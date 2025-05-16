import 'package:flutter/material.dart';
import 'package:porsiku/components/title.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TitleText(text: 'Berat badanmu?'),
          const SizedBox(height: 4),
          SubtitleText(text: 'Masukkan berat badan kamu saat ini (kg)'),
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
      ),
    );
  }
}
