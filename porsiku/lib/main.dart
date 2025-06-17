import 'package:flutter/material.dart';
// import 'package:porsiku/view/main/dashboard.dart';
import 'package:porsiku/view/onboarding/landing.dart';

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
      home: const LandingPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
