import 'package:flutter/material.dart';
import 'package:porsiku/constants/constants.dart';

class ProgressBarOnboarding extends StatelessWidget {
  final int step;
  final int totalStep;
  const ProgressBarOnboarding({
    super.key,
    required this.step,
    this.totalStep = 10,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: (step + 1) / totalStep),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(AppBorderRadius.infinity),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: AppColors.lightGrey,
            color: AppColors.black,
            minHeight: 12.0,
          ),
        );
      },
    );
  }
}
