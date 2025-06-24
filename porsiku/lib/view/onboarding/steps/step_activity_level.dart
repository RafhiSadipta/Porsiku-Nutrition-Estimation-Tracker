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
        'color': AppColors.error,
      },
      {
        'label': 'Ringan',
        'desc':
            'Olahraga ringan 1–3x/minggu - Jalan kaki, yoga, atau aktivitas ringan',
        'icon': Icons.directions_walk,
        'value': 'ringan',
        'color': AppColors.warning,
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
        'color': AppColors.success,
      },
      {
        'label': 'Sangat Aktif',
        'desc':
            'Aktivitas fisik berat/2x olahraga per hari - Atlet atau pekerja fisik berat',
        'icon': Icons.sports_mma,
        'value': 'sangat_aktif',
        'color': AppColors.success,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: AppSpacing.lg),

          // Title and subtitle
          TitleText(text: 'Seberapa aktif kamu?'),
          const SizedBox(height: AppSpacing.xs),
          SubtitleText(text: 'Pilih tingkat aktivitas harianmu'),
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
                    'Tingkat aktivitas membantu menghitung kebutuhan kalori harianmu',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

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
                (context, index) => const SizedBox(height: AppSpacing.md),
          ),
        ],
      ),
    );
  }
}
