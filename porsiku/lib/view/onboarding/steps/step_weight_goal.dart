import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Title and subtitle
          TitleText(text: 'Target berat badanmu?'),
          SizedBox(height: AppSpacing.xs),
          SubtitleText(text: 'Masukkan berat badan yang ingin dicapai (kg)'),
          SizedBox(height: AppSpacing.xl),

          // Premium cards for weight comparison
          Row(
            children: [
              // Current weight card
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.lg),
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
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        '$currentWeight kg',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
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
              SizedBox(width: AppSpacing.lg),

              // Arrow icon
              Icon(Icons.arrow_forward, color: AppColors.primary, size: 24),

              SizedBox(width: AppSpacing.lg),

              // Target weight card
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.md),
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
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        '$targetWeight kg',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
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

          SizedBox(height: AppSpacing.xl), // Premium wheel selector
          Container(
            height: 180.h,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.lightGrey, width: 1),
            ),
            child: ListWheelScrollView.useDelegate(
              itemExtent: 48.h,
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
                      padding: EdgeInsets.symmetric(
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

          SizedBox(height: AppSpacing.lg),

          // Weight difference indicator
          Container(
            padding: EdgeInsets.symmetric(
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
                SizedBox(width: AppSpacing.sm),
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
