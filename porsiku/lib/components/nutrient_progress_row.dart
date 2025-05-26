import 'package:flutter/material.dart';
import 'package:porsiku/constants/constants.dart'; // Ensure this path is correct

class NutrientProgressRow extends StatelessWidget {
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
  Widget build(BuildContext context) {
    double progress = targetValue > 0 ? (currentValue / targetValue) : 0;
    return Row(
      children: [
        SizedBox(
          width: 30, // Adjust size as needed
          height: 30,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 4,
                  backgroundColor: progressColor.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: AppTexts.sm, color: AppColors.black),
            ),
            Text(
              '$currentValue / $targetValue g',
              style: TextStyle(fontSize: AppTexts.xs, color: AppColors.grey),
            ),
          ],
        ),
      ],
    );
  }
}
