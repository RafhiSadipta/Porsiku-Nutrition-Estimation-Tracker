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
        'color': AppColors.primary,
      },
      {
        'value': '0.05kg/week',
        'label': '0.05kg/minggu',
        'description': 'Lambat - Pendekatan yang stabil dan sehat',
        'icon': Icons.trending_up,
        'color': AppColors.primary,
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
        'color': AppColors.primary,
      },
      {
        'value': '0.5kg/week',
        'label': '0.5kg/minggu',
        'description': 'Sangat cepat - Memerlukan disiplin tinggi',
        'icon': Icons.rocket_launch,
        'color': AppColors.primary,
      },
    ];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          // Title and subtitle
          TitleText(text: 'Seberapa cepat kamu ingin mencapai tujuan?'),
          SizedBox(height: AppSpacing.xs),
          SubtitleText(text: 'Pilih kecepatan perubahan berat badan'),
          SizedBox(height: AppSpacing.md),

          // Pace options in scrollable list
          Expanded(
            child: ListView.separated(
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
                  (context, index) => SizedBox(height: AppSpacing.sm),
            ),
          ),
        ],
      ),
    );
  }
}
