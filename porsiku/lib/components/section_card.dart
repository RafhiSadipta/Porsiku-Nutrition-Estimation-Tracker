import 'package:flutter/material.dart';
import 'package:porsiku/constants/constants.dart'; // Assuming this path is correct

class SectionCard extends StatelessWidget {
  final String? title;
  final Widget contentChild;
  final double titleToContentGap;
  final EdgeInsetsGeometry? margin;

  const SectionCard({
    super.key,
    this.title,
    required this.contentChild,
    this.titleToContentGap = 8.0,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: margin,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(
          AppBorderRadius.md,
        ), // e.g., 12.0 or from constants
        boxShadow: AppShadows.card, // Using existing shadow style from your app
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null && title!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: titleToContentGap),
              child: Text(
                title!,
                style: TextStyle(
                  fontSize: AppTexts.md, // Consistent with titles in dashboard
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ),
          contentChild,
        ],
      ),
    );
  }
}
