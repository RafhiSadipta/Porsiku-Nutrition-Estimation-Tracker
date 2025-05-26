import 'package:flutter/material.dart';
import 'package:porsiku/components/title.dart';
import 'package:porsiku/components/option.dart'; // Import Option

class StepGender extends StatelessWidget {
  final String? selectedGender;
  final ValueChanged<String> onGenderSelected;
  const StepGender({
    super.key,
    this.selectedGender,
    required this.onGenderSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TitleText(text: 'Apa jenis kelaminmu?'),
          const SizedBox(height: 4),
          SubtitleText(
            text: 'Pilih jenis kelamin yang sesuai dengan identitasmu',
          ),
          const SizedBox(height: 32),
          Option(
            // Use Option
            icon: Icons.male,
            label: 'Laki-laki',
            selected: selectedGender == 'L',
            onTap: () => onGenderSelected('L'),
          ),
          const SizedBox(height: 16),
          Option(
            // Use Option
            icon: Icons.female,
            label: 'Perempuan',
            selected: selectedGender == 'P',
            onTap: () => onGenderSelected('P'),
          ),
        ],
      ),
    );
  }
}
