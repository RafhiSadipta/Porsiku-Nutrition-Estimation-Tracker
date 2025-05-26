import 'package:flutter/material.dart';
import 'package:porsiku/components/title.dart';
import 'package:porsiku/components/option.dart'; // Import Option

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
        'desc': 'Jarang bergerak/olahraga',
        'icon': Icons.self_improvement,
        'value': 'sangat_ringan',
      },
      {
        'label': 'Ringan',
        'desc': 'Olahraga ringan 1–3x/minggu',
        'icon': Icons.directions_walk,
        'value': 'ringan',
      },
      {
        'label': 'Sedang',
        'desc': 'Olahraga sedang 3–5x/minggu',
        'icon': Icons.directions_run,
        'value': 'sedang',
      },
      {
        'label': 'Aktif',
        'desc': 'Olahraga intens 6–7x/minggu',
        'icon': Icons.fitness_center,
        'value': 'aktif',
      },
      {
        'label': 'Sangat Aktif',
        'desc': 'Aktivitas fisik berat/2x olahraga per hari',
        'icon': Icons.sports_mma,
        'value': 'sangat_aktif',
      },
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 32),
          TitleText(text: 'Seberapa aktif kamu?'),
          const SizedBox(height: 4),
          SubtitleText(text: 'Pilih tingkat aktivitas harianmu'),
          const SizedBox(height: 32),
          ...levels.map(
            (level) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Option(
                // Use Option
                icon: level['icon'] as IconData?,
                label: level['label'] as String,
                description: level['desc'] as String?,
                selected: selectedLevel == level['value'],
                onTap: () => onLevelSelected(level['value'] as String),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ActivityLevelOption class can be removed from this file now
