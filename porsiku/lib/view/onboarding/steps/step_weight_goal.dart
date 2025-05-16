import 'package:flutter/material.dart';
import 'package:porsiku/components/title.dart';

class StepWeightGoal extends StatelessWidget {
  final int currentWeight;
  final int targetWeight;
  final ValueChanged<int> onTargetWeightChanged;
  const StepWeightGoal({
    super.key,
    required this.currentWeight,
    required this.targetWeight,
    required this.onTargetWeightChanged,
  });

  @override
  Widget build(BuildContext context) {
    final diff = targetWeight - currentWeight;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TitleText(text: 'Target berat badanmu?'),
          const SizedBox(height: 4),
          SubtitleText(text: 'Masukkan berat badan yang ingin dicapai (kg)'),
          const SizedBox(height: 32),
          SizedBox(
            height: 180,
            child: ListWheelScrollView.useDelegate(
              itemExtent: 48,
              diameterRatio: 1.2,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: onTargetWeightChanged,
              childDelegate: ListWheelChildBuilderDelegate(
                builder: (context, index) {
                  final weight = 30 + index;
                  return Center(
                    child: Text(
                      '$weight kg',
                      style: TextStyle(
                        fontSize: targetWeight == weight ? 28 : 20,
                        fontWeight:
                            targetWeight == weight
                                ? FontWeight.bold
                                : FontWeight.normal,
                        color:
                            targetWeight == weight
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
          const SizedBox(height: 8),
          Text(
            diff == 0
                ? 'Berat badanmu sudah ideal!'
                : 'Berat badanmu akan ${diff > 0 ? '(naik)' : '(turun)'} ${diff.abs()}kg',
            style: TextStyle(
              fontSize: 16,
              color: diff == 0 ? Colors.grey : Colors.green,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
