import 'dart:io';
import 'package:flutter/material.dart';
import 'package:porsiku/constants/constants.dart';
import 'package:porsiku/components/button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ResultPage extends StatefulWidget {
  final String foodListText;
  final List nutritionResult;
  final String imagePath;

  const ResultPage({
    super.key,
    required this.foodListText,
    required this.nutritionResult,
    required this.imagePath,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  String? konsumsiId;
  bool isDeleting = false;
  bool isLoading = true;
  late String foodName;

  @override
  void initState() {
    super.initState();
    final item =
        widget.nutritionResult.isNotEmpty ? widget.nutritionResult[0] : {};
    foodName = item['nama_makanan'] ?? 'Unknown Product';
    _logConsumption();
  }

  Future<void> _editFoodName() async {
    final controller = TextEditingController(text: foodName);
    final result = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.white,
            title: const Text('Edit Food Name'),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Food Name',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.grey),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, controller.text.trim()),
                child: const Text(
                  'Save',
                  style: TextStyle(color: AppColors.black),
                ),
              ),
            ],
          ),
    );

    if (result != null && result.isNotEmpty && result != foodName) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => const AlertDialog(
              backgroundColor: AppColors.white,
              content: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text('Updating food name...'),
                ],
              ),
            ),
      );

      try {
        print('DEBUG: Starting food name update...');
        print('DEBUG: Old name: $foodName');
        print('DEBUG: New name: $result');
        print('DEBUG: konsumsiId: $konsumsiId');

        // Update local state first
        setState(() {
          foodName = result;
        });

        // Update on backend if konsumsiId exists
        if (konsumsiId != null) {
          print('DEBUG: Calling _updateFoodNameOnBackend...');
          await _updateFoodNameOnBackend();
          print('DEBUG: _updateFoodNameOnBackend completed successfully');
        } else {
          print('DEBUG: konsumsiId is null, skipping backend update');
        }

        // Close loading dialog
        if (mounted) Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Food name updated successfully')),
        );
        print('DEBUG: Successfully completed food name update');
      } catch (e) {
        print('DEBUG: Exception occurred: $e');
        print('DEBUG: Exception type: ${e.runtimeType}');

        // Close loading dialog
        if (mounted) Navigator.pop(context);

        // Revert local state on error
        setState(() {
          foodName =
              widget.nutritionResult.isNotEmpty
                  ? widget.nutritionResult[0]['nama_makanan'] ??
                      'Unknown Product'
                  : 'Unknown Product';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update food name: $e')),
        );
      }
    }
  }

  Future<void> _updateFoodNameOnBackend() async {
    print('DEBUG: _updateFoodNameOnBackend called');
    print('DEBUG: konsumsiId = $konsumsiId');

    if (konsumsiId == null) {
      print('DEBUG: konsumsiId is null, throwing exception');
      throw Exception('No consumption ID available');
    }

    try {
      print('DEBUG: Getting SharedPreferences...');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userId = prefs.getString('user_id');
      if (token == null) {
        print('DEBUG: Token is null, throwing exception');
        throw Exception('User not logged in');
      }
      if (userId == null) {
        print('DEBUG: User ID is null, throwing exception');
        throw Exception('User ID not found');
      }

      print('DEBUG: Token found: ${token.substring(0, 20)}...');
      print('DEBUG: User ID: $userId'); // Ambil seluruh ingredients
      final List<Map<String, dynamic>> ingredients =
          widget.nutritionResult.isNotEmpty
              ? widget.nutritionResult.map<Map<String, dynamic>>((item) {
                final nutr = item['nutrition_total'] ?? {};
                int kalori = 0;
                if (nutr.isNotEmpty && nutr['kalori'] != null) {
                  kalori = (nutr['kalori'] ?? 0).round();
                } else if (item['kalori'] != null) {
                  kalori = (item['kalori'] ?? 0).round();
                } else if (item['calories'] != null) {
                  kalori = (item['calories'] ?? 0).round();
                }
                return {
                  'nama_makanan': item['nama_makanan'] ?? '',
                  'jumlah': item['jumlah'] ?? '',
                  'kalori': kalori,
                  'protein':
                      (nutr['protein'] ?? item['protein'] ?? 0).toDouble(),
                  'lemak': (nutr['lemak'] ?? item['lemak'] ?? 0).toDouble(),
                  'karbohidrat':
                      (nutr['karbohidrat'] ?? item['karbohidrat'] ?? 0)
                          .toDouble(),
                };
              }).toList()
              : [];
      // Hitung total dari seluruh ingredients
      double totalKalori = 0, totalKarbo = 0, totalProtein = 0, totalLemak = 0;
      for (final ing in ingredients) {
        totalKalori += (ing['kalori'] ?? 0).toDouble();
        totalKarbo += (ing['karbohidrat'] ?? 0).toDouble();
        totalProtein += (ing['protein'] ?? 0).toDouble();
        totalLemak += (ing['lemak'] ?? 0).toDouble();
      }
      final now = DateTime.now();
      final mealType = 'Dinner';
      String foto = widget.imagePath;
      bool isFoto = widget.imagePath.isNotEmpty;
      final String? imageUrl =
          ingredients.isNotEmpty
              ? widget.nutritionResult[0]['image_url']
              : null;
      if (!isFoto && imageUrl != null && imageUrl.isNotEmpty) {
        foto = imageUrl;
        isFoto = true;
      }
      final url = 'http://192.168.0.105:8080/api/konsumsi/$konsumsiId';
      final requestBody = {
        'nama_makanan': foodName,
        'kalori_total': totalKalori,
        'karbohidrat_total': totalKarbo,
        'protein_total': totalProtein,
        'lemak_total': totalLemak,
        'waktu_makan': mealType,
        'tanggal': now.toUtc().toIso8601String(),
        'is_foto': isFoto,
        'foto': foto,
        'soft_deleted': false,
        'is_saved': false,
        'nutrition_items': ingredients,
      };
      print('DEBUG: Making PUT request to: $url');
      print('DEBUG: Request body: ${jsonEncode(requestBody)}');

      try {
        final response = await http.put(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(requestBody),
        );

        print('DEBUG: Response status code: ${response.statusCode}');
        print('DEBUG: Response body: ${response.body}');

        if (response.statusCode != 200) {
          throw Exception(
            'Server responded with status ${response.statusCode}: ${response.body}',
          );
        }

        print('DEBUG: PUT request completed successfully');
      } catch (httpError) {
        print('DEBUG: HTTP request failed: $httpError');
        print('DEBUG: HTTP error type: ${httpError.runtimeType}');
        rethrow;
      }
    } catch (e) {
      rethrow; // Re-throw the exception to be handled by the calling function
    }
  }

  Future<void> _logConsumption() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      final token = prefs.getString('token');
      if (userId == null || token == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User not logged in.')));
        setState(() {
          isLoading = false;
        });
        return;
      }
      // Ambil seluruh ingredients
      final List<Map<String, dynamic>> ingredients =
          widget.nutritionResult.isNotEmpty
              ? widget.nutritionResult.map<Map<String, dynamic>>((item) {
                final nutr = item['nutrition_total'] ?? {};
                int kalori = 0;
                if (nutr.isNotEmpty && nutr['kalori'] != null) {
                  kalori = (nutr['kalori'] ?? 0).round();
                } else if (item['kalori'] != null) {
                  kalori = (item['kalori'] ?? 0).round();
                } else if (item['calories'] != null) {
                  kalori = (item['calories'] ?? 0).round();
                }
                return {
                  'nama_makanan': item['nama_makanan'] ?? '',
                  'jumlah': item['jumlah'] ?? '',
                  'kalori': kalori,
                  'protein':
                      (nutr['protein'] ?? item['protein'] ?? 0).toDouble(),
                  'lemak': (nutr['lemak'] ?? item['lemak'] ?? 0).toDouble(),
                  'karbohidrat':
                      (nutr['karbohidrat'] ?? item['karbohidrat'] ?? 0)
                          .toDouble(),
                };
              }).toList()
              : [];
      // Hitung total dari seluruh ingredients
      double totalKalori = 0, totalKarbo = 0, totalProtein = 0, totalLemak = 0;
      for (final ing in ingredients) {
        totalKalori += (ing['kalori'] ?? 0).toDouble();
        totalKarbo += (ing['karbohidrat'] ?? 0).toDouble();
        totalProtein += (ing['protein'] ?? 0).toDouble();
        totalLemak += (ing['lemak'] ?? 0).toDouble();
      }
      final now = DateTime.now();
      final mealType = 'Dinner';
      String foto = widget.imagePath;
      bool isFoto = widget.imagePath.isNotEmpty;
      final String? imageUrl =
          ingredients.isNotEmpty
              ? widget.nutritionResult[0]['image_url']
              : null;
      if (!isFoto && imageUrl != null && imageUrl.isNotEmpty) {
        foto = imageUrl;
        isFoto = true;
      }
      final response = await http.post(
        Uri.parse('http://192.168.0.105:8080/api/konsumsi'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'id_user': userId,
          'nama_makanan': foodName,
          'kalori_total': totalKalori,
          'karbohidrat_total': totalKarbo,
          'protein_total': totalProtein,
          'lemak_total': totalLemak,
          'waktu_makan': mealType,
          'tanggal': now.toUtc().toIso8601String(),
          'is_foto': isFoto,
          'foto': foto,
          'nutrition_items': ingredients,
        }),
      );
      if (response.statusCode == 200) {
        final resp = jsonDecode(response.body);
        print('DEBUG: Full response from POST konsumsi: $resp');

        // Backend returns: {"message": "...", "data": konsumsiObject}
        // ID is in resp['data']['id']
        final newKonsumsiId = resp['data']?['id']?.toString();
        print('DEBUG: Extracted konsumsiId: $newKonsumsiId');

        setState(() {
          konsumsiId = newKonsumsiId;
          isLoading = false;
        });
        // Jangan auto-pop, biarkan user menutup halaman secara manual
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal log konsumsi: ${response.body}')),
        );
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal log konsumsi: $e')));
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteConsumption() async {
    if (konsumsiId == null) return;
    setState(() {
      isDeleting = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User not logged in.')));
        setState(() {
          isDeleting = false;
        });
        return;
      }
      final response = await http.delete(
        Uri.parse('http://192.168.0.105:8080/api/konsumsi/$konsumsiId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Konsumsi berhasil dihapus.')),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal hapus konsumsi: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal hapus konsumsi: $e')));
    }
    setState(() {
      isDeleting = false;
    });
  }

  Future<void> _deleteIngredient(int ingredientIndex) async {
    if (konsumsiId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot delete ingredient: No consumption ID'),
        ),
      );
      return;
    }

    // Check if this is the last ingredient
    if (widget.nutritionResult.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot delete the last ingredient')),
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.white,
            title: const Text('Delete Ingredient'),
            content: Text(
              'Are you sure you want to delete "${widget.nutritionResult[ingredientIndex]['nama_makanan'] ?? 'this ingredient'}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.grey),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: AppColors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const AlertDialog(
            backgroundColor: AppColors.white,
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Deleting ingredient...'),
              ],
            ),
          ),
    );

    try {
      print('DEBUG: Starting ingredient deletion...');
      print('DEBUG: Deleting ingredient at index: $ingredientIndex');
      print(
        'DEBUG: Ingredient name: ${widget.nutritionResult[ingredientIndex]['nama_makanan']}',
      );
      print(
        'DEBUG: Ingredient ID (if exists): ${widget.nutritionResult[ingredientIndex]['id']}',
      );
      print(
        'DEBUG: Total ingredients before deletion: ${widget.nutritionResult.length}',
      );

      await _updateConsumptionAfterDeleteIngredient(ingredientIndex);

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingredient deleted successfully')),
      );

      // Update local state by removing the ingredient
      setState(() {
        widget.nutritionResult.removeAt(ingredientIndex);
      });

      print('DEBUG: Ingredient deletion completed successfully');
    } catch (e) {
      print('DEBUG: Exception occurred during ingredient deletion: $e');

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete ingredient: $e')),
      );
    }
  }

  Future<void> _updateConsumptionAfterDeleteIngredient(
    int ingredientIndex,
  ) async {
    print('DEBUG: _updateConsumptionAfterDeleteIngredient called');
    print('DEBUG: konsumsiId = $konsumsiId');

    if (konsumsiId == null) {
      throw Exception('No consumption ID available');
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userId = prefs.getString('user_id');

      if (token == null || userId == null) {
        throw Exception('User not logged in');
      }

      // Create new ingredients list without the deleted ingredient
      final List<Map<String, dynamic>> updatedIngredients = [];

      for (int i = 0; i < widget.nutritionResult.length; i++) {
        if (i != ingredientIndex) {
          // Skip the ingredient to be deleted
          final item = widget.nutritionResult[i];
          final nutr = item['nutrition_total'] ?? {};
          int kalori = 0;
          if (nutr.isNotEmpty && nutr['kalori'] != null) {
            kalori = (nutr['kalori'] ?? 0).round();
          } else if (item['kalori'] != null) {
            kalori = (item['kalori'] ?? 0).round();
          } else if (item['calories'] != null) {
            kalori = (item['calories'] ?? 0).round();
          }

          updatedIngredients.add({
            'nama_makanan': item['nama_makanan'] ?? '',
            'jumlah': item['jumlah'] ?? '',
            'kalori': kalori,
            'protein': (nutr['protein'] ?? item['protein'] ?? 0).toDouble(),
            'lemak': (nutr['lemak'] ?? item['lemak'] ?? 0).toDouble(),
            'karbohidrat':
                (nutr['karbohidrat'] ?? item['karbohidrat'] ?? 0).toDouble(),
          });
        }
      }

      // Calculate new totals from remaining ingredients
      double totalKalori = 0, totalKarbo = 0, totalProtein = 0, totalLemak = 0;
      for (final ing in updatedIngredients) {
        totalKalori += (ing['kalori'] ?? 0).toDouble();
        totalKarbo += (ing['karbohidrat'] ?? 0).toDouble();
        totalProtein += (ing['protein'] ?? 0).toDouble();
        totalLemak += (ing['lemak'] ?? 0).toDouble();
      }

      final now = DateTime.now();
      final mealType = 'Dinner';
      String foto = widget.imagePath;
      bool isFoto = widget.imagePath.isNotEmpty;

      final String? imageUrl =
          widget.nutritionResult.isNotEmpty
              ? widget.nutritionResult[0]['image_url']
              : null;
      if (!isFoto && imageUrl != null && imageUrl.isNotEmpty) {
        foto = imageUrl;
        isFoto = true;
      }

      final url = 'http://192.168.0.105:8080/api/konsumsi/$konsumsiId';
      final requestBody = {
        'id_user': userId,
        'nama_makanan': foodName,
        'kalori_total': totalKalori,
        'karbohidrat_total': totalKarbo,
        'protein_total': totalProtein,
        'lemak_total': totalLemak,
        'waktu_makan': mealType,
        'tanggal': now.toUtc().toIso8601String(),
        'is_foto': isFoto,
        'foto': foto,
        'soft_deleted': false,
        'is_saved': false,
        'nutrition_items': updatedIngredients,
      };

      print('DEBUG: Making PUT request to: $url');
      print('DEBUG: Updated ingredients count: ${updatedIngredients.length}');
      print('DEBUG: Request body: ${jsonEncode(requestBody)}');

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      print('DEBUG: Response status code: ${response.statusCode}');
      print('DEBUG: Response body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(
          'Server responded with status ${response.statusCode}: ${response.body}',
        );
      }

      print(
        'DEBUG: PUT request for ingredient deletion completed successfully',
      );
    } catch (e) {
      print('DEBUG: Error in _updateConsumptionAfterDeleteIngredient: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> item =
        widget.nutritionResult.isNotEmpty ? widget.nutritionResult[0] : {};
    final String foodImage =
        widget.imagePath.isNotEmpty
            ? widget.imagePath
            : 'assets/images/placeholder.png';
    final String? imageUrl = item['image_url'];
    final String mealType = 'Dinner';
    final int quantity = 1;
    // Build ingredients list & total nutrition
    final List<Map<String, dynamic>> ingredients =
        widget.nutritionResult.isNotEmpty
            ? widget.nutritionResult.map<Map<String, dynamic>>((item) {
              final nutr = item['nutrition_total'] ?? {};
              int kalori = 0;
              if (nutr.isNotEmpty && nutr['kalori'] != null) {
                kalori = (nutr['kalori'] ?? 0).round();
              } else if (item['kalori'] != null) {
                kalori = (item['kalori'] ?? 0).round();
              } else if (item['calories'] != null) {
                kalori = (item['calories'] ?? 0).round();
              }
              return {
                'name': item['nama_makanan'] ?? '',
                'kalori': kalori,
                'jumlah': item['jumlah'] ?? '',
                'protein': (nutr['protein'] ?? item['protein'] ?? 0).toDouble(),
                'lemak': (nutr['lemak'] ?? item['lemak'] ?? 0).toDouble(),
                'karbohidrat':
                    (nutr['karbohidrat'] ?? item['karbohidrat'] ?? 0)
                        .toDouble(),
              };
            }).toList()
            : [
              {
                'name': 'Nasi',
                'kalori': 270,
                'jumlah': '150g',
                'protein': 4,
                'lemak': 1,
                'karbohidrat': 60,
              },
              {
                'name': 'Ayam Pop',
                'kalori': 270,
                'jumlah': '150g',
                'protein': 20,
                'lemak': 15,
                'karbohidrat': 0,
              },
              {
                'name': 'Sambal',
                'kalori': 270,
                'jumlah': '150g',
                'protein': 1,
                'lemak': 2,
                'karbohidrat': 10,
              },
            ];

    // Hitung total nutrisi dari seluruh ingredient
    int totalKalori = 0;
    double totalKarbo = 0, totalProtein = 0, totalLemak = 0;
    for (final ing in ingredients) {
      totalKalori += (ing['kalori'] ?? 0) as int;
      totalKarbo += (ing['karbohidrat'] ?? 0).toDouble();
      totalProtein += (ing['protein'] ?? 0).toDouble();
      totalLemak += (ing['lemak'] ?? 0).toDouble();
    }
    final Map<String, dynamic> nutrition = {
      'calories': totalKalori,
      'carbs': totalKarbo.round(),
      'proteins': totalProtein.round(),
      'fats': totalLemak.round(),
    };
    final bool isNutritionZero = nutrition.values.every((v) => v == 0);
    // Tampilkan warning jika semua nutrisi 0
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border, color: AppColors.black),
            onPressed: () {},
            tooltip: 'Save',
          ),
          IconButton(
            icon:
                isDeleting
                    ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.delete_outline, color: AppColors.red),
            onPressed: isDeleting ? null : _deleteConsumption,
            tooltip: 'Remove',
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(AppBorderRadius.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isNutritionZero)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.yellow[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Nutrisi tidak ditemukan untuk produk ini. Data akan tetap disimpan, namun nilai nutrisi 0.',
                            style: TextStyle(color: Colors.black87),
                          ),
                        ),
                      ),
                    // Gambar makanan
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                      child:
                          widget.imagePath.isNotEmpty
                              ? Image.file(
                                File(foodImage),
                                width: double.infinity,
                                height: 180,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => Image.asset(
                                      'assets/images/placeholder.png',
                                    ),
                              )
                              : (imageUrl != null
                                  ? Image.network(
                                    imageUrl,
                                    width: double.infinity,
                                    height: 180,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Image.asset(
                                              'assets/images/placeholder.png',
                                            ),
                                  )
                                  : Image.asset(
                                    'assets/images/placeholder.png',
                                    width: double.infinity,
                                    height: 180,
                                    fit: BoxFit.cover,
                                  )),
                    ),
                    const SizedBox(height: AppBorderRadius.md),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            foodName,
                            style: TextStyle(
                              fontSize: AppTexts.lg,
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            size: AppIcons.md,
                            color: AppColors.grey,
                          ),
                          onPressed: _editFoodName,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppBorderRadius.md),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppBorderRadius.md,
                        vertical: AppBorderRadius.sm,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: AppBorderRadius.md),
                          DropdownButton<String>(
                            value: mealType,
                            underline: const SizedBox(),
                            items:
                                ['Breakfast', 'Lunch', 'Dinner']
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (v) {},
                          ),
                          const SizedBox(width: AppBorderRadius.md),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.remove,
                                  size: AppIcons.md,
                                ),
                                onPressed: () {},
                              ),
                              Text(
                                '$quantity',
                                style: TextStyle(fontSize: AppTexts.md),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, size: AppIcons.md),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppBorderRadius.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _NutritionCard(
                          icon: Icons.local_fire_department,
                          value: nutrition['calories'],
                          label: 'Calories',
                          color: AppColors.blue,
                        ),
                        _NutritionCard(
                          icon: Icons.bubble_chart,
                          value: nutrition['carbs'],
                          label: 'Carbs',
                          color: AppColors.yellow,
                        ),
                        _NutritionCard(
                          icon: Icons.fitness_center,
                          value: nutrition['proteins'],
                          label: 'Protein',
                          color: AppColors.red,
                        ),
                        _NutritionCard(
                          icon: Icons.eco,
                          value: nutrition['fats'],
                          label: 'Fat',
                          color: AppColors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppBorderRadius.md),
                    Text(
                      'Ingredients',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: AppTexts.md,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: AppBorderRadius.sm),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: ingredients.length,
                        separatorBuilder:
                            (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final ing = ingredients[index];
                          return ListTile(
                            title: Text(
                              ing['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            // Pada ListTile ingredient, subtitle hanya tampilkan kalori dan jumlah
                            subtitle: Text(
                              '${ing['kalori']} cal  ${ing['jumlah']}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: AppColors.red,
                              ),
                              onPressed: () => _deleteIngredient(index),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppBorderRadius.lg),
                    Button(
                      text: '+ Add Ingredients',
                      variant: ButtonVariant.primary,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
    );
  }
}

class _NutritionCard extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;
  final Color color;

  const _NutritionCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: AppIcons.lg),
          const SizedBox(height: 4),
          Text(
            '$value${label == 'kalori' ? '' : 'g'}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: AppTexts.md,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: AppTexts.sm, color: AppColors.darkGrey),
          ),
        ],
      ),
    );
  }
}
