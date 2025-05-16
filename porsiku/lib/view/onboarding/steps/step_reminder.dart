import 'package:flutter/material.dart';
import 'package:porsiku/components/title.dart';

class StepReminder extends StatelessWidget {
  final List<String> selectedMeals;
  final ValueChanged<String> onMealTap;
  const StepReminder({
    super.key,
    required this.selectedMeals,
    required this.onMealTap,
  });

  @override
  Widget build(BuildContext context) {
    final meals = [
      {
        'label': 'Sarapan Pagi',
        'time': '08.00',
        'icon': Icons.breakfast_dining,
        'value': 'breakfast',
      },
      {
        'label': 'Makan Siang',
        'time': '13.00',
        'icon': Icons.ramen_dining,
        'value': 'lunch',
      },
      {
        'label': 'Makan Malam',
        'time': '19.00',
        'icon': Icons.dinner_dining,
        'value': 'dinner',
      },
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          const Text(
            'Pengingat waktu makan harian',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          TitleText(text: 'Mau diingatkan makan apa saja?'),
          const SizedBox(height: 8),
          SubtitleText(text: 'Pilih waktu makan yang ingin diingatkan'),
          const SizedBox(height: 32),
          ...meals.map(
            (meal) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ReminderMealOption(
                icon: meal['icon'] as IconData,
                label: meal['label'] as String,
                time: meal['time'] as String,
                selected: selectedMeals.contains(meal['value']),
                onTap: () => onMealTap(meal['value'] as String),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReminderMealOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String time;
  final bool selected;
  final VoidCallback onTap;
  const ReminderMealOption({
    required this.icon,
    required this.label,
    required this.time,
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
                  time,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.black26),
          ],
        ),
      ),
    );
  }
}
