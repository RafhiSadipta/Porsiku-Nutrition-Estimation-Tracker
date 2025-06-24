import 'package:flutter/material.dart';
import 'package:porsiku/components/title.dart';
import 'package:porsiku/components/option.dart';
import 'package:porsiku/constants/constants.dart';

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
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Header
          Column(
            children: [
              TitleText(text: 'Apa jenis kelaminmu?'),
              SizedBox(height: AppSpacing.sm),
              SubtitleText(
                text:
                    'Informasi ini membantu kami menghitung\nkebutuhan kalori yang lebih akurat',
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xxl),

          // Gender Options
          Option(
            icon: Icons.male_rounded,
            label: 'Laki-laki',
            description: 'Kebutuhan kalori umumnya lebih tinggi',
            selected: selectedGender == 'male',
            onTap: () => onGenderSelected('male'),
            iconColor: Colors.blue,
          ),
          SizedBox(height: AppSpacing.lg),

          Option(
            icon: Icons.female_rounded,
            label: 'Perempuan',
            description: 'Kebutuhan kalori disesuaikan dengan metabolisme',
            selected: selectedGender == 'female',
            onTap: () => onGenderSelected('female'),
            iconColor: Colors.pink,
          ),
        ],
      ),
    );
  }
}
