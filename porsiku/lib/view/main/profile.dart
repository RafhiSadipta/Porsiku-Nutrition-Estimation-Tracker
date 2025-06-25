import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../constants/constants.dart';
import '../../components/input_field.dart';
import '../../components/button.dart';

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
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle_rounded : Icons.error_rounded,
              color: AppColors.white,
              size: 20,
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: success ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
        ),
        margin: EdgeInsets.all(AppSpacing.md),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _updateUsername() async {
    if (_usernameController.text.trim().isEmpty) {
      setState(() {
        errorMessage = 'Username cannot be empty.';
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
          successMessage = 'Username successfully updated!';
        });
        prefs.setString('username', _usernameController.text.trim());
        _showSnackbar(successMessage!, success: true);
      } else {
        final resp = jsonDecode(response.body);
        setState(() {
          errorMessage =
              resp['error']?.toString() ?? 'Failed to update username.';
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
        errorMessage = 'All password fields must be filled.';
      });
      _showSnackbar(errorMessage!);
      _newPasswordFocus.requestFocus();
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() {
        errorMessage = 'New password confirmation does not match.';
      });
      _showSnackbar(errorMessage!);
      _newPasswordFocus.requestFocus();
      return;
    }
    if (_oldPasswordController.text == _newPasswordController.text) {
      setState(() {
        errorMessage = 'New password cannot be the same as old password.';
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
          successMessage = 'Password successfully updated!';
        });
        _oldPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        _showSnackbar(successMessage!, success: true);
      } else {
        final resp = jsonDecode(response.body);
        setState(() {
          errorMessage =
              resp['error']?.toString() ?? 'Failed to update password.';
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Premium Header
            Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.05),
                    AppColors.primaryLight.withOpacity(0.02),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  // Back Button
                  ElevatedButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.white,
                          foregroundColor: AppColors.black,
                          minimumSize: const Size(40, 40),
                          maximumSize: const Size(40, 40),
                          padding: EdgeInsets.zero,
                          shape: const CircleBorder(),
                          elevation: 2,
                          shadowColor: AppColors.black.withOpacity(0.1),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: AppColors.black,
                          size: 18,
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 100.ms)
                      .scale(begin: const Offset(0.8, 0.8)),

                  // Title Section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'My Profile',
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.3),
                      ],
                    ),
                  ),

                  // Invisible spacer to balance the back button
                  SizedBox(width: 40, height: 40),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    // Username Section Card
                    Container(
                      padding: EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                        boxShadow: AppShadows.card,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section Header
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(AppSpacing.sm),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(
                                    AppBorderRadius.md,
                                  ),
                                ),
                                child: Icon(
                                  Icons.person_outline_rounded,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              SizedBox(width: AppSpacing.md),
                              Text(
                                'Change Username',
                                style: AppTextStyles.h4.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: AppSpacing.lg),

                          // Username Input
                          InputField(
                            controller: _usernameController,
                            labelText: 'Username',
                            hintText: 'Enter new username',
                            prefixIcon: Icon(
                              Icons.alternate_email_rounded,
                              color: AppColors.grey,
                              size: 20,
                            ),
                            textInputAction: TextInputAction.done,
                            onSubmitted:
                                (_) => !isLoading ? _updateUsername() : null,
                          ),

                          SizedBox(height: AppSpacing.lg),

                          // Update Username Button
                          SizedBox(
                            width: double.infinity,
                            child: Button(
                              text:
                                  isLoading ? 'Updating...' : 'Update Username',
                              variant: ButtonVariant.primary,
                              onPressed: isLoading ? null : _updateUsername,
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
                                        Icons.save_rounded,
                                        size: 18,
                                        color: AppColors.white,
                                      ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3),

                    SizedBox(height: AppSpacing.xl),

                    // Password Section Card
                    Container(
                      padding: EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                        boxShadow: AppShadows.card,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section Header
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(AppSpacing.sm),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(
                                    AppBorderRadius.md,
                                  ),
                                ),
                                child: Icon(
                                  Icons.lock_outline_rounded,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              SizedBox(width: AppSpacing.md),
                              Text(
                                'Change Password',
                                style: AppTextStyles.h4.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: AppSpacing.lg),

                          // Old Password Input
                          InputField(
                            controller: _oldPasswordController,
                            labelText: 'Old Password',
                            hintText: 'Enter old password',
                            isPassword: true,
                            prefixIcon: Icon(
                              Icons.lock_open_rounded,
                              color: AppColors.grey,
                              size: 20,
                            ),
                            textInputAction: TextInputAction.next,
                          ),

                          SizedBox(height: AppSpacing.sm),

                          // New Password Input
                          InputField(
                            controller: _newPasswordController,
                            labelText: 'New Password',
                            hintText: 'Enter new password',
                            isPassword: true,
                            prefixIcon: Icon(
                              Icons.lock_rounded,
                              color: AppColors.grey,
                              size: 20,
                            ),
                            textInputAction: TextInputAction.next,
                          ),

                          SizedBox(height: AppSpacing.sm),

                          // Confirm Password Input
                          InputField(
                            controller: _confirmPasswordController,
                            labelText: 'Confirm Password',
                            hintText: 'Confirm new password',
                            isPassword: true,
                            prefixIcon: Icon(
                              Icons.lock_reset_rounded,
                              color: AppColors.grey,
                              size: 20,
                            ),
                            textInputAction: TextInputAction.done,
                            onSubmitted:
                                (_) => !isLoading ? _updatePassword() : null,
                          ),

                          SizedBox(height: AppSpacing.lg),

                          // Update Password Button
                          SizedBox(
                            width: double.infinity,
                            child: Button(
                              text:
                                  isLoading ? 'Updating...' : 'Update Password',
                              variant: ButtonVariant.primary,
                              onPressed: isLoading ? null : _updatePassword,
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
                                        Icons.security_rounded,
                                        size: 18,
                                        color: AppColors.white,
                                      ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3),

                    SizedBox(height: AppSpacing.md),
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
