import 'package:flutter/material.dart';
import 'package:porsiku/components/title.dart';

class StepReady extends StatelessWidget {
  final VoidCallback onGetStarted;
  const StepReady({super.key, required this.onGetStarted});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          TitleText(
            text:
                'Kami sudah siap\nmembantumu mencapai tujuan dengan porsi yang tepat. 🥢😋',
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
