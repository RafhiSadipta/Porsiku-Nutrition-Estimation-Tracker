import 'package:flutter/material.dart';
import 'package:porsiku/components/title.dart';

class StepHeight extends StatelessWidget {
  final int selectedHeight;
  final ValueChanged<int> onHeightChanged;
  const StepHeight({
    super.key,
    required this.selectedHeight,
    required this.onHeightChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TitleText(text: 'Tinggi badanmu?'),
          const SizedBox(height: 4),
          SubtitleText(text: 'Masukkan tinggi badan kamu (cm)'),
          const SizedBox(height: 32),
          SizedBox(
            height: 180,
            child: ListWheelScrollView.useDelegate(
              itemExtent: 48,
              diameterRatio: 1.2,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: onHeightChanged,
              childDelegate: ListWheelChildBuilderDelegate(
                builder: (context, index) {
                  final height = 100 + index;
                  return Center(
                    child: Text(
                      '$height cm',
                      style: TextStyle(
                        fontSize: selectedHeight == height ? 28 : 20,
                        fontWeight:
                            selectedHeight == height
                                ? FontWeight.bold
                                : FontWeight.normal,
                        color:
                            selectedHeight == height
                                ? Colors.black
                                : Colors.black54,
                      ),
                    ),
                  );
                },
                childCount: 101, // 100-200
              ),
            ),
          ),
        ],
      ),
    );
  }
}
