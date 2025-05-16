import 'package:flutter/material.dart';
import 'package:porsiku/components/title.dart';

class StepGoal extends StatelessWidget {
  final String? selectedGoal;
  final ValueChanged<String> onGoalSelected;
  const StepGoal({super.key, this.selectedGoal, required this.onGoalSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          TitleText(text: 'Apa tujuan utamamu?'),
          const SizedBox(height: 8),
          SubtitleText(text: 'Apa yang memotivasimu menggunakan PorsiKu?'),
          const SizedBox(height: 32),
          GoalOption(
            icon: Icons.local_fire_department,
            label: 'Menurunkan berat badan',
            selected: selectedGoal == 'cutting',
            onTap: () => onGoalSelected('cutting'),
          ),
          const SizedBox(height: 16),
          GoalOption(
            icon: Icons.fitness_center,
            label: 'Menaikkan berat badan',
            selected: selectedGoal == 'bulking',
            onTap: () => onGoalSelected('bulking'),
          ),
          const SizedBox(height: 16),
          GoalOption(
            icon: Icons.emoji_emotions,
            label: 'Menjaga kondisi tubuh',
            selected: selectedGoal == 'maintain',
            onTap: () => onGoalSelected('maintain'),
          ),
        ],
      ),
    );
  }
}

class GoalOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const GoalOption({
    required this.icon,
    required this.label,
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
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
