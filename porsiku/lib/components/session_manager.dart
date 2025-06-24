import 'package:flutter/material.dart';
import 'package:porsiku/services/auth_service.dart';

class SessionManager {
  static bool _isInitialized = false;

  // Initialize session manager
  static Future<void> initialize() async {
    if (_isInitialized) return;

    print('DEBUG: Initializing SessionManager');
    _isInitialized = true;

    // Check initial session status
    await checkSession();
  }

  // Check current session status
  static Future<SessionStatus> checkSession() async {
    try {
      final isLoggedIn = await AuthService.isLoggedIn();

      if (!isLoggedIn) {
        print('DEBUG: Session check - User not logged in');
        return SessionStatus.notLoggedIn;
      }

      final isExpiringSoon = await AuthService.isTokenExpiringSoon();

      if (isExpiringSoon) {
        print('DEBUG: Session check - Token expiring soon');
        return SessionStatus.expiringSoon;
      }

      print('DEBUG: Session check - Valid session');
      return SessionStatus.valid;
    } catch (e) {
      print('DEBUG: Session check error: $e');
      return SessionStatus.error;
    }
  }

  // Handle session based on current app state
  static Future<NavigationTarget> handleAppStart(BuildContext context) async {
    final sessionStatus = await checkSession();
    final hasCompletedOnboarding = await AuthService.hasCompletedOnboarding();

    switch (sessionStatus) {
      case SessionStatus.valid:
        print('DEBUG: Valid session - proceeding to dashboard');
        return NavigationTarget.dashboard;

      case SessionStatus.expiringSoon:
        print('DEBUG: Token expiring soon - showing warning');
        _showExpiringWarning(context);
        return NavigationTarget.dashboard; // Still valid, but show warning

      case SessionStatus.notLoggedIn:
      case SessionStatus.error:
        if (hasCompletedOnboarding) {
          print(
            'DEBUG: User has completed onboarding before - redirecting to login',
          );
          return NavigationTarget.login;
        } else {
          print('DEBUG: New user - redirecting to landing/onboarding');
          return NavigationTarget.landing;
        }
    }
  }

  // Show warning when token is expiring soon
  static void _showExpiringWarning(BuildContext context) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Your session will expire soon. Please login again to continue.',
        ),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Login',
          onPressed: () {
            // Navigate to login page
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          },
        ),
      ),
    );
  }

  // Refresh session by getting user data
  static Future<void> refreshSession() async {
    await checkSession();
  }

  // Logout user
  static Future<void> logout(BuildContext context) async {
    await AuthService.clearSession();

    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  // Check if user needs to login
  static Future<bool> requiresLogin() async {
    final sessionStatus = await checkSession();
    return sessionStatus == SessionStatus.notLoggedIn ||
        sessionStatus == SessionStatus.error;
  }

  // Get session info for debugging
  static Future<Map<String, dynamic>> getSessionInfo() async {
    final userData = await AuthService.getUserData();
    final expiryDate = await AuthService.getTokenExpiryDate();
    final isExpiringSoon = await AuthService.isTokenExpiringSoon();

    return {
      'user_data': userData,
      'token_expiry': expiryDate?.toIso8601String(),
      'is_expiring_soon': isExpiringSoon,
      'session_status': (await checkSession()).name,
    };
  }
}

enum SessionStatus { valid, expiringSoon, notLoggedIn, error }

enum NavigationTarget { dashboard, login, landing }
