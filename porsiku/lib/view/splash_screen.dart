import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:porsiku/components/session_manager.dart';
import 'package:porsiku/constants/constants.dart';
import 'package:porsiku/view/authentication/login.dart';
import 'package:porsiku/view/main/dashboard.dart';
import 'package:porsiku/view/onboarding/landing.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Start session check and navigation
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize session manager
    await SessionManager.initialize();

    // Wait minimum splash duration for better UX
    await Future.delayed(const Duration(seconds: 2));

    // Check session and navigate
    if (mounted) {
      await _checkSessionAndNavigate();
    }
  }

  Future<void> _checkSessionAndNavigate() async {
    try {
      final navigationTarget = await SessionManager.handleAppStart(context);

      if (mounted) {
        switch (navigationTarget) {
          case NavigationTarget.dashboard:
            // User has valid session, go to dashboard
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardPage()),
            );
            break;
          case NavigationTarget.login:
            // User has signed up before but needs to login
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
            break;
          case NavigationTarget.landing:
            // New user, show landing page for onboarding
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LandingPage()),
            );
            break;
        }
      }
    } catch (e) {
      print('DEBUG: Error during session check: $e');

      // On error, go to landing page for safety
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LandingPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Image.asset('assets/icon/icon.png', width: 120, height: 120)
            .animate(onPlay: (controller) => controller.repeat())
            .scale(
              duration: 2000.ms,
              begin: const Offset(0.8, 0.8),
              end: const Offset(1.1, 1.1),
              curve: Curves.easeInOut,
            )
            .then()
            .scale(
              duration: 2000.ms,
              begin: const Offset(1.1, 1.1),
              end: const Offset(0.8, 0.8),
              curve: Curves.easeInOut,
            ),
      ),
    );
  }
}
