import 'package:flutter/material.dart';
import 'package:porsiku/components/title.dart';
import 'package:porsiku/constants/constants.dart';

class StepHeight extends StatelessWidget {
  final int selectedHeight;
  final ValueChanged<int> onHeightChanged;
  const StepHeight({
    super.key,
    required this.selectedHeight,
    required this.onHeightChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Title and subtitle
          TitleText(text: 'Tinggi badanmu?'),
          const SizedBox(height: AppSpacing.xs),
          SubtitleText(text: 'Masukkan tinggi badan kamu (cm)'),
          const SizedBox(height: AppSpacing.xl),

          // Premium card for selected height display
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
                Icon(Icons.height, color: AppColors.primary, size: 32),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '$selectedHeight cm',
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Tinggi badan kamu',
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
              onSelectedItemChanged: onHeightChanged,
              childDelegate: ListWheelChildBuilderDelegate(
                builder: (context, index) {
                  final height = 100 + index;
                  final isSelected = selectedHeight == height;

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
                        '$height cm',
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
                childCount: 101, // 100-200
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Helper text
          Text(
            'Geser untuk memilih tinggi badan yang sesuai',
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
