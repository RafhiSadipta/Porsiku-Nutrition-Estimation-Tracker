import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:porsiku/constants/constants.dart';

class PremiumDialog extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final String primaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final bool isError;

  const PremiumDialog({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.primaryButtonText,
    this.onPrimaryPressed,
    this.isError = false,
  });

  static Future<void> showNoFoodDetected(
    BuildContext context, {
    required String retryText,
    VoidCallback? onRetry,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => PremiumDialog(
            title: 'Tidak ada makanan terdeteksi',
            icon: Icons.search_off_rounded,
            iconColor: AppColors.warning,
            primaryButtonText: retryText,
            isError: true,
            onPrimaryPressed: () {
              Navigator.of(context).pop();
              if (onRetry != null) onRetry();
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
            margin: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppBorderRadius.xl),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: AppColors.black.withOpacity(0.05),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with icon
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color:
                        isError
                            ? AppColors.warning.withOpacity(0.05)
                            : AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppBorderRadius.xl),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Animated icon container
                      Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  iconColor.withOpacity(0.2),
                                  iconColor.withOpacity(0.1),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: iconColor.withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Icon(icon, size: 40, color: iconColor),
                          )
                          .animate()
                          .scale(duration: 600.ms, curve: Curves.elasticOut)
                          .then()
                          .shake(duration: 300.ms, hz: 2),

                      SizedBox(height: AppSpacing.lg),

                      // Title
                      Text(
                        title,
                        style: AppTextStyles.h3.copyWith(
                          fontWeight: AppTexts.bold,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    children: [
                      // Action button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            if (onPrimaryPressed != null) {
                              onPrimaryPressed!();
                            } else {
                              Navigator.of(context).pop();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isError
                                    ? AppColors.warning
                                    : AppColors.primary,
                            foregroundColor: AppColors.white,
                            elevation: 4,
                            shadowColor: (isError
                                    ? AppColors.warning
                                    : AppColors.primary)
                                .withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppBorderRadius.lg,
                              ),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                              horizontal: AppSpacing.lg,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isError
                                    ? Icons.refresh_rounded
                                    : Icons.check_rounded,
                                size: AppIcons.sm,
                                color: AppColors.white,
                              ),
                              SizedBox(width: AppSpacing.sm),
                              Text(
                                primaryButtonText,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.white,
                                  fontWeight: AppTexts.semiBold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.5),
                    ],
                  ),
                ),
              ],
            ),
          )
          .animate()
          .scale(
            duration: 300.ms,
            curve: Curves.easeOutBack,
            begin: const Offset(0.8, 0.8),
          )
          .fadeIn(duration: 200.ms),
    );
  }
}

// Helper function for quick success dialog
class SuccessDialog extends StatelessWidget {
  final String title;
  final String buttonText;
  final VoidCallback? onPressed;

  const SuccessDialog({
    super.key,
    required this.title,
    this.buttonText = 'OK',
    this.onPressed,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) {
    return showDialog(
      context: context,
      builder:
          (context) => SuccessDialog(
            title: title,
            buttonText: buttonText,
            onPressed: onPressed,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PremiumDialog(
      title: title,
      icon: Icons.check_circle_rounded,
      iconColor: AppColors.success,
      primaryButtonText: buttonText,
      onPrimaryPressed: onPressed ?? () => Navigator.of(context).pop(),
    );
  }
}
