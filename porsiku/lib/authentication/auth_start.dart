import 'package:flutter/material.dart';
import 'signup.dart';
import 'login.dart';

class AuthStartPage extends StatelessWidget {
  const AuthStartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Cookie Icon
                Container(
                  margin: const EdgeInsets.only(bottom: 40),
                  child: Icon(Icons.cookie, size: 120, color: Colors.black87),
                ),
                // Title
                const Text(
                  'Langkah pertama menuju\nhidup lebih sehat dimulai\ndi sini',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // Subtitle
                const Text(
                  'Buat akun baru atau masuk kembali',
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                // Continue With Email Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.mail_outline, color: Colors.white),
                    label: const Text(
                      'Continue With Email',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.centerLeft,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SignupPage(),
                        ),
                      );
                    },
                  ),
                ),
                // const SizedBox(height: 16),
                // // Continue With Google Button
                // SizedBox(
                //   width: double.infinity,
                //   child: ElevatedButton.icon(
                //     icon: Image.asset(
                //       'assets/google_logo.png',
                //       height: 24,
                //       width: 24,
                //     ),
                //     label: const Text(
                //       'Continue With Google',
                //       style: TextStyle(
                //         fontSize: 16,
                //         fontWeight: FontWeight.w600,
                //         color: Colors.white,
                //       ),
                //     ),
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: Colors.white,
                //       foregroundColor: Colors.black,
                //       side: const BorderSide(color: Colors.black12),
                //       padding: const EdgeInsets.symmetric(vertical: 16),
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(12),
                //       ),
                //       alignment: Alignment.centerLeft,
                //       elevation: 2,
                //       shadowColor: Colors.black12,
                //     ).copyWith(
                //       backgroundColor: WidgetStateProperty.resolveWith<Color>((
                //         states,
                //       ) {
                //         if (states.contains(WidgetState.pressed)) {
                //           return Colors.grey.shade200;
                //         }
                //         return Colors.white;
                //       }),
                //     ),
                //     onPressed: () {
                //       // TODO: Continue with Google
                //     },
                //   ),
                // ),
                const SizedBox(height: 16),
                // Log In With Email Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.badge_outlined, color: Colors.black),
                    label: const Text(
                      'Log In With Email',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: Colors.black12),
                      alignment: Alignment.centerLeft,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
