import 'package:flutter/material.dart';

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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Berapa tinggi badanmu?',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Tinggi badan dibutuhkan untuk menghitung kebutuhan energi tubuhmu.',
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
    );
  }
}
