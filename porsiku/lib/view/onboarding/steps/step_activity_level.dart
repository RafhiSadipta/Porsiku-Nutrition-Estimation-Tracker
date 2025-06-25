import 'package:flutter/material.dart';
import 'package:porsiku/components/title.dart';
import 'package:porsiku/components/option.dart';
import 'package:porsiku/constants/constants.dart';

class StepActivityLevel extends StatelessWidget {
  final String? selectedLevel;
  final ValueChanged<String> onLevelSelected;
  const StepActivityLevel({
    super.key,
    this.selectedLevel,
    required this.onLevelSelected,
  });

  @override
  Widget build(BuildContext context) {
    final levels = [
      {
        'label': 'Sangat Ringan',
        'desc':
            'Jarang bergerak/olahraga - Pekerjaan duduk, sedikit aktivitas fisik',
        'icon': Icons.self_improvement,
        'value': 'sangat_ringan',
        'color': AppColors.primary,
      },
      {
        'label': 'Ringan',
        'desc':
            'Olahraga ringan 1–3x/minggu - Jalan kaki, yoga, atau aktivitas ringan',
        'icon': Icons.directions_walk,
        'value': 'ringan',
        'color': AppColors.primary,
      },
      {
        'label': 'Sedang',
        'desc': 'Olahraga sedang 3–5x/minggu - Jogging, bersepeda, berenang',
        'icon': Icons.directions_run,
        'value': 'sedang',
        'color': AppColors.primary,
      },
      {
        'label': 'Aktif',
        'desc':
            'Olahraga intens 6–7x/minggu - Latihan kekuatan, HIIT, olahraga kompetitif',
        'icon': Icons.fitness_center,
        'value': 'aktif',
        'color': AppColors.primary,
      },
      {
        'label': 'Sangat Aktif',
        'desc':
            'Aktivitas fisik berat/2x olahraga per hari - Atlet atau pekerja fisik berat',
        'icon': Icons.sports_mma,
        'value': 'sangat_aktif',
        'color': AppColors.primary,
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Title and subtitle
          TitleText(text: 'Seberapa aktif kamu?'),
          SizedBox(height: AppSpacing.xs),
          SubtitleText(text: 'Pilih tingkat aktivitas harianmu'),
          SizedBox(height: AppSpacing.md),

          // Activity level options
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: levels.length,
            itemBuilder: (context, index) {
              final level = levels[index];
              return Option(
                icon: level['icon'] as IconData,
                iconColor: level['color'] as Color,
                label: level['label'] as String,
                description: level['desc'] as String,
                selected: selectedLevel == level['value'],
                onTap: () => onLevelSelected(level['value'] as String),
              );
            },
            separatorBuilder:
                (context, index) => SizedBox(height: AppSpacing.sm),
          ),
        ],
      ),
    );
  }
}
