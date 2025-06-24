import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:porsiku/constants/constants.dart';
import 'package:porsiku/view/authentication/login.dart';
import 'form.dart';
import '../../components/button.dart';
import '../../components/title.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    _slideController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
  }

  void _startAnimations() {
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // porsiku logo menggunakan asset
                Image.asset('assets/icon/icon.png', width: 120, height: 120)
                    .animate()
                    .fadeIn(delay: 200.ms)
                    .scale(begin: const Offset(0.8, 0.8)),

                SizedBox(height: AppSpacing.xxxl),

                // Title
                TitleText(
                  text: 'Selamat datang di PorsiKu',
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),

                SizedBox(height: AppSpacing.sm),

                // Subtitle
                SubtitleText(
                  text: 'Foto makananmu, ketahui gizi harianmu',
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3),

                SizedBox(height: AppSpacing.xxxl),

                // Let's Get Started Button
                Button(
                  text: "Let's Get Started",
                  variant: ButtonVariant.primary,
                  icon: Icon(
                    Icons.rocket_launch_rounded,
                    size: AppIcons.md,
                    color: AppColors.white,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const OnboardingFormPage(),
                      ),
                    );
                  },
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3),

                SizedBox(
                  height: AppSpacing.lg,
                ), // I already have an account Button
                Button(
                  text: 'I already have an account',
                  variant: ButtonVariant.secondary,
                  icon: Icon(
                    Icons.person_rounded,
                    size: AppIcons.md,
                    color: AppColors.primary,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
