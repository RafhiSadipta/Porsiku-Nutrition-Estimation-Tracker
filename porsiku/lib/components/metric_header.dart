import 'package:flutter/material.dart';
import '../constants/constants.dart';

class MetricHeader extends StatelessWidget {
  final String title;
  final String unit;
  final Color barColor;
  final IconData icon;
  final double currentValue;
  final double changePercent;

  const MetricHeader({
    super.key,
    required this.title,
    required this.unit,
    required this.barColor,
    required this.icon,
    required this.currentValue,
    required this.changePercent,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = changePercent >= 0;
    final hasChange = changePercent != 0;

    return Row(
      children: [
        // Icon container with enhanced design
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [barColor.withOpacity(0.15), barColor.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
            border: Border.all(color: barColor.withOpacity(0.2), width: 1),
          ),
          child: Icon(icon, color: barColor, size: 24),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                title,
                style: AppTextStyles.h4.copyWith(
                  fontWeight: AppTexts.semiBold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              // Value and change indicator
              Row(
                children: [
                  // Current value
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: currentValue.toStringAsFixed(
                            currentValue == currentValue.toInt() ? 0 : 1,
                          ),
                          style: AppTextStyles.h2.copyWith(
                            fontWeight: AppTexts.bold,
                            color: barColor,
                          ),
                        ),
                        TextSpan(
                          text: ' $unit',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: AppTexts.medium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasChange) ...[
                    const SizedBox(width: AppSpacing.sm),
                    // Change indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            isPositive
                                ? AppColors.success.withOpacity(0.15)
                                : AppColors.error.withOpacity(0.15),
                            isPositive
                                ? AppColors.success.withOpacity(0.05)
                                : AppColors.error.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(
                          AppBorderRadius.infinity,
                        ),
                        border: Border.all(
                          color:
                              isPositive
                                  ? AppColors.success.withOpacity(0.3)
                                  : AppColors.error.withOpacity(0.3),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPositive
                                ? Icons.trending_up_rounded
                                : Icons.trending_down_rounded,
                            size: 14,
                            color:
                                isPositive
                                    ? AppColors.success
                                    : AppColors.error,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${changePercent.abs().toStringAsFixed(1)}%',
                            style: AppTextStyles.caption.copyWith(
                              fontWeight: AppTexts.semiBold,
                              color:
                                  isPositive
                                      ? AppColors.success
                                      : AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
