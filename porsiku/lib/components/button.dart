import 'package:flutter/material.dart';
import 'package:porsiku/constants/constants.dart';

enum ButtonVariant { primary, secondary }

class Button extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final TextStyle? textStyle;
  final bool isActive;
  final Widget? icon;
  final Color? customBackgroundColor; // Untuk override jika diperlukan
  final Color? customTextColor; // Untuk override jika diperlukan

  const Button({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.padding,
    this.borderRadius = AppBorderRadius.md,
    this.textStyle,
    this.isActive = true,
    this.icon,
    this.customBackgroundColor,
    this.customTextColor,
  });
  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    BorderSide? borderSide;
    List<BoxShadow>? boxShadow;

    switch (variant) {
      case ButtonVariant.secondary:
        bgColor = customBackgroundColor ?? AppColors.white;
        textColor = customTextColor ?? AppColors.primary;
        borderSide = BorderSide(
          color: isActive ? AppColors.primary.withOpacity(0.3) : AppColors.grey,
          width: 1.5,
        );
        boxShadow = AppShadows.card;
        break;
      case ButtonVariant.primary:
        bgColor = customBackgroundColor ?? AppColors.primary;
        textColor = customTextColor ?? AppColors.white;
        borderSide = null;
        boxShadow = AppShadows.primaryButton;
        break;
    }

    final Color effectiveBgColor = isActive ? bgColor : AppColors.lightGrey;
    final Color effectiveTextColor =
        isActive ? textColor : AppColors.textTertiary;
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: isActive ? boxShadow : null,
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: effectiveBgColor,
            padding: padding ?? EdgeInsets.symmetric(vertical: AppSpacing.md),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            side: borderSide,
            elevation:
                0, // Remove default elevation as we're using custom shadows
            shadowColor: Colors.transparent,
          ),
          onPressed: isActive ? onPressed : null,
          child:
              icon == null
                  ? Text(
                    text,
                    style: (textStyle ?? AppTextStyles.buttonLarge).copyWith(
                      color: effectiveTextColor,
                    ),
                  )
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      icon!,
                      SizedBox(width: AppSpacing.sm),
                      Text(
                        text,
                        style: (textStyle ?? AppTextStyles.buttonLarge)
                            .copyWith(color: effectiveTextColor),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}
