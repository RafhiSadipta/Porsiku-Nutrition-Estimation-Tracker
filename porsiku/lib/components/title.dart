import 'package:flutter/material.dart';
import 'package:porsiku/constants/constants.dart';

class TitleText extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final Color? color;

  const TitleText({super.key, required this.text, this.textAlign, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.h3.copyWith(color: color ?? AppColors.textPrimary),
      textAlign: textAlign ?? TextAlign.center,
    );
  }
}

class SubtitleText extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final Color? color;

  const SubtitleText({
    super.key,
    required this.text,
    this.textAlign,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.bodyMedium.copyWith(
        color: color ?? AppColors.grey,
        height: 1.4,
      ),
      textAlign: textAlign ?? TextAlign.center,
    );
  }
}
