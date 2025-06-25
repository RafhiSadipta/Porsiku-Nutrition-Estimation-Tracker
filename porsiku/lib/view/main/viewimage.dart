import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'result.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'package:porsiku/constants/constants.dart';
import 'package:porsiku/components/premium_dialog.dart';

class ViewImagePage extends StatefulWidget {
  final String imagePath;
  const ViewImagePage({super.key, required this.imagePath});

  @override
  State<ViewImagePage> createState() => _ViewImagePageState();
}

class _ViewImagePageState extends State<ViewImagePage>
    with TickerProviderStateMixin {
  bool _loading = false;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    _slideController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  void _startAnimations() {
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _checkNutrition(BuildContext context) async {
    setState(() => _loading = true);
    HapticFeedback.mediumImpact();
    _pulseController.forward().then((_) => _pulseController.reverse());

    try {
      // Show loading feedback
      _showEnhancedMessage('Analyzing your food image...', isSuccess: true);

      // Get token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) {
        throw Exception('Login token not found. Please login again.');
      }

      // Check image file before upload
      final file = File(widget.imagePath);
      if (!file.existsSync() || file.lengthSync() == 0) {
        throw Exception('Image file not found or empty');
      }

      // 1. Send image to /api/detect_food
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
          'https://porsiku-nutrition-estimation-tracker-production.up.railway.app/api/detect_food',
        ),
      );
      request.headers['Authorization'] = 'Bearer $token';

      // Determine content-type manually
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
      if (foodListText.isEmpty) throw Exception('No food detected in image');

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

      if (jsonStr == null) throw Exception('Could not extract nutrition data');

      var nutritionResult = jsonDecode(jsonStr);
      if (nutritionResult == null || nutritionResult is! List) {
        throw Exception('Invalid nutrition data received');
      }

      // Cek jika semua hasil adalah "Unknown food"
      bool allUnknown = nutritionResult.every(
        (item) =>
            item is Map<String, dynamic> &&
            (item['nama_makanan'] as String?)?.toLowerCase() == 'unknown food',
      );

      if (allUnknown) {
        if (!mounted) return;
        await PremiumDialog.showNoFoodDetected(
          context,
          retryText: "Foto Ulang",
          onRetry: () {
            Navigator.of(context).pop(); // kembali ke kamera
          },
        );
        return;
      }

      // Show progress feedback (moved here after unknown food check)
      _showEnhancedMessage(
        'Food detected! Calculating nutrition...',
        isSuccess: true,
      );

      // Show success feedback
      _showEnhancedMessage(
        'Analysis complete! Redirecting...',
        isSuccess: true,
      );

      // Navigate to ResultPage with enhanced animation
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) => ResultPage(
                foodListText: foodListText,
                nutritionResult: nutritionResult,
                imagePath: widget.imagePath,
                autoLog: false, // Disable auto-logging for immediate display
              ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          transitionDuration: AppAnimations.medium,
        ),
      );
    } catch (e) {
      if (mounted) {
        _showEnhancedMessage('Analysis failed: ${e.toString()}', isError: true);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showEnhancedMessage(
    String message, {
    bool isError = false,
    bool isSuccess = false,
  }) {
    Color backgroundColor;
    IconData icon;

    if (isError) {
      backgroundColor = AppColors.error;
      icon = Icons.error_rounded;
      HapticFeedback.heavyImpact();
    } else if (isSuccess) {
      backgroundColor = AppColors.success;
      icon = Icons.check_circle_rounded;
      HapticFeedback.lightImpact();
    } else {
      backgroundColor = AppColors.info;
      icon = Icons.info_rounded;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: AppColors.white, size: AppIcons.sm),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
        ),
        margin: EdgeInsets.all(AppSpacing.md),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.black.withOpacity(0.3),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.white,
              size: AppIcons.sm,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
            },
          ),
        ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.8, 0.8)),
        title: Text(
          'Image Preview',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.white,
            fontWeight: AppTexts.bold,
          ),
        ).animate().fadeIn(delay: 300.ms).slideY(begin: -0.3),
        centerTitle: true,
        actions: [
          Container(
                margin: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.white,
                    size: AppIcons.sm,
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _showInfoDialog();
                  },
                ),
              )
              .animate()
              .fadeIn(delay: 400.ms)
              .scale(begin: const Offset(0.8, 0.8)),
        ],
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge([_fadeController, _slideController]),
        builder: (context, child) {
          return Stack(
            children: [
              // Main image view
              Positioned.fill(
                child: Center(
                      child: Hero(
                        tag: 'image_${widget.imagePath}',
                        child: Container(
                          margin: EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              AppBorderRadius.lg,
                            ),
                            boxShadow: AppShadows.floating,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppBorderRadius.lg,
                            ),
                            child: Image.file(
                              File(widget.imagePath),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 600.ms)
                    .scale(begin: const Offset(0.9, 0.9)),
              ),

              // Top gradient overlay
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 120,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom action area
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        AppColors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildInstructionCard()
                              .animate()
                              .fadeIn(delay: 500.ms)
                              .slideY(begin: 0.3),
                          SizedBox(height: AppSpacing.lg),
                          _buildActionButton()
                              .animate()
                              .fadeIn(delay: 600.ms)
                              .slideY(begin: 0.3),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Loading overlay
              if (_loading)
                Positioned.fill(
                  child: Container(
                    color: AppColors.black.withOpacity(0.8),
                    child: Center(child: _buildLoadingIndicator()),
                  ).animate().fadeIn(duration: 300.ms),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInstructionCard() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.primary,
              size: AppIcons.lg,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Nutrition Analysis',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: AppTexts.semiBold,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  'Our AI will analyze your food image and provide detailed nutrition information',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: _loading ? 1.0 + (_pulseController.value * 0.1) : 1.0,
          child: Container(
            width: double.infinity,
            height: AppButtons.heightLarge,
            child: ElevatedButton(
              onPressed: _loading ? null : () => _checkNutrition(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: _loading ? AppColors.grey : AppColors.primary,
                foregroundColor: AppColors.white,
                elevation: _loading ? 0 : 8,
                shadowColor: AppColors.primary.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_loading) ...[
                    SizedBox(
                      width: AppIcons.sm,
                      height: AppIcons.sm,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                  ] else ...[
                    Icon(Icons.analytics_rounded, size: AppIcons.md),
                    SizedBox(width: AppSpacing.md),
                  ],
                  Text(
                    _loading ? 'Analyzing Image...' : 'Analyze Nutrition',
                    style: AppTextStyles.buttonLarge.copyWith(
                      fontWeight: AppTexts.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.white.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  strokeWidth: 4,
                ),
              ),
            )
            .animate(onPlay: (controller) => controller.repeat())
            .rotate(duration: 2000.ms),

        SizedBox(height: AppSpacing.xl),

        Text(
          'Analyzing Your Food',
          style: AppTextStyles.h4.copyWith(color: AppColors.white),
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),

        SizedBox(height: AppSpacing.md),

        Text(
          'Our AI is examining your image to identify food items and calculate nutrition values',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.white.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3),
      ],
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              margin: EdgeInsets.all(AppSpacing.lg),
              padding: EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                boxShadow: AppShadows.floating,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.primary,
                    size: AppIcons.xl,
                  ),
                  SizedBox(height: AppSpacing.lg),
                  Text(
                    'AI Nutrition Analysis',
                    style: AppTextStyles.h3,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.lg),
                  Text(
                    'Our advanced AI technology analyzes your food image to:',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.lg),
                  _buildInfoItem(
                    Icons.search_rounded,
                    'Identify Food Items',
                    'Recognizes different foods in your image',
                  ),
                  SizedBox(height: AppSpacing.md),
                  _buildInfoItem(
                    Icons.calculate_rounded,
                    'Estimate Portions',
                    'Calculates serving sizes and quantities',
                  ),
                  SizedBox(height: AppSpacing.md),
                  _buildInfoItem(
                    Icons.restaurant_menu_rounded,
                    'Calculate Nutrition',
                    'Provides detailed nutritional information',
                  ),
                  SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppBorderRadius.md,
                              ),
                            ),
                          ),
                          child: Text(
                            'Got it!',
                            style: AppTextStyles.buttonLarge,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: AppIcons.md),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: AppTexts.semiBold,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                description,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
