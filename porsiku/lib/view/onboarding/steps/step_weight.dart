import 'package:flutter/material.dart';
import 'package:porsiku/components/title.dart';
import 'package:porsiku/constants/constants.dart';

class StepWeight extends StatelessWidget {
  final int selectedWeight;
  final ValueChanged<int> onWeightChanged;
  const StepWeight({
    super.key,
    required this.selectedWeight,
    required this.onWeightChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Title and subtitle
          TitleText(text: 'Berat badanmu?'),
          const SizedBox(height: AppSpacing.xs),
          SubtitleText(text: 'Masukkan berat badan kamu saat ini (kg)'),
          const SizedBox(height: AppSpacing.xl),

          // Premium card for selected weight display
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppShadows.card,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.monitor_weight, color: AppColors.primary, size: 32),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '$selectedWeight kg',
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Berat badan saat ini',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
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
              onSelectedItemChanged: onWeightChanged,
              childDelegate: ListWheelChildBuilderDelegate(
                builder: (context, index) {
                  final weight = 30 + index;
                  final isSelected = selectedWeight == weight;

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

          // Helper text
          Text(
            'Geser untuk memilih berat badan yang sesuai',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
