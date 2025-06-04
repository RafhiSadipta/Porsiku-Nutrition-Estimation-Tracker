import 'package:flutter/material.dart';
import 'package:porsiku/components/input_field.dart';
import 'package:http/http.dart' as http;
import 'package:porsiku/components/title.dart';
import 'package:porsiku/constants/constants.dart';
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
      'http://192.168.0.104:8080/api/register',
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
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 80),
                const TitleText(text: 'Sign Up'),
                const SizedBox(height: 8),
                const SubtitleText(
                  text: 'Daftar untuk mulai menggunakan PorsiKu',
                ),
                const SizedBox(height: 32),

                // Input Fields
                InputField(
                  hintText: 'Username',
                  controller: usernameController,
                ),
                const SizedBox(height: 16),
                InputField(
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController,
                ),
                const SizedBox(height: 16),
                InputField(
                  hintText: 'Password',
                  isPassword: true,
                  controller: passwordController,
                ),
                const SizedBox(height: 24),

                // Submit Button
                Button(
                  // Replaced PrimaryButton
                  text: isLoading ? 'Loading...' : 'Sign Up',
                  variant: ButtonVariant.primary, // Added variant
                  onPressed: isLoading ? null : _register,
                  isActive: !isLoading, // Added isActive based on isLoading
                ),
                const SizedBox(height: 16),

                // Navigate to Login
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  },
                  child: const Text(
                    'Already have an account? Login',
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
    );
  }
}
