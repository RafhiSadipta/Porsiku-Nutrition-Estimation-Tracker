import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:porsiku/constants/constants.dart';

class CaloriesProgressIndicator extends StatefulWidget {
  final int currentCalories;
  final int targetCalories;

  const CaloriesProgressIndicator({
    super.key,
    required this.currentCalories,
    required this.targetCalories,
  });

  @override
  State<CaloriesProgressIndicator> createState() =>
      _CaloriesProgressIndicatorState();
}

class _CaloriesProgressIndicatorState extends State<CaloriesProgressIndicator>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end:
          widget.targetCalories > 0
              ? (widget.currentCalories / widget.targetCalories)
              : 0.0,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    // Start animation after a small delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void didUpdateWidget(CaloriesProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentCalories != oldWidget.currentCalories ||
        widget.targetCalories != oldWidget.targetCalories) {
      _updateProgress();
    }
  }

  void _updateProgress() {
    final newProgress =
        widget.targetCalories > 0
            ? (widget.currentCalories / widget.targetCalories)
            : 0.0;

    _progressAnimation = Tween<double>(
      begin: _progressAnimation.value,
      end: newProgress,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.reset();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
              border: Border.all(
                color: AppColors.blue.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title with icon (similar to nutrient progress row)
                Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          size: AppIcons.sm,
                          color: AppColors.blue,
                        ),
                        SizedBox(width: AppSpacing.xs),
                        Text(
                          'Calories',
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 400.ms)
                    .slideY(begin: 0.3, duration: 600.ms, delay: 400.ms),

                SizedBox(height: AppSpacing.md),

                // Enhanced circular progress indicator
                SizedBox(
                      width: 90,
                      height: 90,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Background circle with gradient
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.blue.withOpacity(0.1),
                                  AppColors.blue.withOpacity(0.05),
                                ],
                              ),
                            ),
                          ),

                          // Animated circular progress
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: CircularProgressIndicator(
                              value: _progressAnimation.value,
                              strokeWidth: 12,
                              backgroundColor: AppColors.blue.withOpacity(0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.blue,
                              ),
                              strokeCap: StrokeCap.round,
                            ),
                          ),

                          // Animated center content
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Current calories with number animation
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Text(
                                  '${widget.currentCalories}',
                                  key: ValueKey(widget.currentCalories),
                                  style: AppTextStyles.h3.copyWith(
                                    color: AppColors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: AppTexts.ml,
                                  ),
                                ),
                              ),

                              // Target calories
                              Text(
                                '/ ${widget.targetCalories}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .scale(
                      duration: 800.ms,
                      delay: 200.ms,
                      curve: Curves.elasticOut,
                    )
                    .fadeIn(duration: 600.ms, delay: 200.ms),
              ],
            ),
          ),
        );
      },
    );
  }
}
