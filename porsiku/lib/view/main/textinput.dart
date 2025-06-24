import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:porsiku/view/main/result.dart';
import 'package:porsiku/constants/constants.dart';

class TextInputPage extends StatefulWidget {
  const TextInputPage({super.key});

  static Future<void> show(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: const TextInputPage(),
        );
      },
    );
  }

  @override
  State<TextInputPage> createState() => _TextInputPageState();
}

class _TextInputPageState extends State<TextInputPage>
    with TickerProviderStateMixin {
  final controller = TextEditingController();
  final focusNode = FocusNode();
  bool isLoading = false;

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();

    // Auto focus after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        focusNode.requestFocus();
      }
    });
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
    _scaleController = AnimationController(
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
    controller.dispose();
    focusNode.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _submitFoodInput() async {
    final foodText = controller.text.trim();
    if (foodText.isEmpty || foodText.replaceAll(',', '').trim().isEmpty) {
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_rounded, color: AppColors.white),
              SizedBox(width: AppSpacing.sm),
              const Text('Please enter some food items'),
            ],
          ),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
          ),
        ),
      );
      return;
    }

    setState(() => isLoading = true);
    HapticFeedback.mediumImpact();
    _scaleController.forward().then((_) => _scaleController.reverse());

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
            Uri.parse(
              'https://porsiku-nutrition-estimation-tracker-production.up.railway.app/api/nutri-estimation',
            ),
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
          throw Exception('Invalid nutrition estimation format');
        }
        if (nutritionResult.isEmpty) {
          HapticFeedback.lightImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.search_off_rounded, color: AppColors.white),
                  SizedBox(width: AppSpacing.sm),
                  const Text('No food items detected'),
                ],
              ),
              backgroundColor: AppColors.info,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
              ),
            ),
          );
          setState(() => isLoading = false);
          return;
        } // Success feedback
        HapticFeedback.heavyImpact();

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
        throw Exception('Nutrition estimation failed: ${response.body}');
      }
    } catch (e) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_rounded, color: AppColors.white),
              SizedBox(width: AppSpacing.sm),
              Expanded(child: Text('Failed to estimate nutrition: $e')),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
          ),
        ),
      );
    } finally {
      setState(() => isLoading = false);
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
                                    AppColors.info.withOpacity(0.1),
                                    AppColors.info.withOpacity(0.05),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppBorderRadius.md,
                                ),
                                border: Border.all(
                                  color: AppColors.info.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.text_fields_rounded,
                                color: AppColors.info,
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
                                    'Text Input',
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
                                    'Describe what you ate today',
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

                  SizedBox(height: AppSpacing.lg),

                  // Content section
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Input field
                        Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  AppBorderRadius.lg,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: controller,
                                focusNode: focusNode,
                                maxLines: 4,
                                minLines: 4,
                                enabled: !isLoading,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  hintText:
                                      'e.g., 1 bowl of rice, grilled chicken, vegetables...',
                                  hintStyle: AppTextStyles.bodyLarge.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppBorderRadius.lg,
                                    ),
                                    borderSide: BorderSide(
                                      color: AppColors.lightGrey.withOpacity(
                                        0.3,
                                      ),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppBorderRadius.lg,
                                    ),
                                    borderSide: BorderSide(
                                      color: AppColors.lightGrey.withOpacity(
                                        0.3,
                                      ),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppBorderRadius.lg,
                                    ),
                                    borderSide: BorderSide(
                                      color: AppColors.info,
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: AppColors.white,
                                  contentPadding: EdgeInsets.all(AppSpacing.lg),
                                  prefixIcon: Padding(
                                    padding: EdgeInsets.all(AppSpacing.md),
                                    child: Icon(
                                      Icons.restaurant_menu_rounded,
                                      color: AppColors.info,
                                      size: AppIcons.sm,
                                    ),
                                  ),
                                ),
                                onSubmitted: (_) => _submitFoodInput(),
                              ),
                            )
                            .animate()
                            .fadeIn(delay: 400.ms)
                            .slideY(
                              begin: 0.3,
                              duration: AppAnimations.medium,
                              curve: Curves.easeOutCubic,
                            ),

                        SizedBox(height: AppSpacing.sm),

                        // Helper text
                        Text(
                          'Separate multiple items with commas',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ).animate().fadeIn(delay: 500.ms),

                        SizedBox(height: AppSpacing.xl),

                        // Submit button
                        SizedBox(
                              width: double.infinity,
                              child: AnimatedBuilder(
                                animation: _scaleController,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale:
                                        1.0 + (_scaleController.value * 0.05),
                                    child: ElevatedButton.icon(
                                      onPressed:
                                          isLoading ? null : _submitFoodInput,
                                      icon:
                                          isLoading
                                              ? SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(AppColors.white),
                                                ),
                                              )
                                              : Icon(
                                                Icons.search_rounded,
                                                size: AppIcons.sm,
                                              ),
                                      label: Text(
                                        isLoading
                                            ? 'Analyzing...'
                                            : 'Analyze Nutrition',
                                        style: AppTextStyles.bodyLarge.copyWith(
                                          fontWeight: AppTexts.semiBold,
                                          color: AppColors.white,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.info,
                                        foregroundColor: AppColors.white,
                                        disabledBackgroundColor:
                                            AppColors.lightGrey,
                                        padding: EdgeInsets.symmetric(
                                          vertical: AppSpacing.lg,
                                          horizontal: AppSpacing.xl,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppBorderRadius.lg,
                                          ),
                                        ),
                                        elevation: 4,
                                        shadowColor: AppColors.info.withOpacity(
                                          0.3,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                            .animate()
                            .fadeIn(delay: 600.ms)
                            .slideY(
                              begin: 0.5,
                              duration: AppAnimations.medium,
                              curve: Curves.easeOutCubic,
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
