// Tambahkan di file service, misal: lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, dynamic>> fetchDailyTarget(String userId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token'); // Ambil token dari SharedPreferences

  final headers = <String, String>{};
  if (token != null) {
    headers['Authorization'] = 'Bearer $token';
  }

  final response = await http.get(
    Uri.parse(
      'http://192.168.0.105:8080/api/daily_target/$userId',
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
    Uri.parse('http://192.168.0.105:8080/api/analytics/$userId?week=$week'),
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
    Uri.parse('http://192.168.0.105:8080/api/resep-detil'),
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
