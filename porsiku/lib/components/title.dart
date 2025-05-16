import 'package:flutter/material.dart';
import 'package:porsiku/constants/constants.dart';

class TitleText extends StatelessWidget {
  final String text;
  const TitleText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: AppTexts.xl,
        fontWeight: FontWeight.bold,
        color: AppColors.black,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class SubtitleText extends StatelessWidget {
  final String text;
  const SubtitleText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: AppTexts.md,
        fontWeight: FontWeight.w500,
        color: AppColors.grey,
      ),
      textAlign: TextAlign.center,
    );
  }
}
