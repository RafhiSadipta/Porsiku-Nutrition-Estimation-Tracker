import 'package:flutter/material.dart';
import 'package:porsiku/constants/constants.dart'; // Ensure this path is correct

class CaloriesProgressIndicator extends StatelessWidget {
  final int currentCalories;
  final int targetCalories;

  const CaloriesProgressIndicator({
    super.key,
    required this.currentCalories,
    required this.targetCalories,
  });

  @override
  Widget build(BuildContext context) {
    double progress =
        targetCalories > 0 ? (currentCalories / targetCalories) : 0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Calories',
          style: TextStyle(
            fontSize: AppTexts.md,
            color: AppColors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 100, // Adjust size as needed
          height: 100,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 10,
                  backgroundColor: AppColors.lightGrey.withOpacity(0.5),
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.blue),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$currentCalories',
                    style: TextStyle(
                      fontSize: AppTexts.xl,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blue,
                    ),
                  ),
                  Text(
                    '/ $targetCalories',
                    style: TextStyle(
                      fontSize: AppTexts.sm,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
