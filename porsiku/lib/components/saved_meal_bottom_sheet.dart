import 'dart:io';
import 'package:flutter/material.dart';
import 'package:porsiku/constants/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SavedMealBottomSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onMealSelected;

  const SavedMealBottomSheet({super.key, required this.onMealSelected});

  @override
  State<SavedMealBottomSheet> createState() => _SavedMealBottomSheetState();
}

class _SavedMealBottomSheetState extends State<SavedMealBottomSheet> {
  List<Map<String, dynamic>> savedMeals = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchSavedMeals();
  }

  Future<void> _fetchSavedMeals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      final token = prefs.getString('token');

      if (userId == null || token == null) {
        setState(() {
          errorMessage = 'User not logged in';
          isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse(
          'https://porsiku-nutrition-estimation-tracker-production.up.railway.app/api/save_konsumsi/$userId',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final data = responseData['data'] as List<dynamic>?;

        if (data != null) {
          setState(() {
            savedMeals =
                data.map((item) => item as Map<String, dynamic>).toList();
            isLoading = false;
          });
        } else {
          setState(() {
            savedMeals = [];
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to load saved meals';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  void _selectMeal(Map<String, dynamic> meal) {
    // Transform the meal data to match the expected format
    final transformedMeal = {
      'id': meal['id'],
      'nama_makanan': meal['nama_makanan'],
      'kalori_total': meal['kalori_total'],
      'protein_total': meal['protein_total'],
      'lemak_total': meal['lemak_total'],
      'karbohidrat_total': meal['karbohidrat_total'],
      'waktu_makan': meal['waktu_makan'],
      'foto': meal['foto'],
      'is_foto': meal['is_foto'],
      'nutrition_items': meal['nutrition_items'],
    };

    print('DEBUG: Selected saved meal foto: ${meal['foto']}');
    print('DEBUG: Selected saved meal is_foto: ${meal['is_foto']}');

    Navigator.pop(context);
    widget.onMealSelected(transformedMeal);
  }

  String _getMealIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return '🍳';
      case 'lunch':
        return '🍽️';
      case 'dinner':
        return '🌙';
      default:
        return '🍽️';
    }
  }

  // Helper method to check if image is placeholder
  bool _isPlaceholderImage(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return true;

    // Check if it's placeholder image path or URL
    return imagePath.contains('placeholder.png') ||
        imagePath.contains('placeholder') ||
        imagePath == 'assets/images/placeholder.png';
  }

  // Helper method to check if path is network URL
  bool _isNetworkUrl(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }

  // Helper method to build meal image with smart fallback
  Widget _buildMealImage(Map<String, dynamic> meal, String mealIcon) {
    final String? foto = meal['foto'];
    final bool isFoto = meal['is_foto'] == true;

    print('DEBUG: Building meal image - foto: $foto, isFoto: $isFoto');
    print('DEBUG: Is placeholder: ${_isPlaceholderImage(foto)}');

    // Check if we have a valid, non-placeholder image
    if (isFoto &&
        foto != null &&
        foto.isNotEmpty &&
        !_isPlaceholderImage(foto)) {
      if (_isNetworkUrl(foto)) {
        print('DEBUG: Using network image: $foto');
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            foto,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('DEBUG: Network image failed, using meal icon fallback');
              return Center(
                child: Text(mealIcon, style: const TextStyle(fontSize: 24)),
              );
            },
          ),
        );
      } else {
        print('DEBUG: Using local file image: $foto');
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(foto),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('DEBUG: Local file image failed, using meal icon fallback');
              return Center(
                child: Text(mealIcon, style: const TextStyle(fontSize: 24)),
              );
            },
          ),
        );
      }
    } else {
      print('DEBUG: Using meal icon emoji: $mealIcon');
      // Use meal icon emoji as fallback
      return Center(
        child: Text(mealIcon, style: const TextStyle(fontSize: 24)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  'Saved Meals',
                  style: TextStyle(
                    fontSize: AppTexts.xl,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : errorMessage != null
                    ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: AppColors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              errorMessage!,
                              style: TextStyle(
                                color: AppColors.grey,
                                fontSize: AppTexts.md,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isLoading = true;
                                  errorMessage = null;
                                });
                                _fetchSavedMeals();
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                    : savedMeals.isEmpty
                    ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bookmark_border,
                              size: 64,
                              color: AppColors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No Saved Meals',
                              style: TextStyle(
                                fontSize: AppTexts.lg,
                                fontWeight: FontWeight.w600,
                                color: AppColors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Save your favorite meals to quickly add them later',
                              style: TextStyle(
                                color: AppColors.grey,
                                fontSize: AppTexts.md,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                    : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: savedMeals.length,
                      separatorBuilder:
                          (context, index) =>
                              const Divider(height: 1, indent: 66),
                      itemBuilder: (context, index) {
                        final meal = savedMeals[index];
                        final mealType = meal['waktu_makan'] ?? 'Dinner';
                        final calories = meal['kalori_total']?.round() ?? 0;
                        final mealIcon = _getMealIcon(mealType);

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 0,
                          ),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.lightGrey,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: _buildMealImage(meal, mealIcon),
                          ),
                          title: Text(
                            meal['nama_makanan'] ?? 'Unknown Meal',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                '$mealType • $calories cal',
                                style: TextStyle(
                                  color: AppColors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'Add',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          onTap: () => _selectMeal(meal),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
