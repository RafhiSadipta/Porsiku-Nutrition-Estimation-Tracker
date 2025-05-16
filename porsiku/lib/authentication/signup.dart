import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'login.dart';

class SignupPage extends StatefulWidget {
  final String? gender;
  final int age;
  final int height;
  final int weight;
  final String? goal;
  final int targetWeight;
  final String pace;
  final String? activityLevel;
  final List<String> reminders;

  const SignupPage({
    super.key,
    required this.gender,
    required this.age,
    required this.height,
    required this.weight,
    required this.goal,
    required this.targetWeight,
    required this.pace,
    required this.activityLevel,
    required this.reminders,
  });

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> register() async {
    if (usernameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      showDialog(
        context: context,
        builder:
            (_) => const AlertDialog(
              title: Text('Form tidak lengkap'),
              content: Text('Harap isi semua data yang diperlukan.'),
            ),
      );
      return;
    }

    double targetMingguan;
    switch (widget.pace) {
      case 'slow':
        targetMingguan = 0.25;
        break;
      case 'fast':
        targetMingguan = 1.0;
        break;
      default:
        targetMingguan = 0.5; // default 'moderate'
    }

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': usernameController.text,
          'email': emailController.text,
          'password': passwordController.text,
          'gender': widget.gender,
          'usia': widget.age,
          'tinggi_badan': widget.height,
          'berat_badan': widget.weight,
          'program': widget.goal,
          'target_akhir': widget.targetWeight,
          'target_mingguan': targetMingguan,
          'aktivitas': widget.activityLevel,
        }),
      );

      if (response.statusCode == 201) {
        if (!mounted) return;
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
      } else {
        final body = jsonDecode(response.body);
        final msg = body['error'] ?? 'Gagal mendaftar.';
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text('Error'),
                content: Text(msg),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('Kesalahan'),
              content: Text('Terjadi kesalahan saat menghubungi server: $e'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 80),
                const Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Daftar untuk mulai menggunakan PorsiKu.',
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: usernameController,
                  decoration: _inputDecoration('Username'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: _inputDecoration('Email'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: _inputDecoration('Password'),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: register,
                    child: const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  },
                  child: const Text(
                    'Already have an account? Login',
                    style: TextStyle(
                      color: Colors.black54,
                      decoration: TextDecoration.underline,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.black12),
      ),
    );
  }
}
