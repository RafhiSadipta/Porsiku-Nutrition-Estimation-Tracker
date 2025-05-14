import 'package:flutter/material.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 24),
        const Text(
          'Seberapa cepat kamu ingin mencapai targetmu?',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Pilih kecepatan penurunan/kenaikan berat badan per minggu.',
          style: TextStyle(fontSize: 15, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
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
    );
  }
}
