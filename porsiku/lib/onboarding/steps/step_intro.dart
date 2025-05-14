import 'package:flutter/material.dart';

class StepIntro extends StatelessWidget {
  const StepIntro({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 80),
        Text(
          'Pertama-tama, mari kenali tubuhmu dan tujuanmu.',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'kami akan membantumu mencapai tujuan dengan optimal',
          style: const TextStyle(fontSize: 15, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
