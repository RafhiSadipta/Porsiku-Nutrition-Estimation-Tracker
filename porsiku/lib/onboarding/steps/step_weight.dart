import 'package:flutter/material.dart';

class StepWeight extends StatelessWidget {
  final int selectedWeight;
  final ValueChanged<int> onWeightChanged;
  const StepWeight({
    super.key,
    required this.selectedWeight,
    required this.onWeightChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Berapa berat badanmu sekarang?',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Informasi ini akan menjadi dasar dari progress tracking-mu.',
          style: const TextStyle(fontSize: 15, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        SizedBox(
          height: 180,
          child: ListWheelScrollView.useDelegate(
            itemExtent: 48,
            diameterRatio: 1.2,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: onWeightChanged,
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) {
                final weight = 30 + index;
                return Center(
                  child: Text(
                    '$weight kg',
                    style: TextStyle(
                      fontSize: selectedWeight == weight ? 28 : 20,
                      fontWeight:
                          selectedWeight == weight
                              ? FontWeight.bold
                              : FontWeight.normal,
                      color:
                          selectedWeight == weight
                              ? Colors.black
                              : Colors.black54,
                    ),
                  ),
                );
              },
              childCount: 121, // 30-150
            ),
          ),
        ),
      ],
    );
  }
}
