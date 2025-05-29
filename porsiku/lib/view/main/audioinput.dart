import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'package:porsiku/view/main/result.dart';

Future<void> showAudioInputDialog(BuildContext context) async {
  final Record audioRecorder = Record();
  bool isRecording = false;
  String statusText = "Mengecek izin akses mikrofon...";
  bool permissionChecked = false;

  Future<void> updatePermissionStatus(StateSetter setState) async {
    final hasPermission = await audioRecorder.hasPermission();
    setState(() {
      statusText =
          hasPermission
              ? "Tekan tombol mic untuk mulai merekam."
              : "Izin akses mikrofon ditolak.";
    });
  }

  Future<void> sendAudioToServer(BuildContext context, String filePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) {
        throw Exception('Token login tidak ditemukan, silakan login ulang.');
      }

      final file = File(filePath);
      if (!file.existsSync() || file.lengthSync() == 0) {
        throw Exception('File audio tidak ditemukan atau kosong.');
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      // === STEP 1: Kirim ke detect_food
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.18.156:8080/api/detect_food'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(
        await http.MultipartFile.fromPath(
          'media',
          filePath,
          contentType: MediaType.parse('audio/m4a'),
        ),
      );

      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        Navigator.of(context).pop();
        throw Exception('Gagal mendeteksi makanan: ${response.body}');
      }

      final decoded = jsonDecode(response.body);
      final foodListText = decoded['transkrip']?.toString() ?? '';
      if (foodListText.isEmpty) {
        Navigator.of(context).pop();
        throw Exception('Tidak ada makanan terdeteksi.');
      }

      // === STEP 2: Kirim ke nutri-estimation
      var nutriResponse = await http
          .post(
            Uri.parse('http://192.168.18.156:8080/api/nutri-estimation'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'food_list': foodListText}),
          )
          .timeout(const Duration(seconds: 30));

      if (nutriResponse.statusCode != 200) {
        Navigator.of(context).pop();
        throw Exception('Estimasi nutrisi gagal: ${nutriResponse.body}');
      }

      var decodedNutri = jsonDecode(nutriResponse.body);
      var nutritionResult = decodedNutri['result'];

      if (nutritionResult == null || nutritionResult is! List) {
        Navigator.of(context).pop();
        throw Exception('Format hasil estimasi tidak valid.');
      }

      Navigator.of(context).pop(); // Tutup loading
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder:
              (_) => ResultPage(
                foodListText: foodListText,
                nutritionResult: nutritionResult,
                imagePath: filePath,
              ),
        ),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Tutup loading jika error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal: $e')));
    }
  }

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          if (!permissionChecked) {
            permissionChecked = true;
            updatePermissionStatus(setState);
          }

          return AlertDialog(
            title: const Text("Input Audio"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(statusText),
                IconButton(
                  icon: Icon(isRecording ? Icons.stop : Icons.mic),
                  iconSize: 48,
                  color: isRecording ? Colors.red : Colors.blue,
                  onPressed:
                      statusText.contains("Tekan")
                          ? () async {
                            final directory =
                                await getApplicationDocumentsDirectory();
                            final timestamp =
                                DateTime.now().millisecondsSinceEpoch;
                            final tempPath =
                                "${directory.path}/audio_$timestamp.m4a";

                            if (isRecording) {
                              final recordedPath = await audioRecorder.stop();
                              setState(() {
                                isRecording = false;
                                statusText = "Rekaman selesai. Mengirim...";
                              });
                              if (recordedPath != null &&
                                  recordedPath.isNotEmpty) {
                                await sendAudioToServer(context, recordedPath);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Gagal menyimpan rekaman audio',
                                    ),
                                  ),
                                );
                              }
                            } else {
                              await audioRecorder.start(
                                path: tempPath,
                                encoder: AudioEncoder.aacLc,
                                bitRate: 128000,
                                samplingRate: 44100,
                              );
                              setState(() {
                                isRecording = true;
                                statusText =
                                    "Merekam... Tekan lagi untuk berhenti.";
                              });
                            }
                          }
                          : null,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if (isRecording) {
                    await audioRecorder.stop();
                  }
                  Navigator.of(dialogContext).pop();
                },
                child: const Text("Tutup"),
              ),
            ],
          );
        },
      );
    },
  );
}
