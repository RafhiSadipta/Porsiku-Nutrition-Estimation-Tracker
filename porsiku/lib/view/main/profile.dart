import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../constants/constants.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _usernameController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameFocus = FocusNode();
  final _newPasswordFocus = FocusNode();
  bool isLoading = false;
  String? errorMessage;
  String? successMessage;
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    // Auto-focus username field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _usernameFocus.requestFocus();
    });
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('user_id');
      _usernameController.text = prefs.getString('username') ?? '';
    });
  }

  Future<void> _showSnackbar(String message, {bool success = false}) async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _updateUsername() async {
    if (_usernameController.text.trim().isEmpty) {
      setState(() {
        errorMessage = 'Username tidak boleh kosong.';
      });
      _showSnackbar(errorMessage!);
      _usernameFocus.requestFocus();
      return;
    }
    setState(() {
      isLoading = true;
      errorMessage = null;
      successMessage = null;
    });
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (userId == null || token == null) {
      setState(() {
        errorMessage = 'User not logged in.';
        isLoading = false;
      });
      _showSnackbar(errorMessage!);
      return;
    }
    final url =
        'https://porsiku-nutrition-estimation-tracker-production.up.railway.app/api/user/username/$userId';
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'username': _usernameController.text.trim()}),
      );
      if (response.statusCode == 200) {
        setState(() {
          successMessage = 'Username berhasil diupdate!';
        });
        prefs.setString('username', _usernameController.text.trim());
        _showSnackbar(successMessage!, success: true);
      } else {
        final resp = jsonDecode(response.body);
        setState(() {
          errorMessage = resp['error']?.toString() ?? 'Gagal update username.';
        });
        _showSnackbar(errorMessage!);
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
      });
      _showSnackbar(errorMessage!);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updatePassword() async {
    if (_oldPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      setState(() {
        errorMessage = 'Semua field password harus diisi.';
      });
      _showSnackbar(errorMessage!);
      _newPasswordFocus.requestFocus();
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() {
        errorMessage = 'Konfirmasi password baru tidak cocok.';
      });
      _showSnackbar(errorMessage!);
      _newPasswordFocus.requestFocus();
      return;
    }
    if (_oldPasswordController.text == _newPasswordController.text) {
      setState(() {
        errorMessage = 'Password baru tidak boleh sama dengan password lama.';
      });
      _showSnackbar(errorMessage!);
      _newPasswordFocus.requestFocus();
      return;
    }
    setState(() {
      isLoading = true;
      errorMessage = null;
      successMessage = null;
    });
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (userId == null || token == null) {
      setState(() {
        errorMessage = 'User not logged in.';
        isLoading = false;
      });
      _showSnackbar(errorMessage!);
      return;
    }
    final url =
        'https://porsiku-nutrition-estimation-tracker-production.up.railway.app/api/user/password/$userId';
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'password': _oldPasswordController.text,
          'password_baru': _newPasswordController.text,
        }),
      );
      if (response.statusCode == 200) {
        setState(() {
          successMessage = 'Password berhasil diupdate!';
        });
        _oldPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        _showSnackbar(successMessage!, success: true);
      } else {
        final resp = jsonDecode(response.body);
        setState(() {
          errorMessage = resp['error']?.toString() ?? 'Gagal update password.';
        });
        _showSnackbar(errorMessage!);
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
      });
      _showSnackbar(errorMessage!);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _usernameFocus.dispose();
    _newPasswordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: Card(
            elevation: AppElevations.md,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
            ),
            color: AppColors.surface,
            child: Padding(
              padding: AppCards.paddingLarge,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: AppSpacing.md),
                  Text('Ganti Username', style: AppTextStyles.h3),
                  SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _usernameController,
                    focusNode: _usernameFocus,
                    style: AppTextStyles.bodyLarge,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle: AppTextStyles.label,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: AppInputs.padding,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                      ),
                      padding: AppButtons.padding,
                      elevation: AppElevations.sm,
                    ),
                    onPressed: isLoading ? null : _updateUsername,
                    child:
                        isLoading
                            ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.textOnPrimary,
                              ),
                            )
                            : Text(
                              'Update Username',
                              style: AppTextStyles.primaryButton,
                            ),
                  ),
                  SizedBox(height: AppSpacing.lg),
                  Text('Ganti Password', style: AppTextStyles.h3),
                  SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _oldPasswordController,
                    obscureText: true,
                    style: AppTextStyles.bodyLarge,
                    decoration: InputDecoration(
                      labelText: 'Password Lama',
                      labelStyle: AppTextStyles.label,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: AppInputs.padding,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _newPasswordController,
                    focusNode: _newPasswordFocus,
                    obscureText: true,
                    style: AppTextStyles.bodyLarge,
                    decoration: InputDecoration(
                      labelText: 'Password Baru',
                      labelStyle: AppTextStyles.label,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: AppInputs.padding,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    style: AppTextStyles.bodyLarge,
                    decoration: InputDecoration(
                      labelText: 'Konfirmasi Password Baru',
                      labelStyle: AppTextStyles.label,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: AppInputs.padding,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                      ),
                      padding: AppButtons.padding,
                      elevation: AppElevations.sm,
                    ),
                    onPressed: isLoading ? null : _updatePassword,
                    child:
                        isLoading
                            ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.textOnPrimary,
                              ),
                            )
                            : Text(
                              'Update Password',
                              style: AppTextStyles.primaryButton,
                            ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  // Feedback text is now handled by snackbar
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
