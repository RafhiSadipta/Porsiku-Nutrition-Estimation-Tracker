import 'package:flutter/material.dart';
import 'package:porsiku/view/splash_screen.dart';
import 'package:porsiku/view/onboarding/landing.dart';
import 'package:porsiku/view/authentication/login.dart';
import 'package:porsiku/view/main/dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PorsiKu',
      theme: ThemeData(
        fontFamily: 'Manrope',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const SplashScreen(),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/landing': (context) => const LandingPage(),
        '/login': (context) => const LoginPage(),
        '/dashboard': (context) => const DashboardPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
