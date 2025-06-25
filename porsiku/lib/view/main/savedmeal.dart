import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'result.dart';

class SavedMealsPage extends StatefulWidget {
  const SavedMealsPage({super.key});

  @override
  State<SavedMealsPage> createState() => _SavedMealsPageState();
}

class _SavedMealsPageState extends State<SavedMealsPage> {
  List<Map<String, dynamic>> savedMeals = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchSavedMeals();
  }

  Future<void> _fetchSavedMeals() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      final token = prefs.getString('token');
      if (token == null || userId == null) {
        setState(() {
          errorMessage = 'User not logged in.';
          isLoading = false;
        });
        return;
      }
      // Ambil semua konsumsi user, lalu filter yang is_saved == true
      final response = await http.get(
        Uri.parse(
          'https://porsiku-nutrition-estimation-tracker-production.up.railway.app/api/save_konsumsi/$userId',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> meals = data['data'] ?? [];
        final List<Map<String, dynamic>> filtered =
            meals
                .where(
                  (m) => m is Map<String, dynamic> && m['is_saved'] == true,
                )
                .cast<Map<String, dynamic>>()
                .toList();
        setState(() {
          savedMeals = filtered;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Gagal mengambil saved meals: \n${response.body}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Meals')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : savedMeals.isEmpty
              ? const Center(child: Text('Belum ada saved meal.'))
              : ListView.separated(
                itemCount: savedMeals.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final meal = savedMeals[index];
                  return ListTile(
                    title: Text(meal['nama_makanan'] ?? 'No name'),
                    subtitle: Text(
                      (meal['kalori_total'] != null
                              ? '${meal['kalori_total']} kalori'
                              : '') +
                          (meal['jumlah'] != null
                              ? ' • ${meal['jumlah']}'
                              : ''),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Hapus Saved Meal',
                      onPressed: () async {
                        if (meal['id'] == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('ID konsumsi tidak ditemukan'),
                            ),
                          );
                          return;
                        }
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text('Hapus Saved Meal'),
                                content: const Text(
                                  'Yakin ingin menghapus saved meal ini?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, false),
                                    child: const Text('Batal'),
                                  ),
                                  ElevatedButton(
                                    onPressed:
                                        () => Navigator.pop(context, true),
                                    child: const Text('Hapus'),
                                  ),
                                ],
                              ),
                        );
                        if (confirm == true) {
                          await _unsaveMeal(meal['id'].toString());
                        }
                      },
                    ),
                    onTap: () {
                      // Pastikan meal['id'] adalah ID konsumsi yang valid
                      if (meal['id'] == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('ID konsumsi tidak ditemukan'),
                          ),
                        );
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ResultPage(
                                foodListText: meal['nama_makanan'] ?? '',
                                nutritionResult: meal['nutrition_items'] ?? [],
                                imagePath: meal['foto'] ?? '',
                                isViewMode: true,
                                existingKonsumsiId: meal['id'].toString(),
                              ),
                        ),
                      ).then((_) {
                        _fetchSavedMeals();
                      });
                    },
                  );
                },
              ),
    );
  }

  Future<void> _unsaveMeal(String konsumsiId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      print('DEBUG: Akan unsave konsumsiId: $konsumsiId');
      if (token == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User not logged in.')));
        return;
      }
      // Endpoint dan body disamakan dengan ResultPage
      final url =
          'https://porsiku-nutrition-estimation-tracker-production.up.railway.app/api/save_konsumsi/$konsumsiId';
      print('DEBUG: Endpoint unsave: $url');
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'is_saved': false}),
      );
      print('DEBUG: Response status: ${response.statusCode}');
      print('DEBUG: Response body: ${response.body}');
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved meal berhasil dihapus.')),
        );
        _fetchSavedMeals();
      } else {
        String errorMsg = 'Gagal hapus: ${response.body}';
        try {
          final err = jsonDecode(response.body);
          if (err is Map && err['error'] != null)
            errorMsg = 'Gagal hapus: ${err['error']}';
        } catch (_) {}
        print('DEBUG: Error saat unsave: $errorMsg');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMsg)));
      }
    } catch (e) {
      print('DEBUG: Exception saat unsave: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
