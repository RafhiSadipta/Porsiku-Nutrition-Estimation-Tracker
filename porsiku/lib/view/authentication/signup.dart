import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:porsiku/components/input_field.dart';
import 'package:http/http.dart' as http;
import 'package:porsiku/constants/constants.dart';
import 'package:porsiku/services/auth_service.dart';
import 'dart:convert';
import 'login.dart';
import 'package:porsiku/components/button.dart'; // Updated import

class SignupPage extends StatefulWidget {
  final Map<String, dynamic>? onboardingData;

  const SignupPage({super.key, this.onboardingData});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController providerController = TextEditingController();
  final TextEditingController usiaController = TextEditingController();
  final TextEditingController tinggiBadanController = TextEditingController();
  final TextEditingController beratBadanController = TextEditingController();
  final TextEditingController jenisKelaminController = TextEditingController();
  final TextEditingController aktivitasController = TextEditingController();
  final TextEditingController programController = TextEditingController();
  final TextEditingController targetBeratBadanController =
      TextEditingController();
  final TextEditingController targetWaktuController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.onboardingData != null) {
      // Username tetap manual dari input user signup
      usiaController.text = widget.onboardingData!['age']?.toString() ?? '';
      jenisKelaminController.text = _mapGender(
        widget.onboardingData!['gender'],
      );
      beratBadanController.text =
          widget.onboardingData!['weight']?.toString() ?? '';
      tinggiBadanController.text =
          widget.onboardingData!['height']?.toString() ?? '';
      programController.text = widget.onboardingData!['goal'] ?? '';
      targetBeratBadanController.text =
          widget.onboardingData!['targetWeight']?.toString() ?? '';
      targetWaktuController.text = _parsePace(widget.onboardingData!['pace']);
      aktivitasController.text = widget.onboardingData!['activityLevel'] ?? '';
      // providerController.text = ... (isi jika ada)
    }
    print(widget.onboardingData);
  }

  String _mapGender(dynamic gender) {
    return gender?.toString() ?? '';
  }

  String _parsePace(dynamic pace) {
    // pace bisa berupa '0.05kg/week' atau angka, ambil hanya angkanya
    if (pace == null) return '';
    final match = RegExp(r'[\d.]+').firstMatch(pace.toString());
    return match != null ? match.group(0)! : pace.toString();
  }

  Future<void> _register() async {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final provider = providerController.text.trim();
    final usia = usiaController.text.trim();
    final tinggiBadan = tinggiBadanController.text.trim();
    final beratBadan = beratBadanController.text.trim();
    final jenisKelamin = jenisKelaminController.text.trim();
    final aktivitas = aktivitasController.text.trim();
    final program = programController.text.trim();
    final targetBeratBadan = targetBeratBadanController.text.trim();
    final targetWaktu = targetWaktuController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Semua field harus diisi.")));
      return;
    }

    setState(() => isLoading = true);

    final uri = Uri.parse(
      'https://porsiku-nutrition-estimation-tracker-production.up.railway.app/api/register',
    ); // Localhost Android emulator
    final body = {
      'username': username,
      'email': email,
      'password': password,
      if (provider.isNotEmpty) 'provider': provider,
      if (usia.isNotEmpty) 'usia': int.tryParse(usia) ?? 0,
      if (jenisKelamin.isNotEmpty) 'gender': jenisKelamin,
      if (beratBadan.isNotEmpty)
        'berat_badan': double.tryParse(beratBadan) ?? 0,
      if (tinggiBadan.isNotEmpty)
        'tinggi_badan': double.tryParse(tinggiBadan) ?? 0,
      if (program.isNotEmpty) 'program': program,
      if (targetWaktu.isNotEmpty)
        'target_mingguan': double.tryParse(targetWaktu) ?? 0,
      if (targetBeratBadan.isNotEmpty)
        'target_akhir': double.tryParse(targetBeratBadan) ?? 0,
      if (aktivitas.isNotEmpty) 'aktivitas': aktivitas,
    };

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      setState(() => isLoading = false);
      if (response.statusCode == 200) {
        // Mark onboarding as completed when user successfully signs up
        await AuthService.markOnboardingCompleted();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Berhasil daftar! Silakan login.")),
        );
        // Langsung arahkan ke halaman LoginPage setelah berhasil daftar
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false, // Hapus semua route sebelumnya
        );
      } else {
        final responseBody = json.decode(response.body);
        final errorMsg = responseBody['message'] ?? 'Gagal daftar.';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMsg)));
        if (response.statusCode != 200) {
          print('Register error: \\n${response.body}');
        }
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Terjadi kesalahan: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Back Button Only
            Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                top: AppSpacing.md,
              ),
              child: Row(
                children: [
                  _EnhancedCircleButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.pop(context),
                    backgroundColor: AppColors.white.withOpacity(0.9),
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: AppSpacing.xxl),
                    // Welcome Section
                    Text(
                      'Bergabung dengan PorsiKu',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      'Daftar untuk mulai perjalanan\nnutrisi sehat bersama komunitas PorsiKu',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.grey,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppSpacing.xxl),

                    // Signup Form Card
                    Container(
                      padding: EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                        boxShadow: AppShadows.card,
                      ),
                      child: Column(
                        children: [
                          // Username Field
                          InputField(
                            hintText: 'Masukkan username',
                            labelText: 'Username',
                            controller: usernameController,
                            textInputAction: TextInputAction.next,
                            prefixIcon: Icon(
                              Icons.person_outline_rounded,
                              color: AppColors.grey,
                              size: 20,
                            ),
                          ),
                          SizedBox(height: AppSpacing.md),

                          // Email Field
                          InputField(
                            hintText: 'Masukkan email',
                            labelText: 'Email',
                            keyboardType: TextInputType.emailAddress,
                            controller: emailController,
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
                            hintText: 'Masukkan password',
                            labelText: 'Password',
                            isPassword: true,
                            controller: passwordController,
                            textInputAction: TextInputAction.done,
                            prefixIcon: Icon(
                              Icons.lock_outline_rounded,
                              color: AppColors.grey,
                              size: 20,
                            ),
                            onSubmitted: (_) => !isLoading ? _register() : null,
                          ),
                          SizedBox(height: AppSpacing.xl),
                          // Submit Button
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: double.infinity,
                            child: Button(
                              text:
                                  isLoading
                                      ? 'Mendaftar...'
                                      : 'Daftar Sekarang',
                              variant: ButtonVariant.primary,
                              onPressed: isLoading ? null : _register,
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
                                        Icons.person_add_rounded,
                                        size: 18,
                                        color: AppColors.white,
                                      ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSpacing.xl),

                    // Login Link
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                        border: Border.all(
                          color: AppColors.lightGrey,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Sudah punya akun? ",
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.grey,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => const LoginPage(),
                                ),
                              );
                            },
                            child: Text(
                              "Masuk Sekarang",
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
          ],
        ),
      ),
    );
  }
}

// Enhanced Circle Button Component from recipe_open.dart
class _EnhancedCircleButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? backgroundColor;

  const _EnhancedCircleButton({
    required this.icon,
    required this.onTap,
    this.backgroundColor,
  });

  @override
  State<_EnhancedCircleButton> createState() => _EnhancedCircleButtonState();
}

class _EnhancedCircleButtonState extends State<_EnhancedCircleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? AppColors.white.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  HapticFeedback.lightImpact();
                  widget.onTap();
                },
                onTapDown: (_) => _animationController.forward(),
                onTapUp: (_) => _animationController.reverse(),
                onTapCancel: () => _animationController.reverse(),
                child: Icon(
                  widget.icon,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
