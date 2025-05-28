import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:porsiku/components/title.dart';
import 'package:porsiku/constants/constants.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'signup.dart';
import 'package:porsiku/components/input_field.dart';
import 'package:porsiku/components/button.dart'; // Updated import
import 'package:porsiku/view/main/dashboard.dart'; // Import DashboardPage

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email dan password harus diisi")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse('http://192.168.0.103:8080/api/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token']?.toString() ?? '';
        final userId = data['user_id']?.toString() ?? '';

        if (token.isEmpty || userId.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Login gagal: Data user_id/token tidak ditemukan."),
            ),
          );
          setState(() {
            isLoading = false;
          });
          return;
        }

        // Simpan token dan user_id ke SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('user_id', userId); // pastikan key: user_id

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Login berhasil!")));

        // TODO: Simpan token ke SharedPreferences

        // Navigasi ke halaman utama setelah login berhasil
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardPage()),
        );

        print("Login sukses. Token: $token, UserID: $userId");
      } else {
        String errorMsg = "Login gagal";
        try {
          final error = jsonDecode(response.body)['error'];
          if (error != null) errorMsg = error.toString();
        } catch (_) {}
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMsg)));
      }
    } catch (e) {
      // Tampilkan error detail ke user (bukan hanya di terminal)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal terhubung ke server: ${e.toString()}")),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 80),
                  const TitleText(text: 'Log In'),
                  const SizedBox(height: 8),
                  const SubtitleText(
                    text:
                        'Masuk untuk melanjutkan perjalananmu\nbersama PorsiKu.',
                  ),
                  const SizedBox(height: 32),

                  // Email InputField with controller
                  InputField(
                    controller: emailController,
                    hintText: 'Email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  // Password InputField with controller
                  InputField(
                    controller: passwordController,
                    hintText: 'Password',
                    isPassword: true,
                  ),
                  const SizedBox(height: 8),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        // TODO: Navigate to forget password
                      },
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: const Text(
                        'Lupa password?',
                        style: TextStyle(
                          color: AppColors.grey,
                          decoration: TextDecoration.underline,
                          fontSize: AppTexts.md,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  SizedBox(
                    width: double.infinity,
                    child: Button(
                      // Replaced PrimaryButton
                      text: isLoading ? 'Loading...' : 'Log In',
                      variant: ButtonVariant.primary, // Added variant
                      onPressed: isLoading ? null : login,
                      isActive: !isLoading, // Added isActive based on isLoading
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SignupPage(),
                        ),
                      );
                    },
                    child: const Text(
                      "Belum punya akun? Daftar",
                      style: TextStyle(
                        color: AppColors.grey,
                        decoration: TextDecoration.underline,
                        fontSize: AppTexts.md,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
