import 'package:flutter/material.dart';

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
        'value': 'very_light',
      },
      {
        'label': 'Ringan',
        'desc': 'Olahraga ringan 1–3x/minggu',
        'icon': Icons.directions_walk,
        'value': 'light',
      },
      {
        'label': 'Sedang',
        'desc': 'Olahraga sedang 3–5x/minggu',
        'icon': Icons.directions_run,
        'value': 'moderate',
      },
      {
        'label': 'Aktif',
        'desc': 'Olahraga intens 6–7x/minggu',
        'icon': Icons.fitness_center,
        'value': 'active',
      },
      {
        'label': 'Sangat Aktif',
        'desc': 'Aktivitas fisik berat/2x olahraga per hari',
        'icon': Icons.sports_mma,
        'value': 'very_active',
      },
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 24),
        const Text(
          'Seberapa aktif kamu sehari-hari?',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Aktivitas fisik memengaruhi kebutuhan kalori harianmu.',
          style: TextStyle(fontSize: 15, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ...levels.map(
          (level) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ActivityLevelOption(
              icon: level['icon'] as IconData,
              label: level['label'] as String,
              desc: level['desc'] as String,
              selected: selectedLevel == level['value'],
              onTap: () => onLevelSelected(level['value'] as String),
            ),
          ),
        ),
      ],
    );
  }
}

class ActivityLevelOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String desc;
  final bool selected;
  final VoidCallback onTap;
  const ActivityLevelOption({
    required this.icon,
    required this.label,
    required this.desc,
    required this.selected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? Colors.black12 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black87),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
