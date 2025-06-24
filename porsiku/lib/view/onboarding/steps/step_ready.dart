import 'package:flutter/material.dart';
import 'package:porsiku/components/title.dart';
import 'package:porsiku/constants/constants.dart';

class StepReady extends StatelessWidget {
  final VoidCallback onGetStarted;

  const StepReady({super.key, required this.onGetStarted});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Success Message
          TitleText(text: 'Semuanya Sudah Siap! 🎉'),
          SizedBox(height: AppSpacing.xs),

          SubtitleText(
            text:
                'Kami telah menyiapkan rencana nutrisi\npersonal yang sesuai dengan tujuanmu',
          ),
          SizedBox(height: AppSpacing.xl),

          // Summary Card
          Container(
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              boxShadow: AppShadows.card,
            ),
            child: Column(
              children: [
                _BenefitItem(
                  icon: Icons.track_changes_rounded,
                  title: 'Tracking Nutrisi Harian',
                  description: 'Pantau kalori dan nutrisi makananmu',
                ),
                SizedBox(height: AppSpacing.md),

                _BenefitItem(
                  icon: Icons.restaurant_menu_rounded,
                  title: 'Rekomendasi Resep',
                  description: 'Resep sehat sesuai target kalorimu',
                ),
                SizedBox(height: AppSpacing.md),

                _BenefitItem(
                  icon: Icons.analytics_rounded,
                  title: 'Analisis Progress',
                  description: 'Laporan kemajuan yang mendalam',
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.xl),

          // Motivational Quote
          Container(
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              border: Border.all(color: AppColors.primary.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.format_quote_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    '"Perjalanan seribu mil dimulai dari satu langkah"',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Icon(
                  Icons.format_quote_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _BenefitItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                description,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
