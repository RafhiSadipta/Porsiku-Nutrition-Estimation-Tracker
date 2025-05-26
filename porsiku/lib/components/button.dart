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

    switch (variant) {
      case ButtonVariant.secondary:
        bgColor = customBackgroundColor ?? AppColors.white;
        textColor = customTextColor ?? AppColors.black;
        borderSide = BorderSide(
          color: isActive ? AppColors.lightGrey : AppColors.grey,
        );
        break;
      case ButtonVariant.primary:
      default:
        bgColor = customBackgroundColor ?? AppColors.black;
        textColor = customTextColor ?? AppColors.white;
        borderSide = null;
        break;
    }

    final Color effectiveBgColor = isActive ? bgColor : Colors.grey.shade300;
    final Color effectiveTextColor =
        isActive ? textColor : Colors.grey.shade500;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveBgColor,
          padding: padding ?? const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          side: borderSide,
          elevation:
              AppElevations
                  .sm, // Default elevation, bisa disesuaikan per variant jika perlu
          shadowColor: AppShadows.card.first.color.withOpacity(
            0.5,
          ), // Ambil dari AppShadows
        ),
        onPressed: isActive ? onPressed : null,
        child:
            icon == null
                ? Text(
                  text,
                  style: (textStyle ??
                          TextStyle(
                            fontSize: AppTexts.md,
                            fontWeight: FontWeight.bold,
                            fontFamily:
                                'Manrope', // Pastikan font family konsisten
                          ))
                      .copyWith(color: effectiveTextColor),
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    icon!,
                    const SizedBox(width: 8),
                    Text(
                      text,
                      style: (textStyle ??
                              TextStyle(
                                fontSize: AppTexts.md,
                                fontWeight: FontWeight.bold,
                                fontFamily:
                                    'Manrope', // Pastikan font family konsisten
                              ))
                          .copyWith(color: effectiveTextColor),
                    ),
                  ],
                ),
      ),
    );
  }
}
