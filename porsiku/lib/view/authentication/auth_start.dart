import 'package:flutter/material.dart';
import 'package:porsiku/constants/constants.dart';
import 'package:porsiku/components/title.dart';
import 'package:porsiku/components/primary_button.dart';
import 'package:porsiku/components/secondary_button.dart';
import 'signup.dart';
import 'login.dart';
import '../main/scan.dart';

class AuthStartPage extends StatelessWidget {
  const AuthStartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Cookie Icon
                Container(
                  margin: const EdgeInsets.only(bottom: 40),
                  child: Icon(
                    Icons.cookie,
                    size: AppIcons.xl,
                    color: AppColors.black,
                  ),
                ),
                // Title
                const TitleText(
                  text:
                      'Langkah pertama menuju\nhidup lebih sehat dimulai\ndi sini',
                ),
                const SizedBox(height: 8),
                // Subtitle
                const SubtitleText(text: 'Buat akun baru atau masuk kembali'),
                const SizedBox(height: 40),
                // Continue With Email Button
                PrimaryButton(
                  text: 'Continue With Email',
                  icon: const Icon(
                    Icons.mail_outline,
                    color: AppColors.white,
                    size: AppIcons.md,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SignupPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Continue With Google Button
                SecondaryButton(
                  text: 'Continue With Google',
                  icon: const Icon(
                    Icons.g_mobiledata,
                    color: AppColors.black,
                    size: AppIcons.md,
                  ),
                  onPressed: () {
                    // TODO: Continue with Google
                  },
                  backgroundColor: AppColors.white,
                  textStyle: const TextStyle(
                    fontSize: AppTexts.md,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 16),
                // Log In With Email Button
                SecondaryButton(
                  text: 'Log In With Email',
                  icon: const Icon(
                    Icons.badge_outlined,
                    color: AppColors.black,
                    size: AppIcons.md,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Scan Button
                SecondaryButton(
                  text: 'Scan',
                  icon: const Icon(
                    Icons.badge_outlined,
                    color: AppColors.black,
                    size: AppIcons.md,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const ScanPage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
