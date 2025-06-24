// API Service with automatic session management
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:porsiku/services/auth_service.dart';
import 'package:porsiku/components/session_manager.dart';

class ApiService {
  static const String baseUrl =
      'https://porsiku-nutrition-estimation-tracker-production.up.railway.app/api';

  // Make authenticated GET request with session check
  static Future<http.Response> authenticatedGet(
    String endpoint, {
    BuildContext? context,
  }) async {
    return _makeAuthenticatedRequest(
      () async => http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getAuthHeaders(),
      ),
      context: context,
    );
  }

  // Make authenticated POST request with session check
  static Future<http.Response> authenticatedPost(
    String endpoint, {
    Object? body,
    BuildContext? context,
  }) async {
    return _makeAuthenticatedRequest(
      () async => http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getAuthHeaders(),
        body: body != null ? jsonEncode(body) : null,
      ),
      context: context,
    );
  }

  // Get headers with authentication token
  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await AuthService.getToken();

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Private method to handle authenticated requests with session check
  static Future<http.Response> _makeAuthenticatedRequest(
    Future<http.Response> Function() requestFunction, {
    BuildContext? context,
  }) async {
    // Check session before making request
    final isLoggedIn = await AuthService.isLoggedIn();

    if (!isLoggedIn) {
      // Session is invalid, redirect to login if context available
      if (context != null && context.mounted) {
        await SessionManager.logout(context);
      }
      throw Exception('Session expired. Please login again.');
    }

    try {
      final response = await requestFunction();

      // Check if response indicates authentication error
      if (response.statusCode == 401) {
        print('DEBUG: Received 401 - Token expired');

        // Clear session and redirect to login
        await AuthService.clearSession();
        if (context != null && context.mounted) {
          await SessionManager.logout(context);
        }

        throw Exception('Authentication failed. Please login again.');
      }

      return response;
    } catch (e) {
      print('DEBUG: API request error: $e');
      rethrow;
    }
  }
}

// Legacy methods (keep for backward compatibility)
Future<Map<String, dynamic>> fetchDailyTarget(String userId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token'); // Ambil token dari SharedPreferences

  final headers = <String, String>{};
  if (token != null) {
    headers['Authorization'] = 'Bearer $token';
  }

  final response = await http.get(
    Uri.parse(
      'https://porsiku-nutrition-estimation-tracker-production.up.railway.app/api/daily_target/$userId',
    ), // 10.0.2.2 untuk Android emulator
    headers: headers,
  );
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    print('Error: \\${response.body}');
    throw Exception('Failed to load daily target');
  }
}

Future<Map<String, dynamic>> fetchAnalyticsData(
  String userId, {
  int week = 0,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  final headers = <String, String>{};
  if (token != null) {
    headers['Authorization'] = 'Bearer $token';
  }

  final response = await http.get(
    Uri.parse(
      'https://porsiku-nutrition-estimation-tracker-production.up.railway.app/api/analytics/$userId?week=$week',
    ),
    headers: headers,
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    print('Error: ${response.body}');
    throw Exception('Failed to load analytics data');
  }
}

Future<Map<String, dynamic>> fetchRecipeDetail(int recipeId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  final headers = <String, String>{'Content-Type': 'application/json'};
  if (token != null) {
    headers['Authorization'] = 'Bearer $token';
  }

  final response = await http.post(
    Uri.parse(
      'https://porsiku-nutrition-estimation-tracker-production.up.railway.app/api/resep-detil',
    ),
    headers: headers,
    body: json.encode({'id': recipeId}),
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    print('Error: ${response.body}');
    throw Exception('Failed to load recipe detail');
  }
}
