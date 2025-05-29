import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

Future<void> showAudioInputDialog(BuildContext context) async {
  final Record audioRecorder = Record();
  String statusText = "Speech input is currently disabled.";

  if (await audioRecorder.hasPermission()) {
    statusText = "Press the mic button to start recording.";
  } else {
    statusText = "Permission denied for audio recording.";
  }

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Audio Input"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(statusText),
                IconButton(
                  icon: const Icon(Icons.mic),
                  onPressed: statusText.contains("Press")
                      ? () async {
                          final directory = await getApplicationDocumentsDirectory();
                          final filePath = "${directory.path}/audio.m4a";

                          if (await audioRecorder.isRecording()) {
                            await audioRecorder.stop();
                            setState(() {
                              statusText = "Recording stopped. File saved at $filePath.";
                            });

                            // Send audio file to backend
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

                              var request = http.MultipartRequest(
                                'POST',
                                Uri.parse('http://192.168.136.53:8080/api/detect_food'),
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
                                throw Exception('Food detection failed: ${response.body}');
                              }

                              var foodListText = response.body;
                              if (foodListText.isEmpty) {
                                throw Exception('No food detected.');
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Detected food: $foodListText')),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed: $e')),
                              );
                            }
                          } else {
                            await audioRecorder.start(
                              path: filePath,
                              encoder: AudioEncoder.aacLc,
                              bitRate: 128000,
                              samplingRate: 44100,
                            );
                            setState(() {
                              statusText = "Recording... Press again to stop.";
                            });
                          }
                        }
                      : null,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text("Close"),
              ),
            ],
          );
        },
      );
    },
  );
}