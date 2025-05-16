import 'package:flutter/material.dart';
import 'package:porsiku/components/title.dart';

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
          DropdownButton<String>(
            value: selectedPace,
            items:
                paceOptions
                    .map(
                      (pace) => DropdownMenuItem(
                        value: pace,
                        child: Text(pace, style: const TextStyle(fontSize: 18)),
                      ),
                    )
                    .toList(),
            onChanged: (val) {
              if (val != null) onPaceChanged(val);
            },
            isExpanded: false,
            style: const TextStyle(color: Colors.black, fontSize: 18),
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
    );
  }
}
