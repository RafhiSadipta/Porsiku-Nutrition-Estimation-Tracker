import 'package:flutter/material.dart';
import 'package:porsiku/components/title.dart';
import 'package:porsiku/constants/constants.dart';

class StepIntro extends StatelessWidget {
  const StepIntro({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Welcome Message
          TitleText(text: 'Selamat Datang di PorsiKu!'),
          SizedBox(height: AppSpacing.md),

          SubtitleText(
            text:
                'Mari kenali tubuh dan tujuanmu.\nKami akan membantu mencapai target dengan optimal.',
          ),
          SizedBox(height: AppSpacing.xl),

          // Feature highlights
          Container(
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              boxShadow: AppShadows.card,
            ),
            child: Column(
              children: [
                _FeatureItem(
                  icon: Icons.track_changes_rounded,
                  title: 'Tracking Nutrisi',
                  description: 'Pantau asupan harian dengan mudah',
                ),
                SizedBox(height: AppSpacing.md),
                _FeatureItem(
                  icon: Icons.restaurant_rounded,
                  title: 'Rekomendasi Resep',
                  description: 'Resep sehat sesuai target kalori',
                ),
                SizedBox(height: AppSpacing.md),
                _FeatureItem(
                  icon: Icons.analytics_rounded,
                  title: 'Analisis Personal',
                  description: 'Laporan progress yang detail',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
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
