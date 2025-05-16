import 'package:flutter/material.dart';
import 'package:porsiku/components/title.dart';

class StepIntro extends StatelessWidget {
  const StepIntro({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 80),
              TitleText(
                text: 'Pertama-tama, mari kenali tubuhmu dan tujuanmu.',
              ),
              const SizedBox(height: 12),
              SubtitleText(
                text: 'kami akan membantumu mencapai tujuan dengan optimal',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
