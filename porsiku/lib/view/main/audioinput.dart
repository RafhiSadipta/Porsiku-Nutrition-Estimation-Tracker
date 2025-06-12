import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:porsiku/view/main/result.dart';
import 'dart:io';

class AudioInputPage extends StatefulWidget {
  const AudioInputPage({super.key});

  // Tambahkan static show() agar bisa dipanggil sebagai dialog overlay
  static Future<void> show(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.4),
      builder:
          (ctx) => const Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.all(0),
            child: AudioInputPage(),
          ),
    );
  }

  @override
  State<AudioInputPage> createState() => _AudioInputPageState();
}

class _AudioInputPageState extends State<AudioInputPage> {
  FlutterSoundRecorder? _recorder;
  bool _isRecording = false;
  bool _isLoading = false;
  String? _audioPath;
  String? _transcript;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    // Hanya cek permission microphone (storage tidak perlu di Android 13+)
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) {
      setState(() {
        _errorMsg = 'Izin microphone diperlukan.';
      });
      return;
    }
    await _recorder!.openRecorder();
  }

  @override
  void dispose() {
    _recorder?.closeRecorder();
    _recorder = null;
    super.dispose();
  }

  Future<void> _startRecording() async {
    setState(() {
      _errorMsg = null;
    });
    try {
      final dir = await getTemporaryDirectory();
      final filePath =
          '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';
      await _recorder!.startRecorder(toFile: filePath, codec: Codec.aacADTS);
      setState(() {
        _isRecording = true;
        _audioPath = filePath;
      });
    } catch (e) {
      setState(() {
        _errorMsg = 'Gagal mulai merekam: $e';
      });
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _recorder!.stopRecorder();
      setState(() {
        _isRecording = false;
      });
      if (_audioPath != null) {
        // Cek file benar-benar ada sebelum proses
        final file = File(_audioPath!);
        if (!await file.exists()) {
          setState(() {
            _errorMsg = 'File audio tidak ditemukan. Coba ulangi.';
          });
          return;
        }
        await _processAudio(_audioPath!);
      }
    } catch (e) {
      setState(() {
        _errorMsg = 'Gagal stop rekaman: $e';
      });
    }
  }

  Future<void> _processAudio(String path) async {
    setState(() {
      _isLoading = true;
      _transcript = null;
      _errorMsg = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://10.125.170.253:8080/api/detect_food'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('audio', path));
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        final respJson = jsonDecode(response.body);
        // TODO: Tampilkan transkrip

        // Kirim transcript ke nutri-estimation
        final transcript = respJson['transcript'] ?? '';
        setState(() {
          _transcript = transcript;
        });
        if (transcript.isEmpty) {
          setState(() {
            _errorMsg = 'Tidak ada makanan terdeteksi dari suara.';
            _isLoading = false;
          });
          return;
        }
        final foodListArr =
            transcript
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();
        final nutriResp = await http.post(
          Uri.parse('http://10.125.170.253:8080/api/nutri-estimation'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'food_list': foodListArr}),
        );
        if (nutriResp.statusCode == 200) {
          final nutriJson = jsonDecode(nutriResp.body);
          var nutritionResult = nutriJson['result'];
          if (nutritionResult == null || nutritionResult is! List) {
            throw Exception('Format hasil estimasi tidak valid');
          }
          if (nutritionResult.isEmpty) {
            setState(() {
              _errorMsg = 'Tidak ada makanan terdeteksi.';
              _isLoading = false;
            });
            return;
          }
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder:
                  (_) => ResultPage(
                    foodListText: transcript,
                    nutritionResult: nutritionResult,
                    imagePath: _audioPath ?? '',
                  ),
            ),
          );
        } else {
          throw Exception('Estimasi nutrisi gagal: \\${nutriResp.body}');
        }
      } else {
        throw Exception('Gagal transkripsi audio: ${response.body}');
      }
    } catch (e) {
      setState(() {
        _errorMsg = 'Gagal proses audio: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ganti Scaffold dengan Material transparan agar overlay
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 40),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Tekan tombol mic dan sebutkan makanan yang dikonsumsi',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (_transcript != null)
                Column(
                  children: [
                    const Text(
                      'Transkrip:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(_transcript!, textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                  ],
                ),
              if (_errorMsg != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _errorMsg!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              IconButton(
                iconSize: 64,
                icon: Icon(
                  _isRecording ? Icons.stop_circle : Icons.mic,
                  color: Colors.black,
                ),
                onPressed:
                    _isLoading
                        ? null
                        : _isRecording
                        ? _stopRecording
                        : _startRecording,
              ),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
