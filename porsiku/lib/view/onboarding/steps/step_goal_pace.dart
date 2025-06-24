import 'package:flutter/material.dart';
import 'package:porsiku/components/title.dart';
import 'package:porsiku/components/option.dart';
import 'package:porsiku/constants/constants.dart';

class StepGoalPace extends StatelessWidget {
  final String selectedPace;
  final ValueChanged<String> onPaceChanged;
  const StepGoalPace({
    super.key,
    required this.selectedPace,
    required this.onPaceChanged,
  });

  @override
  Widget build(BuildContext context) {
    final paceOptions = [
      {
        'value': '0.02kg/week',
        'label': '0.02kg/minggu',
        'description': 'Sangat lambat - Perubahan gradual dan berkelanjutan',
        'icon': Icons.speed,
        'color': AppColors.success,
      },
      {
        'value': '0.05kg/week',
        'label': '0.05kg/minggu',
        'description': 'Lambat - Pendekatan yang stabil dan sehat',
        'icon': Icons.trending_up,
        'color': AppColors.success,
      },
      {
        'value': '0.1kg/week',
        'label': '0.1kg/minggu',
        'description': 'Sedang - Keseimbangan antara cepat dan sehat',
        'icon': Icons.directions_run,
        'color': AppColors.primary,
      },
      {
        'value': '0.2kg/week',
        'label': '0.2kg/minggu',
        'description': 'Cepat - Perubahan yang terlihat dalam waktu singkat',
        'icon': Icons.fast_forward,
        'color': AppColors.warning,
      },
      {
        'value': '0.5kg/week',
        'label': '0.5kg/minggu',
        'description': 'Sangat cepat - Memerlukan disiplin tinggi',
        'icon': Icons.rocket_launch,
        'color': AppColors.error,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: AppSpacing.lg),

          // Title and subtitle
          TitleText(text: 'Seberapa cepat kamu ingin mencapai tujuan?'),
          const SizedBox(height: AppSpacing.xs),
          SubtitleText(text: 'Pilih kecepatan perubahan berat badan'),
          const SizedBox(height: AppSpacing.xl),

          // Info card
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Perubahan yang lambat dan stabil lebih mudah dipertahankan dalam jangka panjang',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Pace options
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: paceOptions.length,
            itemBuilder: (context, index) {
              final pace = paceOptions[index];
              return Option(
                icon: pace['icon'] as IconData,
                iconColor: pace['color'] as Color,
                label: pace['label'] as String,
                description: pace['description'] as String,
                selected: selectedPace == pace['value'],
                onTap: () => onPaceChanged(pace['value'] as String),
              );
            },
            separatorBuilder:
                (context, index) => const SizedBox(height: AppSpacing.md),
          ),
        ],
      ),
    );
  }
}
