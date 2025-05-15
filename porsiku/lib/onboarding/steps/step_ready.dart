import 'package:flutter/material.dart';

class StepReady extends StatelessWidget {
  final VoidCallback onGetStarted;
  const StepReady({super.key, required this.onGetStarted});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        const Text(
          'Kami sudah siap\nmembantumu mencapai tujuan dengan porsi yang tepat. 🥢😋',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: onGetStarted,
            child: const Text(
              "Let's Get Started",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
