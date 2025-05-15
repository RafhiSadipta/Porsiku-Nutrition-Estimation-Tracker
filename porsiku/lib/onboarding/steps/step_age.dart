import 'package:flutter/material.dart';

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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Berapa usiamu?',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Usia membantu kami menghitung kebutuhan kalori harianmu.',
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
                      color: selectedAge == age ? Colors.black : Colors.black54,
                    ),
                  ),
                );
              },
              childCount: 81, // 10-90
            ),
          ),
        ),
      ],
    );
  }
}
