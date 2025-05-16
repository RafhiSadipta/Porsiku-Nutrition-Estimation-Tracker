import 'package:flutter/material.dart';
import 'package:porsiku/constants/constants.dart';
import 'package:porsiku/view/authentication/login.dart';
import 'form.dart';
import '../../components/primary_button.dart';
import '../../components/secondary_button.dart';
import '../../components/title.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Cookie Icon
                Container(
                  margin: const EdgeInsets.only(bottom: 32),
                  child: Icon(Icons.cookie, size: 120, color: AppColors.black),
                ),
                // Title
                TitleText(text: 'Selamat datang di PorsiKu'),
                const SizedBox(height: 8),
                // Subtitle
                SubtitleText(text: 'Foto makananmu, ketahui gizi harianmu'),
                const SizedBox(height: 32),
                // Let's Get Started Button
                PrimaryButton(
                  text: "Let's Get Started",
                  icon: const Icon(
                    Icons.rocket_launch_rounded,
                    size: 24,
                    color: AppColors.white,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const OnboardingFormPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                // I already have an account Button
                SecondaryButton(
                  text: 'I already have an account',
                  icon: const Icon(
                    Icons.person_rounded,
                    size: 24,
                    color: AppColors.black,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
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
