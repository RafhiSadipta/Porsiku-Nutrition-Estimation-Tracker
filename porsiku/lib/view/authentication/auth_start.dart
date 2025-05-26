import 'package:flutter/material.dart';
import 'package:porsiku/constants/constants.dart';
import 'package:porsiku/components/title.dart';
import 'package:porsiku/components/button.dart'; // Updated import

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
                // Icon ilustrasi
                Container(
                  margin: const EdgeInsets.only(bottom: 40),
                  child: Icon(
                    Icons.cookie,
                    size: AppIcons.xl,
                    color: AppColors.black,
                  ),
                ),

                // Judul
                const TitleText(
                  text:
                      'Langkah pertama menuju\nhidup lebih sehat dimulai\ndi sini',
                ),
                const SizedBox(height: 8),

                // Subjudul
                const SubtitleText(text: 'Buat akun baru atau masuk kembali'),
                const SizedBox(height: 40),

                // Tombol Continue with Email
                Button(
                  text: 'Continue With Email',
                  variant: ButtonVariant.primary,
                  icon: const Icon(
                    Icons.mail_outline,
                    color: AppColors.white,
                    size: AppIcons.md,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SignupPage()),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Tombol Continue with Google
                Button(
                  text: 'Continue With Google',
                  variant: ButtonVariant.primary,
                  icon: const Icon(
                    Icons.g_mobiledata,
                    color: AppColors.white,
                    size: AppIcons.md,
                  ),
                  onPressed: () {
                    // TODO: Implementasi autentikasi Google
                  },
                ),
                const SizedBox(height: 16),

                // Tombol Login dengan Email
                Button(
                  text: 'Log In With Email',
                  variant: ButtonVariant.secondary,
                  icon: const Icon(
                    Icons.badge_outlined,
                    color: AppColors.black,
                    size: AppIcons.md,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Tombol Scan (opsional, bisa disembunyikan nanti)
                Button(
                  text: 'Scan',
                  variant: ButtonVariant.secondary,
                  icon: const Icon(
                    Icons.qr_code_scanner,
                    color: AppColors.black,
                    size: AppIcons.md,
                  ),
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: (_) => const ScanPage()));
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
