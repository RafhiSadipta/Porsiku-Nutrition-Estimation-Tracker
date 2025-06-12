import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:porsiku/view/main/result.dart';

// Refactor: Jadikan widget ini sebagai dialog overlay, bukan halaman penuh.
// Tambahkan fungsi static untuk menampilkan dialog ini.
class TextInputPage extends StatefulWidget {
  const TextInputPage({super.key});

  static Future<void> show(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.4),
      builder:
          (ctx) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 40,
            ),
            child: const TextInputPage(),
          ),
    );
  }

  @override
  State<TextInputPage> createState() => _TextInputPageState();
}

class _TextInputPageState extends State<TextInputPage> {
  final controller = TextEditingController();
  bool isLoading = false;

  Future<void> _submitFoodInput() async {
    final foodText = controller.text.trim();
    if (foodText.isEmpty || foodText.replaceAll(',', '').trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Input makanan tidak boleh kosong.')),
      );
      return;
    }
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final foodListArr =
          foodText
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
      final response = await http
          .post(
            Uri.parse('http://192.168.0.107:8080/api/nutri-estimation'),
            headers: <String, String>{
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'food_list': foodListArr}),
          )
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final Map<String, dynamic> respJson = jsonDecode(response.body);
        var nutritionResult = respJson['result'];
        if (nutritionResult == null || nutritionResult is! List) {
          throw Exception('Format hasil estimasi tidak valid');
        }
        if (nutritionResult.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak ada makanan terdeteksi.')),
          );
          setState(() => isLoading = false);
          return;
        }
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder:
                (_) => ResultPage(
                  foodListText: foodText,
                  nutritionResult: nutritionResult,
                  imagePath: '',
                ),
          ),
        );
      } else {
        throw Exception('Estimasi nutrisi gagal: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal estimasi nutrisi: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                minLines: 4,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'What do you eat today?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                onSubmitted: (_) => _submitFoodInput(),
                enabled: !isLoading,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: isLoading ? null : _submitFoodInput,
                  child:
                      isLoading
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Text(
                            'Confirm',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
