// ini cuma halaman sementara aja buat ngetes imageview sama save to galery
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'result.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

class ViewImagePage extends StatefulWidget {
  final String imagePath;
  const ViewImagePage({super.key, required this.imagePath});

  @override
  State<ViewImagePage> createState() => _ViewImagePageState();
}

class _ViewImagePageState extends State<ViewImagePage> {
  bool _loading = false;

  Future<void> _checkNutrition(BuildContext context) async {
    setState(() => _loading = true);
    try {
      // Ambil token dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) {
        throw Exception('Token login tidak ditemukan, silakan login ulang.');
      }
      // Cek file gambar sebelum upload
      final file = File(widget.imagePath);
      if (!file.existsSync() || file.lengthSync() == 0) {
        throw Exception('File gambar tidak ditemukan atau kosong');
      }
      // 1. Send image to /api/detect_food
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
          'https://porsiku-nutrition-estimation-tracker-production.up.railway.app/api/detect_food',
        ),
      );
      request.headers['Authorization'] = 'Bearer $token';
      // Tentukan content-type manual
      String? contentType;
      if (widget.imagePath.toLowerCase().endsWith('.jpg') ||
          widget.imagePath.toLowerCase().endsWith('.jpeg')) {
        contentType = 'image/jpeg';
      } else if (widget.imagePath.toLowerCase().endsWith('.png')) {
        contentType = 'image/png';
      }
      request.files.add(
        await http.MultipartFile.fromPath(
          'media',
          widget.imagePath,
          contentType:
              contentType != null ? MediaType.parse(contentType) : null,
        ),
      );
      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      var response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode != 200) {
        String backendMsg = response.body;
        throw Exception('Food detection failed: $backendMsg');
      }
      var foodListText = response.body;
      if (foodListText.isEmpty) throw Exception('No food detected');

      // 2. Send food list to /api/nutri-estimation
      var nutriResponse = await http
          .post(
            Uri.parse(
              'https://porsiku-nutrition-estimation-tracker-production.up.railway.app/api/nutri-estimation',
            ),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'food_list': foodListText}),
          )
          .timeout(const Duration(seconds: 30));
      if (nutriResponse.statusCode != 200) {
        throw Exception('Nutrition estimation failed');
      }
      // Extract JSON array from Markdown code block
      String nutriBody = nutriResponse.body;
      RegExp codeBlock = RegExp(r'```json\n([\s\S]*?)\n```');
      RegExpMatch? match = codeBlock.firstMatch(nutriBody);
      String? jsonStr;
      if (match != null && match.groupCount >= 1) {
        jsonStr = match.group(1);
      } else {
        // fallback: try to find any JSON array in the response
        RegExp arr = RegExp(r'(\[.*\])', dotAll: true);
        var arrMatch = arr.firstMatch(nutriBody);
        if (arrMatch != null) jsonStr = arrMatch.group(1);
      }
      if (jsonStr == null) throw Exception('Could not extract nutrition JSON');
      var nutritionResult = jsonDecode(jsonStr);
      if (nutritionResult == null || nutritionResult is! List) {
        throw Exception('Invalid nutrition result');
      }

      // Navigate to ResultPage - let ResultPage handle the consumption logging
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder:
              (_) => ResultPage(
                foodListText: foodListText,
                nutritionResult: nutritionResult,
                imagePath: widget.imagePath,
              ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Preview', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Image.file(File(widget.imagePath), fit: BoxFit.contain),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 32.0),
            child: SizedBox(
              width: 220,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon:
                    _loading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.restaurant_menu),
                label: Text(
                  _loading ? 'Checking...' : 'Check Nutrition',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: _loading ? null : () => _checkNutrition(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
