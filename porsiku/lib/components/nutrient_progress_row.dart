import 'package:flutter/material.dart';
import 'package:porsiku/constants/constants.dart';

class NutrientProgressRow extends StatefulWidget {
  final String title;
  final int currentValue;
  final int targetValue;
  final Color progressColor;

  const NutrientProgressRow({
    super.key,
    required this.title,
    required this.currentValue,
    required this.targetValue,
    required this.progressColor,
  });

  @override
  State<NutrientProgressRow> createState() => _NutrientProgressRowState();
}

class _NutrientProgressRowState extends State<NutrientProgressRow>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    final progress =
        widget.targetValue > 0
            ? (widget.currentValue / widget.targetValue)
            : 0.0;

    _progressAnimation = Tween<double>(begin: 0.0, end: progress).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _slideAnimation = Tween<double>(begin: 0.3, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void didUpdateWidget(NutrientProgressRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentValue != oldWidget.currentValue ||
        widget.targetValue != oldWidget.targetValue) {
      _updateProgress();
    }
  }

  void _updateProgress() {
    final newProgress =
        widget.targetValue > 0
            ? (widget.currentValue / widget.targetValue)
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
    final progress =
        widget.targetValue > 0
            ? (widget.currentValue / widget.targetValue)
            : 0.0;

    final isOverTarget = progress > 1.0;
    final displayProgress = progress.clamp(0.0, 1.0);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 20),
          child: Opacity(
            opacity: 1.0 - _slideAnimation.value,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: widget.progressColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
                border: Border.all(
                  color: widget.progressColor.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Enhanced circular progress indicator
                  Container(
                    width: 36,
                    height: 36,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background circle with gradient
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                widget.progressColor.withOpacity(0.1),
                                widget.progressColor.withOpacity(0.05),
                              ],
                            ),
                          ),
                        ),

                        // Animated progress circle
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            value: _progressAnimation.value,
                            strokeWidth: 5,
                            backgroundColor: widget.progressColor.withOpacity(
                              0.2,
                            ),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              widget.progressColor,
                            ),
                            strokeCap: StrokeCap.round,
                          ),
                        ),

                        // Center progress percentage
                        if (displayProgress >= 0.1)
                          Text(
                            '${(displayProgress * 100).toInt()}%',
                            style: AppTextStyles.caption.copyWith(
                              color: widget.progressColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 8,
                            ),
                          ),
                      ],
                    ),
                  ),

                  SizedBox(width: AppSpacing.sm),

                  // Enhanced text content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Title with icon
                            Row(
                              children: [
                                Icon(
                                  _getNutrientIcon(widget.title),
                                  size: AppIcons.sm,
                                  color: widget.progressColor,
                                ),
                                SizedBox(width: AppSpacing.xs),
                                Text(
                                  widget.title,
                                  style: AppTextStyles.label.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),

                            // Progress indicator badge
                            if (isOverTarget)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSpacing.xs,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(
                                    AppBorderRadius.xs,
                                  ),
                                ),
                                child: Text(
                                  'Over',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.warning,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 8,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        SizedBox(height: 2),

                        // Values and progress bar
                        Row(
                          children: [
                            // Current and target values
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${widget.currentValue}',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' / ${widget.targetValue}g',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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

  IconData _getNutrientIcon(String nutrient) {
    switch (nutrient.toLowerCase()) {
      case 'protein':
        return Icons.fitness_center;
      case 'fat':
      case 'fats':
        return Icons.eco_rounded;
      case 'carbs':
      case 'carbohydrates':
        return Icons.bakery_dining_rounded;
      default:
        return Icons.circle;
    }
  }
}
