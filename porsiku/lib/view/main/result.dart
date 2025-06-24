import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:porsiku/constants/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ResultPage extends StatefulWidget {
  final String foodListText;
  final List nutritionResult;
  final String imagePath;
  final String?
  existingKonsumsiId; // ID konsumsi yang sudah ada (untuk view/edit mode)
  final bool
  isViewMode; // true jika membuka untuk view/edit, false untuk create baru

  const ResultPage({
    super.key,
    required this.foodListText,
    required this.nutritionResult,
    required this.imagePath,
    this.existingKonsumsiId,
    this.isViewMode = false, // default false untuk backward compatibility
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> with TickerProviderStateMixin {
  String? konsumsiId;
  bool isDeleting = false;
  bool isLoading = true;
  bool isSaved = false;
  bool isSaving = false;
  late String foodName;
  int quantity = 1;
  late String mealType;

  // Animation controllers
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _nutritionController;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _nutritionController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    final item =
        widget.nutritionResult.isNotEmpty ? widget.nutritionResult[0] : {};
    foodName = item['nama_makanan'] ?? 'Unknown Product';

    if (widget.isViewMode) {
      // View/Edit mode: gunakan konsumsiId yang sudah ada
      konsumsiId = widget.existingKonsumsiId;
      // Ambil meal type dari data yang ada jika tersedia
      mealType = item['waktu_makan'] ?? _getCurrentMealType();
      quantity = item['quantity'] ?? 1;
      // Ambil status saved dari data yang ada
      isSaved = item['is_saved'] ?? false;
      // Set loading false karena tidak perlu POST baru
      isLoading = false;
      _startAnimations();
      print(
        'DEBUG: View mode - using existing konsumsiId: $konsumsiId, isSaved: $isSaved',
      );
    } else {
      // Create mode: auto-detect meal type dan buat log baru
      mealType = _getCurrentMealType();
      _logConsumption();
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _nutritionController.dispose();
    super.dispose();
  }

  void _startAnimations() {
    _slideController.forward();
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _nutritionController.forward();
    });
  }

  String _getCurrentMealType() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 5 && hour < 11) {
      return 'Breakfast';
    } else if (hour >= 11 && hour < 17) {
      return 'Lunch';
    } else {
      return 'Dinner';
    }
  }

  void _incrementQuantity() {
    setState(() {
      quantity++;
    });
    HapticFeedback.lightImpact();
    _scaleController.forward().then((_) => _scaleController.reverse());
    _updateQuantityOnBackend();
  }

  void _decrementQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
      HapticFeedback.lightImpact();
      _scaleController.forward().then((_) => _scaleController.reverse());
      _updateQuantityOnBackend();
    }
  }

  void _onMealTypeChanged(String? newMealType) {
    if (newMealType != null && newMealType != mealType) {
      setState(() {
        mealType = newMealType;
      });
      _updateMealTypeOnBackend();
    }
  }

  Future<void> _updateQuantityOnBackend() async {
    if (konsumsiId != null) {
      try {
        await _updateConsumptionData();
        print('DEBUG: Quantity updated successfully to $quantity');
      } catch (e) {
        print('DEBUG: Failed to update quantity: $e');
        // Don't show error to user for quantity updates as it's real-time
      }
    }
  }

  Future<void> _updateMealTypeOnBackend() async {
    if (konsumsiId != null) {
      try {
        await _updateConsumptionData();
        print('DEBUG: Meal type updated successfully to $mealType');
      } catch (e) {
        print('DEBUG: Failed to update meal type: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update meal type: $e')),
        );
      }
    }
  }

  Future<void> _editFoodName() async {
    final controller = TextEditingController(text: foodName);
    final result = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
                backgroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                ),
                title: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                      ),
                      child: Icon(
                        Icons.edit_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    const Text('Edit Food Name'),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: controller,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Enter food name...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppBorderRadius.md,
                          ),
                          borderSide: BorderSide(color: AppColors.lightGrey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppBorderRadius.md,
                          ),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        contentPadding: EdgeInsets.all(AppSpacing.lg),
                        filled: true,
                        fillColor: AppColors.lightGrey.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  ElevatedButton(
                    onPressed:
                        () => Navigator.pop(context, controller.text.trim()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                      ),
                    ),
                    child: const Text('Save'),
                  ),
                ],
              )
              .animate()
              .fadeIn(duration: 300.ms)
              .scale(begin: const Offset(0.8, 0.8)),
    );

    if (result != null && result.isNotEmpty && result != foodName) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              backgroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              ),
              content: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(width: AppSpacing.lg),
                  const Text('Updating food name...'),
                ],
              ),
            ).animate().fadeIn(duration: 200.ms),
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
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: AppColors.white),
                SizedBox(width: AppSpacing.sm),
                const Text('Food name updated successfully'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
            ),
          ),
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
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_rounded, color: AppColors.white),
                SizedBox(width: AppSpacing.sm),
                Text('Failed to update: ${e.toString()}'),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
            ),
          ),
        );
      }
    }
  }

  Future<void> _updateFoodNameOnBackend() async {
    print('DEBUG: _updateFoodNameOnBackend called');
    await _updateConsumptionData();
  }

  Future<void> _updateConsumptionData() async {
    print('DEBUG: _updateConsumptionData called');
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
      print('DEBUG: User ID: $userId');
      print('DEBUG: Current quantity: $quantity');
      print('DEBUG: Current meal type: $mealType');

      // Calculate nutrition with quantity multiplier
      final List<Map<String, dynamic>> ingredients =
          widget.nutritionResult.isNotEmpty
              ? widget.nutritionResult.map<Map<String, dynamic>>((item) {
                final nutr = item['nutrition_total'] ?? {};
                int baseKalori = 0;
                if (nutr.isNotEmpty && nutr['kalori'] != null) {
                  baseKalori = (nutr['kalori'] ?? 0).round();
                } else if (item['kalori'] != null) {
                  baseKalori = (item['kalori'] ?? 0).round();
                } else if (item['calories'] != null) {
                  baseKalori = (item['calories'] ?? 0).round();
                }

                double baseProtein =
                    (nutr['protein'] ?? item['protein'] ?? 0).toDouble();
                double baseLemak =
                    (nutr['lemak'] ?? item['lemak'] ?? 0).toDouble();
                double baseKarbohidrat =
                    (nutr['karbohidrat'] ?? item['karbohidrat'] ?? 0)
                        .toDouble();

                return {
                  'nama_makanan': item['nama_makanan'] ?? '',
                  'jumlah': item['jumlah'] ?? '',
                  'kalori': (baseKalori * quantity).round(),
                  'protein': (baseProtein * quantity),
                  'lemak': (baseLemak * quantity),
                  'karbohidrat': (baseKarbohidrat * quantity),
                };
              }).toList()
              : [];

      // Calculate total from all ingredients with quantity
      double totalKalori = 0, totalKarbo = 0, totalProtein = 0, totalLemak = 0;
      for (final ing in ingredients) {
        totalKalori += (ing['kalori'] ?? 0).toDouble();
        totalKarbo += (ing['karbohidrat'] ?? 0).toDouble();
        totalProtein += (ing['protein'] ?? 0).toDouble();
        totalLemak += (ing['lemak'] ?? 0).toDouble();
      }

      final now = DateTime.now();
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

      final url =
          'https://porsiku-nutrition-estimation-tracker-production.up.railway.app/api/konsumsi/$konsumsiId';
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
        'is_saved': isSaved, // Use current saved status
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
        Uri.parse(
          'https://porsiku-nutrition-estimation-tracker-production.up.railway.app/api/konsumsi',
        ),
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
        _startAnimations();
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
        Uri.parse(
          'https://porsiku-nutrition-estimation-tracker-production.up.railway.app/api/konsumsi/$konsumsiId',
        ),
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
            'kalori': (kalori * quantity).round(),
            'protein':
                ((nutr['protein'] ?? item['protein'] ?? 0).toDouble() *
                    quantity),
            'lemak':
                ((nutr['lemak'] ?? item['lemak'] ?? 0).toDouble() * quantity),
            'karbohidrat':
                ((nutr['karbohidrat'] ?? item['karbohidrat'] ?? 0).toDouble() *
                    quantity),
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

      final url =
          'https://porsiku-nutrition-estimation-tracker-production.up.railway.app/api/konsumsi/$konsumsiId';
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

  Future<void> _addIngredient() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
                backgroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                ),
                title: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                      ),
                      child: Icon(
                        Icons.add_circle_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    const Text('Add Ingredient'),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: controller,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Enter ingredient name...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppBorderRadius.md,
                          ),
                          borderSide: BorderSide(color: AppColors.lightGrey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppBorderRadius.md,
                          ),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        contentPadding: EdgeInsets.all(AppSpacing.lg),
                        filled: true,
                        fillColor: AppColors.lightGrey.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  ElevatedButton(
                    onPressed:
                        () => Navigator.pop(context, controller.text.trim()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                      ),
                    ),
                    child: const Text('Add'),
                  ),
                ],
              )
              .animate()
              .fadeIn(duration: 300.ms)
              .scale(begin: const Offset(0.8, 0.8)),
    );

    if (result != null && result.isNotEmpty) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              backgroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              ),
              content: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(width: AppSpacing.lg),
                  const Text('Adding ingredient...'),
                ],
              ),
            ).animate().fadeIn(duration: 200.ms),
      );

      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token == null) {
          throw Exception('User not logged in');
        }

        // Send request to `/api/nutri-estimation`
        final response = await http.post(
          Uri.parse(
            'https://porsiku-nutrition-estimation-tracker-production.up.railway.app/api/nutri-estimation',
          ),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'food_list': result}),
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          final resultData = responseData['result'];
          if (resultData != null && resultData.isNotEmpty) {
            final newIngredient = resultData[0];

            // Add ingredient to local state
            setState(() {
              widget.nutritionResult.add({
                'nama_makanan': newIngredient['nama_makanan'] ?? '',
                'jumlah': newIngredient['jumlah'] ?? '',
                'nutrition_total': {
                  'kalori': newIngredient['kalori'] ?? 0,
                  'protein': newIngredient['protein'] ?? 0.0,
                  'lemak': newIngredient['lemak'] ?? 0.0,
                  'karbohidrat': newIngredient['karbohidrat'] ?? 0.0,
                },
              });
            });

            // Update consumption on backend
            if (konsumsiId != null) {
              await _updateConsumptionAfterAddIngredient();
            } // Close loading dialog
            if (mounted) Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: AppColors.white),
                    SizedBox(width: AppSpacing.sm),
                    const Text('Ingredient added successfully'),
                  ],
                ),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
              ),
            );
          } else {
            throw Exception('Invalid data format from backend');
          }
        } else {
          throw Exception('Failed to add ingredient: ${response.body}');
        }
      } catch (e) {
        // Close loading dialog
        if (mounted) Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_rounded, color: AppColors.white),
                SizedBox(width: AppSpacing.sm),
                Text('Failed to add ingredient: $e'),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
            ),
          ),
        );
      }
    }
  }

  Future<void> _updateConsumptionAfterAddIngredient() async {
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

      // Recalculate totals
      double totalKalori = 0, totalKarbo = 0, totalProtein = 0, totalLemak = 0;
      final List<Map<String, dynamic>> updatedIngredients =
          widget.nutritionResult.map((item) {
            final nutr = item['nutrition_total'] ?? {};
            int kalori = (nutr['kalori'] ?? item['kalori'] ?? 0).round();
            return {
              'nama_makanan': item['nama_makanan'] ?? '',
              'jumlah': item['jumlah'] ?? '',
              'kalori': kalori,
              'protein': (nutr['protein'] ?? item['protein'] ?? 0).toDouble(),
              'lemak': (nutr['lemak'] ?? item['lemak'] ?? 0).toDouble(),
              'karbohidrat':
                  (nutr['karbohidrat'] ?? item['karbohidrat'] ?? 0).toDouble(),
            };
          }).toList();

      for (final ing in updatedIngredients) {
        totalKalori += (ing['kalori'] ?? 0).toDouble();
        totalKarbo += (ing['karbohidrat'] ?? 0).toDouble();
        totalProtein += (ing['protein'] ?? 0).toDouble();
        totalLemak += (ing['lemak'] ?? 0).toDouble();
      }
      final now = DateTime.now();
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

      final url =
          'https://porsiku-nutrition-estimation-tracker-production.up.railway.app/api/konsumsi/$konsumsiId';
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
        'is_saved': isSaved,
        'nutrition_items': updatedIngredients,
      };

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update consumption: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _toggleSaveMeal() async {
    if (konsumsiId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot save meal: No consumption ID')),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        throw Exception('User not logged in');
      }

      print(
        'DEBUG: ${isSaved ? 'Unsaving' : 'Saving'} meal with ID: $konsumsiId',
      );

      if (isSaved) {
        // Unsave meal - we need to implement this endpoint or use PUT to update is_saved to false
        await _unsaveMeal(token);
      } else {
        // Save meal
        await _saveMeal(token);
      }

      setState(() {
        isSaved = !isSaved;
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isSaved ? 'Meal saved successfully' : 'Meal unsaved successfully',
          ),
        ),
      );

      print('DEBUG: Meal ${isSaved ? 'saved' : 'unsaved'} successfully');
    } catch (e) {
      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to ${isSaved ? 'unsave' : 'save'} meal: $e'),
        ),
      );

      print('DEBUG: Error ${isSaved ? 'unsaving' : 'saving'} meal: $e');
    }
  }

  Future<void> _saveMeal(String token) async {
    final url =
        'https://porsiku-nutrition-estimation-tracker-production.up.railway.app/api/save_konsumsi/$konsumsiId';
    print('DEBUG: Making POST request to save meal: $url');

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('DEBUG: Save meal response status: ${response.statusCode}');
    print('DEBUG: Save meal response body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception(
        'Server responded with status ${response.statusCode}: ${response.body}',
      );
    }
  }

  Future<void> _unsaveMeal(String token) async {
    // Use PUT endpoint to update is_saved status to false
    final url =
        'https://porsiku-nutrition-estimation-tracker-production.up.railway.app/api/save_konsumsi/$konsumsiId';
    print('DEBUG: Making PUT request to unsave meal: $url');

    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'is_saved': false}),
    );

    print('DEBUG: Unsave response: ${response.statusCode} - ${response.body}');

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body)['error'] ?? 'Unknown error';
      throw Exception('Failed to unsave meal: $error');
    }
  }

  // Helper method to determine if path is URL or local file path
  bool _isNetworkUrl(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }

  // Helper method to build appropriate image widget
  Widget _buildFoodImage(String foodImage, String? imageUrl) {
    print('DEBUG: Building food image - widget.imagePath: ${widget.imagePath}');
    print('DEBUG: Building food image - imageUrl: $imageUrl');

    // Priority: 1. Widget imagePath (if not empty), 2. imageUrl from nutrition result, 3. placeholder
    if (widget.imagePath.isNotEmpty) {
      if (_isNetworkUrl(widget.imagePath)) {
        // Network URL (for saved meals)
        print('DEBUG: Using network image: ${widget.imagePath}');
        return ClipRRect(
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          child: Image.network(
            widget.imagePath,
            width: double.infinity,
            height: 300,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  color: AppColors.lightGrey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    value:
                        loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                    color: AppColors.primary,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              print('DEBUG: Network image error: $error');
              return _buildPlaceholderImage();
            },
          ),
        );
      } else {
        // Local file path (for camera/gallery images)
        print('DEBUG: Using local file image: ${widget.imagePath}');
        return ClipRRect(
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          child: Image.file(
            File(widget.imagePath),
            width: double.infinity,
            height: 300,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('DEBUG: File image error: $error');
              return _buildPlaceholderImage();
            },
          ),
        );
      }
    } else if (imageUrl != null && imageUrl.isNotEmpty) {
      // Use imageUrl from nutrition result
      print('DEBUG: Using imageUrl from nutrition result: $imageUrl');
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        child: Image.network(
          imageUrl,
          width: double.infinity,
          height: 300,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.lightGrey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  value:
                      loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                  color: AppColors.primary,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            print('DEBUG: Nutrition result image error: $error');
            return _buildPlaceholderImage();
          },
        ),
      );
    } else {
      // Default placeholder
      print('DEBUG: Using placeholder image');
      return _buildPlaceholderImage();
    }
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.lightGrey.withOpacity(0.3),
            AppColors.lightGrey.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
            ),
            child: Icon(
              Icons.restaurant_outlined,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'No Image Available',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              fontWeight: AppTexts.medium,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Photo not available for this meal',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
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

    // Build ingredients list & total nutrition with quantity multiplier
    final List<Map<String, dynamic>> ingredients =
        widget.nutritionResult.isNotEmpty
            ? widget.nutritionResult.map<Map<String, dynamic>>((item) {
              final nutr = item['nutrition_total'] ?? {};
              int baseKalori = 0;
              if (nutr.isNotEmpty && nutr['kalori'] != null) {
                baseKalori = (nutr['kalori'] ?? 0).round();
              } else if (item['kalori'] != null) {
                baseKalori = (item['kalori'] ?? 0).round();
              } else if (item['calories'] != null) {
                baseKalori = (item['calories'] ?? 0).round();
              }

              double baseProtein =
                  (nutr['protein'] ?? item['protein'] ?? 0).toDouble();
              double baseLemak =
                  (nutr['lemak'] ?? item['lemak'] ?? 0).toDouble();
              double baseKarbohidrat =
                  (nutr['karbohidrat'] ?? item['karbohidrat'] ?? 0).toDouble();

              return {
                'name': item['nama_makanan'] ?? '',
                'kalori': (baseKalori * quantity).round(),
                'jumlah': item['jumlah'] ?? '',
                'protein': (baseProtein * quantity),
                'lemak': (baseLemak * quantity),
                'karbohidrat': (baseKarbohidrat * quantity),
              };
            }).toList()
            : [];
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child:
            isLoading
                ? _buildLoadingState()
                : _buildContent(
                  foodImage,
                  imageUrl,
                  nutrition,
                  ingredients,
                  isNutritionZero,
                ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: AppGradients.primary,
                  borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                ),
                child: const Icon(
                  Icons.restaurant_outlined,
                  size: 50,
                  color: AppColors.white,
                ),
              )
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 1500.ms)
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.2, 1.2),
                duration: 1200.ms,
                curve: Curves.easeInOut,
              ),
          SizedBox(height: AppSpacing.xl),
          Text(
                'Analyzing your meal...',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.textSecondary,
                ),
              )
              .animate()
              .fadeIn(duration: 800.ms, delay: 300.ms)
              .slideY(begin: 0.3, end: 0),
          SizedBox(height: AppSpacing.md),
          Text(
            'Please wait while we process your nutrition data',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 600.ms, delay: 600.ms),
        ],
      ),
    );
  }

  Widget _buildContent(
    String foodImage,
    String? imageUrl,
    Map<String, dynamic> nutrition,
    List<Map<String, dynamic>> ingredients,
    bool isNutritionZero,
  ) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Premium App Bar
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          elevation: 0,
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.textPrimary,
          leadingWidth: 72, // Accommodate padding
          titleSpacing: 0, // Remove default title spacing
          leading: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Container(
                  margin: EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(
                      AppBorderRadius.infinity,
                    ),
                    boxShadow: AppShadows.card,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                )
                .animate()
                .fadeIn(delay: 200.ms)
                .scale(begin: const Offset(0.8, 0.8)),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                        margin: EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(
                            AppBorderRadius.infinity,
                          ),
                          boxShadow: AppShadows.card,
                        ),
                        child: IconButton(
                          icon:
                              isSaving
                                  ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary,
                                    ),
                                  )
                                  : Icon(
                                    isSaved
                                        ? Icons.bookmark_rounded
                                        : Icons.bookmark_border_rounded,
                                    color:
                                        isSaved
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                  ),
                          onPressed:
                              isSaving
                                  ? null
                                  : () {
                                    HapticFeedback.mediumImpact();
                                    _toggleSaveMeal();
                                  },
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 300.ms)
                      .scale(begin: const Offset(0.8, 0.8)),
                  Container(
                        margin: EdgeInsets.only(
                          right: AppSpacing.sm,
                          top: AppSpacing.sm,
                          bottom: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(
                            AppBorderRadius.infinity,
                          ),
                          boxShadow: AppShadows.card,
                        ),
                        child: IconButton(
                          icon:
                              isDeleting
                                  ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.error,
                                    ),
                                  )
                                  : const Icon(
                                    Icons.delete_outline_rounded,
                                    color: AppColors.error,
                                  ),
                          onPressed:
                              isDeleting
                                  ? null
                                  : () {
                                    HapticFeedback.mediumImpact();
                                    _showDeleteConfirmation();
                                  },
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 400.ms)
                      .scale(begin: const Offset(0.8, 0.8)),
                ],
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Food Image with Gradient Overlay
                _buildFoodImage(foodImage, imageUrl)
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scale(
                      begin: const Offset(1.1, 1.1),
                      end: const Offset(1.0, 1.0),
                    ),
                // Gradient Overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.7),
                      ],
                      stops: const [0.0, 0.7, 1.0],
                    ),
                  ),
                ),
                // Food Name Overlay
                Positioned(
                  bottom: AppSpacing.lg,
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                            children: [
                              Expanded(
                                child: Text(
                                  foodName,
                                  style: AppTextStyles.h2.copyWith(
                                    color: AppColors.white,
                                    fontWeight: AppTexts.bold,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.5),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(AppSpacing.xs),
                                decoration: BoxDecoration(
                                  color: AppColors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(
                                    AppBorderRadius.sm,
                                  ),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.edit_rounded,
                                    color: AppColors.white,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    _editFoodName();
                                  },
                                ),
                              ),
                            ],
                          )
                          .animate()
                          .fadeIn(delay: 800.ms, duration: 600.ms)
                          .slideY(begin: 0.3, end: 0),
                      SizedBox(height: AppSpacing.sm),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nutrition Warning
                if (isNutritionZero) _buildNutritionWarning(),

                // Meal Controls
                _buildMealControls(),

                SizedBox(height: AppSpacing.xl),

                // Nutrition Cards
                _buildNutritionCards(nutrition),

                SizedBox(height: AppSpacing.xl),

                // Ingredients Section
                _buildIngredientsSection(ingredients),

                SizedBox(height: AppSpacing.xl),

                // Add Ingredient Button
                _buildAddIngredientButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionWarning() {
    return Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSpacing.lg),
          margin: EdgeInsets.only(bottom: AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.warning.withOpacity(0.1),
                AppColors.warning.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
            border: Border.all(
              color: AppColors.warning.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.warning,
                  size: 20,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nutrition Data Unavailable',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: AppTexts.semiBold,
                        color: AppColors.warning,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      'No nutrition information found for this product. Data will be saved with zero nutritional values.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: 300.ms, duration: 600.ms)
        .slideY(begin: -0.3, end: 0)
        .shimmer(delay: 1000.ms, duration: 1500.ms);
  }

  Widget _buildMealControls() {
    return Container(
          padding: EdgeInsets.all(AppSpacing.md), // Reduced from lg to md
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
            boxShadow: AppShadows.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Remove the "Meal Configuration" title
              Row(
                children: [
                  // Meal Type Selector
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Meal Type',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: AppTexts.medium,
                          ),
                        ),
                        SizedBox(height: AppSpacing.sm),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.lightGrey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(
                              AppBorderRadius.md,
                            ),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: mealType,
                              isExpanded: true,
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: AppColors.primary,
                                size: 18,
                              ),
                              items: [
                                _buildMealTypeItem(
                                  'Breakfast',
                                  Icons.wb_sunny_rounded,
                                ),
                                _buildMealTypeItem(
                                  'Lunch',
                                  Icons.wb_cloudy_rounded,
                                ),
                                _buildMealTypeItem(
                                  'Dinner',
                                  Icons.nightlight_round_rounded,
                                ),
                              ],
                              onChanged: (value) {
                                HapticFeedback.lightImpact();
                                _onMealTypeChanged(value);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: AppSpacing.md), // Quantity Controller
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quantity',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: AppTexts.medium,
                          ),
                        ),
                        SizedBox(height: AppSpacing.sm),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.lightGrey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(
                              AppBorderRadius.md,
                            ),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              _buildQuantityButton(
                                Icons.remove_rounded,
                                quantity > 1 ? _decrementQuantity : null,
                              ),
                              Expanded(
                                child: AnimatedBuilder(
                                  animation: _scaleController,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale:
                                          1.0 + (_scaleController.value * 0.1),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          vertical: AppSpacing.sm,
                                        ),
                                        child: Text(
                                          '$quantity',
                                          style: AppTextStyles.h4.copyWith(
                                            fontWeight: AppTexts.bold,
                                            color: AppColors.primary,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              _buildQuantityButton(
                                Icons.add_rounded,
                                _incrementQuantity,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: 400.ms, duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  DropdownMenuItem<String> _buildMealTypeItem(String value, IconData icon) {
    return DropdownMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          SizedBox(width: AppSpacing.sm),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: AppTexts.medium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback? onPressed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        child: Container(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Icon(
            icon,
            color:
                onPressed != null ? AppColors.primary : AppColors.textTertiary,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionCards(Map<String, dynamic> nutrition) {
    final nutritionData = [
      {
        'icon': Icons.local_fire_department_rounded,
        'value': nutrition['calories'],
        'label': 'Calories',
        'unit': 'cal',
        'color': AppColors.red,
        'gradient': [AppColors.red, const Color(0xFFFF6B6B)],
      },
      {
        'icon': Icons.bakery_dining_rounded,
        'value': nutrition['carbs'],
        'label': 'Carbs',
        'unit': 'g',
        'color': AppColors.yellow,
        'gradient': [AppColors.yellow, const Color(0xFFFFD93D)],
      },
      {
        'icon': Icons.fitness_center_rounded,
        'value': nutrition['proteins'],
        'label': 'Protein',
        'unit': 'g',
        'color': AppColors.blue,
        'gradient': [AppColors.blue, const Color(0xFF4DABF7)],
      },
      {
        'icon': Icons.eco_rounded,
        'value': nutrition['fats'],
        'label': 'Fats',
        'unit': 'g',
        'color': AppColors.green,
        'gradient': [AppColors.green, const Color(0xFF51CF66)],
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
              'Nutrition Facts',
              style: AppTextStyles.h4.copyWith(fontWeight: AppTexts.semiBold),
            )
            .animate()
            .fadeIn(delay: 500.ms, duration: 600.ms)
            .slideX(begin: -0.3, end: 0),
        SizedBox(height: AppSpacing.sm),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio:
                2.2, // Increased from 1.4 to 2.2 for more compact height
          ),
          itemCount: nutritionData.length,
          itemBuilder: (context, index) {
            final data = nutritionData[index];
            return AnimatedBuilder(
              animation: _nutritionController,
              builder: (context, child) {
                final animation = Tween<double>(begin: 0, end: 1).animate(
                  CurvedAnimation(
                    parent: _nutritionController,
                    curve: Interval(
                      index * 0.2,
                      0.6 + (index * 0.1),
                      curve: Curves.easeOutBack,
                    ),
                  ),
                );

                return Transform.scale(
                  scale: animation.value,
                  child: _PremiumNutritionCard(
                    icon: data['icon'] as IconData,
                    value: data['value'] as int,
                    label: data['label'] as String,
                    unit: data['unit'] as String,
                    color: data['color'] as Color,
                    gradient: data['gradient'] as List<Color>,
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildIngredientsSection(List<Map<String, dynamic>> ingredients) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
              children: [
                Text(
                  'Ingredients',
                  style: AppTextStyles.h4.copyWith(
                    fontWeight: AppTexts.semiBold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      AppBorderRadius.infinity,
                    ),
                  ),
                  child: Text(
                    '${ingredients.length} items',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: AppTexts.medium,
                    ),
                  ),
                ),
              ],
            )
            .animate()
            .fadeIn(delay: 600.ms, duration: 600.ms)
            .slideX(begin: -0.3, end: 0),
        SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
            boxShadow: AppShadows.card,
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: ingredients.length,
            separatorBuilder:
                (context, index) => Divider(
                  height: 1,
                  color: AppColors.lightGrey.withOpacity(0.3),
                ),
            itemBuilder: (context, index) {
              final ing = ingredients[index];
              return _PremiumIngredientTile(
                name: ing['name'],
                calories: ing['kalori'],
                quantity: ing['jumlah'],
                onDelete: () => _deleteIngredient(index),
                animationDelay: (700 + (index * 100)).ms,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddIngredientButton() {
    return Container(
          width: double.infinity,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.mediumImpact();
                _addIngredient();
              },
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              child: Container(
                padding: EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                      ),
                      child: Icon(
                        Icons.add_rounded,
                        color: AppColors.white,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Text(
                      'Add Ingredient',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.white,
                        fontWeight: AppTexts.semiBold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: 800.ms, duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
            ),
            title: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                  ),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error,
                    size: 24,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                const Text('Delete Meal'),
              ],
            ),
            content: const Text(
              'Are you sure you want to delete this meal? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteConsumption();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.white,
                ),
                child: const Text('Delete'),
              ),
            ],
          ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.8, 0.8)),
    );
  }
}

class _PremiumNutritionCard extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;
  final String unit;
  final Color color;
  final List<Color> gradient;

  const _PremiumNutritionCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.unit,
    required this.color,
    required this.gradient,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md), // Reduced from lg to md
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [gradient[0].withOpacity(0.1), gradient[1].withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        // Changed from Column to Row for horizontal layout
        children: [
          // Icon container
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(AppBorderRadius.sm),
            ),
            child: Icon(icon, color: AppColors.white, size: 20),
          ),
          SizedBox(width: AppSpacing.md), // Spacing between icon and content
          // Content column (value and label)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Make column take minimum space
              children: [
                // Value with unit
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$value',
                        style: AppTextStyles.h4.copyWith(
                          // Reduced from h3 to h4
                          color: color,
                          fontWeight: AppTexts.bold,
                        ),
                      ),
                      TextSpan(
                        text: ' $unit',
                        style: AppTextStyles.caption.copyWith(
                          // Reduced from bodySmall to caption
                          color: AppColors.textTertiary,
                          fontWeight: AppTexts.medium,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2), // Reduced spacing
                // Label
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    // Reduced from bodySmall to caption
                    color: AppColors.textSecondary,
                    fontWeight: AppTexts.medium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumIngredientTile extends StatelessWidget {
  final String name;
  final int calories;
  final String quantity;
  final VoidCallback onDelete;
  final Duration animationDelay;

  const _PremiumIngredientTile({
    required this.name,
    required this.calories,
    required this.quantity,
    required this.onDelete,
    required this.animationDelay,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Could add ingredient detail view here
            },
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md), // Reduced from lg to md
              child: Row(
                children: [
                  Container(
                    width: 40, // Reduced from 48 to 40
                    height: 40, // Reduced from 48 to 40
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.1),
                          AppColors.primary.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppBorderRadius.md),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.restaurant_outlined,
                      color: AppColors.primary,
                      size: 18, // Reduced from 20 to 18
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: AppTextStyles.bodyMedium.copyWith(
                            // Reduced from bodyLarge to bodyMedium
                            fontWeight: AppTexts.semiBold,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                  AppBorderRadius.sm,
                                ),
                              ),
                              child: Text(
                                '$calories cal',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.red,
                                  fontWeight: AppTexts.medium,
                                ),
                              ),
                            ),
                            SizedBox(width: AppSpacing.sm),
                            Text(
                              quantity,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onDelete();
                      },
                      borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                      child: Container(
                        padding: EdgeInsets.all(AppSpacing.sm),
                        child: Icon(
                          Icons.close_rounded,
                          color: AppColors.error,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: animationDelay, duration: 400.ms)
        .slideX(begin: 0.3, end: 0);
  }
}
