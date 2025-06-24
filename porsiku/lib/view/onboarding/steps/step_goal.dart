import 'package:flutter/material.dart';
import 'package:porsiku/components/title.dart';
import 'package:porsiku/components/option.dart';
import 'package:porsiku/constants/constants.dart';

class StepGoal extends StatelessWidget {
  final String? selectedGoal;
  final ValueChanged<String> onGoalSelected;

  const StepGoal({super.key, this.selectedGoal, required this.onGoalSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Header Section
          Column(
            children: [
              TitleText(text: 'Apa tujuan utamamu?'),
              SizedBox(height: AppSpacing.xs),
              SubtitleText(
                text:
                    'Pilih tujuan yang paling sesuai dengan\nkeinginanmu saat ini',
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xxl),

          // Options
          Option(
            icon: Icons.trending_down_rounded,
            label: 'Menurunkan Berat Badan',
            description: 'Ingin mencapai berat badan ideal dengan sehat',
            selected: selectedGoal == 'cutting',
            onTap: () => onGoalSelected('cutting'),
            iconColor: Colors.red,
          ),
          SizedBox(height: AppSpacing.md),

          Option(
            icon: Icons.trending_up_rounded,
            label: 'Menaikkan Berat Badan',
            description: 'Ingin menambah massa tubuh dengan nutrisi seimbang',
            selected: selectedGoal == 'bulking',
            onTap: () => onGoalSelected('bulking'),
            iconColor: Colors.green,
          ),
          SizedBox(height: AppSpacing.md),

          Option(
            icon: Icons.balance_rounded,
            label: 'Menjaga Kondisi Tubuh',
            description: 'Ingin mempertahankan berat badan yang sudah ideal',
            selected: selectedGoal == 'maintain',
            onTap: () => onGoalSelected('maintain'),
            iconColor: Colors.blue,
          ),
        ],
      ),
    );
  }
}
