import 'package:flutter/material.dart';
import 'package:porsiku/components/title.dart';
import 'package:porsiku/constants/constants.dart';

class StepAge extends StatelessWidget {
  final int selectedAge;
  final ValueChanged<int> onAgeChanged;

  const StepAge({
    super.key,
    required this.selectedAge,
    required this.onAgeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Header
          Column(
            children: [
              TitleText(text: 'Berapa usiamu?'),
              SizedBox(height: AppSpacing.sm),
              SubtitleText(
                text:
                    'Usia membantu kami menghitung\nkebutuhan kalori yang tepat',
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xxl),

          // Age Display Card
          Container(
            padding: EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppBorderRadius.xl),
              boxShadow: AppShadows.card,
            ),
            child: Column(
              children: [
                Text(
                  'Usia Saya',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  '$selectedAge',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'tahun',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.xl),

          // Age Selector
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              boxShadow: AppShadows.card,
            ),
            child: Stack(
              children: [
                // Selection indicator
                Positioned(
                  top: 76,
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppBorderRadius.md),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                  ),
                ),
                // Wheel picker
                ListWheelScrollView.useDelegate(
                  itemExtent: 48,
                  diameterRatio: 2.0,
                  physics: const FixedExtentScrollPhysics(),
                  onSelectedItemChanged: onAgeChanged,
                  childDelegate: ListWheelChildBuilderDelegate(
                    builder: (context, index) {
                      final age = 10 + index;
                      final isSelected = selectedAge == age;
                      return Center(
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            '$age',
                            style: TextStyle(
                              fontSize: isSelected ? 24 : 18,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                              color:
                                  isSelected
                                      ? AppColors.primary
                                      : AppColors.grey,
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: 81, // 10-90
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.lg),

          // Helper text
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Geser untuk memilih usia yang sesuai',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                    ),
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
