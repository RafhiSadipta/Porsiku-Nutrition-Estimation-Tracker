import 'package:flutter/material.dart';
import 'package:porsiku/components/title.dart';
import 'package:porsiku/components/option.dart'; // Import Option

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
          Option(
            // Use Option
            icon: Icons.local_fire_department,
            label: 'Menurunkan berat badan',
            selected: selectedGoal == 'cutting',
            onTap: () => onGoalSelected('cutting'),
          ),
          const SizedBox(height: 16),
          Option(
            // Use Option
            icon: Icons.fitness_center,
            label: 'Menaikkan berat badan',
            selected: selectedGoal == 'bulking',
            onTap: () => onGoalSelected('bulking'),
          ),
          const SizedBox(height: 16),
          Option(
            // Use Option
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
