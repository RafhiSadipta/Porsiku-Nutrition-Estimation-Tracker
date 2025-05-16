import 'package:flutter/material.dart';
import 'package:porsiku/constants/constants.dart';

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color backgroundColor;
  final TextStyle? textStyle;
  final bool isActive;
  final Widget? icon;

  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.padding,
    this.borderRadius = AppBorderRadius.md,
    this.backgroundColor = AppColors.white,
    this.textStyle,
    this.isActive = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveBgColor =
        isActive ? backgroundColor : Colors.grey.shade300;
    final Color effectiveTextColor =
        isActive ? (textStyle?.color ?? AppColors.black) : Colors.grey.shade500;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveBgColor,
          padding: padding ?? const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
          ),
          side: BorderSide(color: AppColors.lightGrey),
        ),
        onPressed: isActive ? onPressed : null,
        child:
            icon == null
                ? Text(
                  text,
                  style: (textStyle ??
                          const TextStyle(
                            fontSize: AppTexts.md,
                            fontWeight: FontWeight.bold,
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
                              const TextStyle(
                                fontSize: AppTexts.md,
                                fontWeight: FontWeight.bold,
                              ))
                          .copyWith(color: effectiveTextColor),
                    ),
                  ],
                ),
      ),
    );
  }
}
