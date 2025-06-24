import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  static const String _tokenKey = 'token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _hasCompletedOnboardingKey = 'has_completed_onboarding';
  // Save user session after successful login
  static Future<void> saveUserSession({
    required String token,
    required String userId,
    String? userName,
    String? userEmail,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userIdKey, userId);
    if (userName != null) await prefs.setString(_userNameKey, userName);
    if (userEmail != null) await prefs.setString(_userEmailKey, userEmail);

    // Mark onboarding as completed when user successfully logs in
    await prefs.setBool(_hasCompletedOnboardingKey, true);

    print('DEBUG: User session saved - UserID: $userId');
  }

  // Get current token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Get current user ID
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  // Get current user name
  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  // Get current user email
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  // Check if user has completed onboarding (signed up at least once)
  static Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasCompletedOnboardingKey) ?? false;
  }

  // Mark onboarding as completed (called after first successful signup)
  static Future<void> markOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasCompletedOnboardingKey, true);
    print('DEBUG: Onboarding marked as completed');
  }

  // Check if user is logged in and token is valid
  static Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();

      if (token == null || token.isEmpty) {
        print('DEBUG: No token found');
        return false;
      }

      // Check if token is expired
      if (JwtDecoder.isExpired(token)) {
        print('DEBUG: Token is expired');
        await clearSession(); // Clear expired session
        return false;
      }

      print('DEBUG: User is logged in with valid token');
      return true;
    } catch (e) {
      print('DEBUG: Error checking login status: $e');
      await clearSession(); // Clear invalid session
      return false;
    }
  }

  // Get token expiry date
  static Future<DateTime?> getTokenExpiryDate() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final expiryDate = JwtDecoder.getExpirationDate(token);
      return expiryDate;
    } catch (e) {
      print('DEBUG: Error getting token expiry: $e');
      return null;
    }
  }

  // Check if token will expire soon (within next hour)
  static Future<bool> isTokenExpiringSoon() async {
    try {
      final expiryDate = await getTokenExpiryDate();
      if (expiryDate == null) return true;

      final now = DateTime.now();
      final difference = expiryDate.difference(now);

      // Consider token expiring soon if less than 1 hour remaining
      return difference.inHours < 1;
    } catch (e) {
      print('DEBUG: Error checking token expiry: $e');
      return true;
    }
  }

  // Clear user session (logout)
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
    // Note: We don't clear _hasCompletedOnboardingKey as it should persist

    print('DEBUG: User session cleared');
  }

  // Get all user data
  static Future<Map<String, String?>> getUserData() async {
    return {
      'token': await getToken(),
      'user_id': await getUserId(),
      'user_name': await getUserName(),
      'user_email': await getUserEmail(),
    };
  }

  // Decode JWT token to get user info
  static Future<Map<String, dynamic>?> getTokenPayload() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      return JwtDecoder.decode(token);
    } catch (e) {
      print('DEBUG: Error decoding token: $e');
      return null;
    }
  }
}
