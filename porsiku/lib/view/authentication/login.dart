import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:porsiku/components/title.dart';
import 'package:porsiku/constants/constants.dart';
import 'dart:convert';
import 'package:porsiku/services/auth_service.dart';
import 'package:porsiku/view/onboarding/form.dart';
import 'package:porsiku/components/input_field.dart';
import 'package:porsiku/components/button.dart';
import 'package:porsiku/view/main/dashboard.dart';

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
      final url = Uri.parse(
        'https://porsiku-nutrition-estimation-tracker-production.up.railway.app/api/login',
      );
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

        // Save user session using AuthService
        await AuthService.saveUserSession(
          token: token,
          userId: userId,
          userEmail: email, // Save email for future reference
        );

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Login berhasil!")));

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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: AppSpacing.xxl * 2),
                  // Welcome Section
                  const TitleText(text: 'Selamat Datang Kembali'),
                  SizedBox(height: AppSpacing.sm),
                  const SubtitleText(
                    text:
                        'Masuk untuk melanjutkan perjalanan\nnutrisi sehatmu dengan PorsiKu',
                  ),
                  SizedBox(height: AppSpacing.xxl),

                  // Login Form Card
                  Container(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                      boxShadow: AppShadows.card,
                    ),
                    child: Column(
                      children: [
                        // Email Field
                        InputField(
                          controller: emailController,
                          hintText: 'Masukkan email',
                          labelText: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: AppColors.grey,
                            size: 20,
                          ),
                        ),
                        SizedBox(height: AppSpacing.md),

                        // Password Field
                        InputField(
                          controller: passwordController,
                          hintText: 'Masukkan password',
                          labelText: 'Password',
                          isPassword: true,
                          textInputAction: TextInputAction.done,
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: AppColors.grey,
                            size: 20,
                          ),
                          onSubmitted: (_) => !isLoading ? login() : null,
                        ),
                        SizedBox(height: AppSpacing.sm),

                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // TODO: Navigate to forget password
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Fitur lupa password akan segera hadir!',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.white,
                                    ),
                                  ),
                                  backgroundColor: AppColors.primary,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppBorderRadius.md,
                                    ),
                                  ),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                              ),
                            ),
                            child: Text(
                              'Lupa password?',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: AppSpacing.lg),

                        // Login Button
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          child: Button(
                            text: isLoading ? 'Masuk...' : 'Masuk',
                            variant: ButtonVariant.primary,
                            onPressed: isLoading ? null : login,
                            isActive: !isLoading,
                            icon:
                                isLoading
                                    ? SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              AppColors.white,
                                            ),
                                      ),
                                    )
                                    : Icon(
                                      Icons.login_rounded,
                                      size: 18,
                                      color: AppColors.white,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.xl),

                  // Sign Up Link
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                      border: Border.all(color: AppColors.lightGrey, width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Belum punya akun? ",
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.grey,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (context) => const OnboardingFormPage(),
                              ),
                            );
                          },
                          child: Text(
                            "Daftar Sekarang",
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
