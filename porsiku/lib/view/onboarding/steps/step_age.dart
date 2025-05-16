import 'package:flutter/material.dart';
import 'package:porsiku/components/title.dart';

class StepAge extends StatelessWidget {
  final int selectedAge;
  final ValueChanged<int> onAgeChanged;
  const StepAge({
    super.key,
    required this.selectedAge,
    required this.onAgeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TitleText(text: 'Berapa usiamu?'),
          const SizedBox(height: 4),
          SubtitleText(text: 'Masukkan usia kamu saat ini'),
          const SizedBox(height: 32),
          SizedBox(
            height: 180,
            child: ListWheelScrollView.useDelegate(
              itemExtent: 48,
              diameterRatio: 1.2,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: onAgeChanged,
              childDelegate: ListWheelChildBuilderDelegate(
                builder: (context, index) {
                  final age = 10 + index;
                  return Center(
                    child: Text(
                      age.toString(),
                      style: TextStyle(
                        fontSize: selectedAge == age ? 28 : 20,
                        fontWeight:
                            selectedAge == age
                                ? FontWeight.bold
                                : FontWeight.normal,
                        color:
                            selectedAge == age ? Colors.black : Colors.black54,
                      ),
                    ),
                  );
                },
                childCount: 81, // 10-90
              ),
            ),
          ),
        ],
      ),
    );
  }
}
