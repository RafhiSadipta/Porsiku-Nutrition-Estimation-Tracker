import 'package:flutter/material.dart';
import 'package:porsiku/components/title.dart';
import 'package:porsiku/constants/constants.dart';

class StepWeightGoal extends StatelessWidget {
  final int currentWeight;
  final int targetWeight;
  final ValueChanged<int> onTargetWeightChanged;
  const StepWeightGoal({
    super.key,
    required this.currentWeight,
    required this.targetWeight,
    required this.onTargetWeightChanged,
  });

  @override
  Widget build(BuildContext context) {
    final diff = targetWeight - currentWeight;
    final isIdeal = diff == 0;
    final isGain = diff > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Title and subtitle
          TitleText(text: 'Target berat badanmu?'),
          const SizedBox(height: AppSpacing.xs),
          SubtitleText(text: 'Masukkan berat badan yang ingin dicapai (kg)'),
          const SizedBox(height: AppSpacing.xl),

          // Premium cards for weight comparison
          Row(
            children: [
              // Current weight card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppShadows.card,
                    border: Border.all(color: AppColors.lightGrey, width: 1),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.scale,
                        color: AppColors.textSecondary,
                        size: 24,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '$currentWeight kg',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Saat ini',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              // Arrow icon
              Icon(Icons.arrow_forward, color: AppColors.primary, size: 24),

              const SizedBox(width: AppSpacing.md),

              // Target weight card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppShadows.card,
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.flag, color: AppColors.primary, size: 24),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '$targetWeight kg',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Target',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // Premium wheel selector
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.lightGrey, width: 1),
            ),
            child: ListWheelScrollView.useDelegate(
              itemExtent: 48,
              diameterRatio: 1.2,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: onTargetWeightChanged,
              childDelegate: ListWheelChildBuilderDelegate(
                builder: (context, index) {
                  final weight = 30 + index;
                  final isSelected = targetWeight == weight;

                  return Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? AppColors.primary.withOpacity(0.1)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$weight kg',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontSize: isSelected ? 24 : 18,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          color:
                              isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                },
                childCount: 121, // 30-150
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Weight difference indicator
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color:
                  isIdeal
                      ? AppColors.success.withOpacity(0.1)
                      : isGain
                      ? AppColors.warning.withOpacity(0.1)
                      : AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isIdeal
                        ? AppColors.success
                        : isGain
                        ? AppColors.warning
                        : AppColors.primary,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isIdeal
                      ? Icons.check_circle
                      : isGain
                      ? Icons.trending_up
                      : Icons.trending_down,
                  color:
                      isIdeal
                          ? AppColors.success
                          : isGain
                          ? AppColors.warning
                          : AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  isIdeal
                      ? 'Berat badanmu sudah ideal!'
                      : 'Berat badanmu akan ${isGain ? 'naik' : 'turun'} ${diff.abs()}kg',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color:
                        isIdeal
                            ? AppColors.success
                            : isGain
                            ? AppColors.warning
                            : AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
