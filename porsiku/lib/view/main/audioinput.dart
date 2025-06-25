import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:porsiku/view/main/result.dart';
import 'package:porsiku/constants/constants.dart';
import 'dart:io';
import 'package:http_parser/http_parser.dart';

class AudioInputPage extends StatefulWidget {
  const AudioInputPage({super.key});

  static Future<void> show(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      builder: (BuildContext context) {
        return const AudioInputPage();
      },
    );
  }

  @override
  State<AudioInputPage> createState() => _AudioInputPageState();
}

class _AudioInputPageState extends State<AudioInputPage>
    with TickerProviderStateMixin {
  FlutterSoundRecorder? _recorder;
  bool _isRecording = false;
  bool _isLoading = false;
  String? _audioPath;
  String? _transcript;
  String? _errorMsg;

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late AnimationController _micController;

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _initializeAnimations();
    _initRecorder();
    _startAnimations();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _micController = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
  }

  void _startAnimations() {
    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _recorder?.closeRecorder();
    _recorder = null;
    _slideController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    _micController.dispose();
    super.dispose();
  }

  Future<void> _initRecorder() async {
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) {
      setState(() {
        _errorMsg = 'Microphone permission is required.';
      });
      return;
    }
    await _recorder!.openRecorder();
  }

  Future<void> _startRecording() async {
    setState(() {
      _errorMsg = null;
    });
    try {
      HapticFeedback.mediumImpact();
      _micController.forward().then((_) => _micController.reverse());

      final dir = await getTemporaryDirectory();
      final filePath =
          '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder!.startRecorder(toFile: filePath, codec: Codec.aacMP4);

      setState(() {
        _isRecording = true;
        _audioPath = filePath;
      });

      // Start pulse animation when recording
      _pulseController.repeat();
    } catch (e) {
      HapticFeedback.heavyImpact();
      setState(() {
        _errorMsg = 'Failed to start recording: $e';
      });
    }
  }

  Future<void> _stopRecording() async {
    try {
      HapticFeedback.lightImpact();
      _micController.forward().then((_) => _micController.reverse());
      _pulseController.stop();

      await _recorder!.stopRecorder();
      setState(() {
        _isRecording = false;
      });

      if (_audioPath != null) {
        final file = File(_audioPath!);
        if (!await file.exists()) {
          setState(() {
            _errorMsg = 'Audio file not found. Please try again.';
          });
          return;
        }
        await _processAudio(_audioPath!);
      }
    } catch (e) {
      HapticFeedback.heavyImpact();
      setState(() {
        _errorMsg = 'Failed to stop recording: $e';
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
      // 1. Kirim audio ke /api/detect_food
      var detectRequest = http.MultipartRequest(
        'POST',
        Uri.parse(
          'https://porsiku-nutrition-estimation-tracker-production.up.railway.app/api/detect_food',
        ),
      );
      detectRequest.headers['Authorization'] = 'Bearer $token';
      detectRequest.files.add(
        await http.MultipartFile.fromPath(
          'media',
          path,
          contentType: MediaType('audio', 'm4a'),
        ),
      );
      final detectStreamed = await detectRequest.send();
      final detectResponse = await http.Response.fromStream(detectStreamed);
      if (detectResponse.statusCode != 200) {
        throw Exception('Failed to detect audio: ${detectResponse.body}');
      }
      final detectJson = jsonDecode(detectResponse.body);
      if (detectJson['type'] != 'audio' || detectJson['transkrip'] == null) {
        throw Exception('Invalid audio detection format');
      }
      final transkrip = detectJson['transkrip'];
      setState(() {
        _transcript = transkrip;
      });
      // 2. Kirim transkrip ke /api/nutri-estimation
      final nutriResponse = await http.post(
        Uri.parse(
          'https://porsiku-nutrition-estimation-tracker-production.up.railway.app/api/nutri-estimation',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'food_list': transkrip}),
      );
      if (nutriResponse.statusCode != 200) {
        throw Exception('Nutrition estimation failed: ${nutriResponse.body}');
      }
      // Ekstrak JSON array dari response (bisa dalam code block)
      String nutriBody = nutriResponse.body;
      RegExp codeBlock = RegExp(r'```json\\n([\s\S]*?)\\n```');
      RegExpMatch? match = codeBlock.firstMatch(nutriBody);
      String? jsonStr;
      if (match != null && match.groupCount >= 1) {
        jsonStr = match.group(1);
      } else {
        // fallback: cari array JSON
        RegExp arr = RegExp(r'(\[.*\])', dotAll: true);
        var arrMatch = arr.firstMatch(nutriBody);
        if (arrMatch != null) jsonStr = arrMatch.group(1);
      }
      if (jsonStr == null)
        throw Exception('Could not extract nutrition results');
      var nutritionResult = jsonDecode(jsonStr);
      if (nutritionResult == null || nutritionResult is! List) {
        throw Exception('Invalid nutrition estimation format');
      }
      if (nutritionResult.isEmpty) {
        setState(() {
          _errorMsg = 'No food items detected in the audio.';
          _isLoading = false;
        });
        return;
      }
      bool allUnknown = nutritionResult.every(
        (item) =>
            item is Map<String, dynamic> &&
            (item['nama_makanan'] as String?)?.toLowerCase() == 'unknown food',
      );
      if (allUnknown) {
        if (!mounted) return;
        await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text("Tidak ada makanan yang terdeteksi"),
                content: const Text(
                  "Silakan foto ulang makananmu untuk hasil yang lebih akurat.",
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // tutup dialog
                    },
                    child: const Text("Rekam Ulang"),
                  ),
                ],
              ),
        );
        return;
      }
      // Success feedback
      HapticFeedback.heavyImpact();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder:
              (_) => ResultPage(
                foodListText: transkrip,
                nutritionResult: nutritionResult,
                imagePath: _audioPath ?? '',
              ),
        ),
      );
    } catch (e) {
      HapticFeedback.heavyImpact();
      setState(() {
        _errorMsg = 'Failed to process audio: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_slideController, _fadeController]),
      builder: (context, child) {
        return Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppBorderRadius.xl),
                ),
                boxShadow: AppShadows.floating,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    margin: EdgeInsets.symmetric(vertical: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey,
                      borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                    ),
                  ).animate().scale(
                    duration: AppAnimations.medium,
                    curve: Curves.elasticOut,
                  ),

                  // Header section
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Row(
                      children: [
                        // Icon container
                        Container(
                              padding: EdgeInsets.all(AppSpacing.sm),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.success.withOpacity(0.1),
                                    AppColors.success.withOpacity(0.05),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppBorderRadius.md,
                                ),
                                border: Border.all(
                                  color: AppColors.success.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.mic_rounded,
                                color: AppColors.success,
                                size: AppIcons.md,
                              ),
                            )
                            .animate()
                            .scale(
                              duration: AppAnimations.medium,
                              curve: Curves.elasticOut,
                            )
                            .fadeIn(),

                        SizedBox(width: AppSpacing.md),

                        // Title and subtitle
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                    'Voice Input',
                                    style: AppTextStyles.h3.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: AppTexts.bold,
                                    ),
                                  )
                                  .animate()
                                  .fadeIn(delay: 100.ms)
                                  .slideX(
                                    begin: -0.3,
                                    duration: AppAnimations.medium,
                                    curve: Curves.easeOutCubic,
                                  ),
                              Text(
                                    'Speak about what you ate today',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  )
                                  .animate()
                                  .fadeIn(delay: 200.ms)
                                  .slideX(
                                    begin: -0.3,
                                    duration: AppAnimations.medium,
                                    curve: Curves.easeOutCubic,
                                  ),
                            ],
                          ),
                        ),

                        // Close button
                        IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(
                                Icons.close_rounded,
                                color: AppColors.textSecondary,
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.lightGrey
                                    .withOpacity(0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppBorderRadius.sm,
                                  ),
                                ),
                              ),
                            )
                            .animate()
                            .fadeIn(delay: 300.ms)
                            .scale(begin: const Offset(0.8, 0.8)),
                      ],
                    ),
                  ),

                  SizedBox(height: AppSpacing.xl),

                  // Main content section
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Column(
                      children: [
                        // Status messages
                        if (_transcript != null)
                          Container(
                            padding: EdgeInsets.all(AppSpacing.md),
                            margin: EdgeInsets.only(bottom: AppSpacing.lg),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                AppBorderRadius.md,
                              ),
                              border: Border.all(
                                color: AppColors.success.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle_rounded,
                                      color: AppColors.success,
                                      size: AppIcons.sm,
                                    ),
                                    SizedBox(width: AppSpacing.sm),
                                    Text(
                                      'Transcript:',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.success,
                                        fontWeight: AppTexts.semiBold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: AppSpacing.sm),
                                Text(
                                  _transcript!,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn().slideY(begin: -0.3),

                        if (_errorMsg != null)
                          Container(
                            padding: EdgeInsets.all(AppSpacing.md),
                            margin: EdgeInsets.only(bottom: AppSpacing.lg),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                AppBorderRadius.md,
                              ),
                              border: Border.all(
                                color: AppColors.error.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_rounded,
                                  color: AppColors.error,
                                  size: AppIcons.sm,
                                ),
                                SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Text(
                                    _errorMsg!,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn().slideY(begin: -0.3),

                        // Microphone button
                        AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return AnimatedBuilder(
                                  animation: _micController,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: 1.0 + (_micController.value * 0.1),
                                      child: Container(
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: RadialGradient(
                                            colors: [
                                              _isRecording
                                                  ? AppColors.error.withOpacity(
                                                    0.2,
                                                  )
                                                  : AppColors.success
                                                      .withOpacity(0.2),
                                              _isRecording
                                                  ? AppColors.error.withOpacity(
                                                    0.1,
                                                  )
                                                  : AppColors.success
                                                      .withOpacity(0.1),
                                              Colors.transparent,
                                            ],
                                            stops: [
                                              0.3 +
                                                  (_pulseController.value *
                                                      0.2),
                                              0.6 +
                                                  (_pulseController.value *
                                                      0.3),
                                              1.0,
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  _isRecording
                                                      ? AppColors.error
                                                          .withOpacity(0.3)
                                                      : AppColors.success
                                                          .withOpacity(0.3),
                                              blurRadius: 20,
                                              spreadRadius:
                                                  _isRecording ? 5 : 0,
                                            ),
                                          ],
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap:
                                                _isLoading
                                                    ? null
                                                    : _isRecording
                                                    ? _stopRecording
                                                    : _startRecording,
                                            borderRadius: BorderRadius.circular(
                                              60,
                                            ),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color:
                                                    _isRecording
                                                        ? AppColors.error
                                                        : AppColors.success,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: AppColors.black
                                                        .withOpacity(0.2),
                                                    blurRadius: 10,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: Icon(
                                                _isRecording
                                                    ? Icons.stop_rounded
                                                    : Icons.mic_rounded,
                                                color: AppColors.white,
                                                size: 48,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            )
                            .animate()
                            .fadeIn(delay: 400.ms)
                            .scale(
                              begin: const Offset(0.8, 0.8),
                              duration: AppAnimations.medium,
                              curve: Curves.elasticOut,
                            ),

                        SizedBox(height: AppSpacing.lg),

                        // Instructions or loading
                        if (_isLoading)
                          Column(
                            children: [
                              SizedBox(
                                width: 32,
                                height: 32,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.success,
                                  ),
                                ),
                              ),
                              SizedBox(height: AppSpacing.md),
                              Text(
                                'Processing your voice...',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ).animate().fadeIn()
                        else
                          Column(
                            children: [
                              Text(
                                _isRecording
                                    ? 'Listening... Tap to stop'
                                    : 'Tap the microphone and speak',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: AppTexts.semiBold,
                                ),
                                textAlign: TextAlign.center,
                              ).animate().fadeIn(delay: 500.ms),
                            ],
                          ),

                        SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
                ],
              ),
            )
            .animate()
            .slideY(
              begin: 1.0,
              duration: AppAnimations.medium,
              curve: Curves.easeOutCubic,
            )
            .fadeIn(duration: AppAnimations.medium);
      },
    );
  }
}
