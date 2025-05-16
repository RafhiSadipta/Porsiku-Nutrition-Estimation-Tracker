import 'package:flutter/material.dart';
import 'package:porsiku/constants/constants.dart';

class BackButtonCustom extends StatelessWidget {
  final VoidCallback? onPressed;
  const BackButtonCustom({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        boxShadow: AppShadows.smButton,
      ),
      child: IconButton(
        icon: const Icon(Icons.chevron_left, size: 32),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        splashRadius: 20,
      ),
    );
  }
}
