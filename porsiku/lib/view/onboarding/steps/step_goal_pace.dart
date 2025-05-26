import 'package:flutter/material.dart';
import 'package:porsiku/components/title.dart';
import 'package:porsiku/components/option.dart'; // Import Option component

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
      '0.02kg/week',
      '0.05kg/week',
      '0.1kg/week',
      '0.2kg/week',
      '0.5kg/week',
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 32),
          TitleText(text: 'Seberapa cepat kamu ingin mencapai tujuan?'),
          const SizedBox(height: 4),
          SubtitleText(text: 'Pilih kecepatan perubahan berat badan'),
          const SizedBox(height: 32),
          // Replace DropdownButton with a Column of Option widgets
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: paceOptions.length,
            itemBuilder: (context, index) {
              final pace = paceOptions[index];
              return Option(
                icon: Icons.speed, // Using a generic icon
                label: pace,
                selected: selectedPace == pace,
                onTap: () => onPaceChanged(pace),
              );
            },
            separatorBuilder:
                (context, index) =>
                    const SizedBox(height: 12), // Space between options
          ),
        ],
      ),
    );
  }
}
