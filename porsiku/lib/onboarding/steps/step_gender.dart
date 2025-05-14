import 'package:flutter/material.dart';

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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Kamu adalah seorang...',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Kami akan menyesuaikan perhitungan berdasarkan gendermu.',
          style: const TextStyle(fontSize: 15, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        GenderOption(
          icon: Icons.male,
          label: 'Laki-laki',
          selected: selectedGender == 'male',
          onTap: () => onGenderSelected('male'),
        ),
        const SizedBox(height: 16),
        GenderOption(
          icon: Icons.female,
          label: 'Perempuan',
          selected: selectedGender == 'female',
          onTap: () => onGenderSelected('female'),
        ),
      ],
    );
  }
}

class GenderOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const GenderOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? Colors.black12 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black87),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
