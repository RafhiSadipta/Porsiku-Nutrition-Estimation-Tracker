import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../../constants/constants.dart';

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
          errorMessage = 'Failed to fetch saved meals: \n${response.body}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: $e';
        isLoading = false;
      });
    }
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
                          'Saved Meals',
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
              child:
                  isLoading
                      ? _buildLoadingState()
                      : errorMessage != null
                      ? _buildErrorState()
                      : savedMeals.isEmpty
                      ? _buildEmptyState()
                      : _buildMealsList(),
            ),
          ],
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
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.2),
                      AppColors.primary.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                    strokeWidth: 3,
                  ),
                ),
              )
              .animate(onPlay: (controller) => controller.repeat())
              .rotate(duration: 2000.ms),

          SizedBox(height: AppSpacing.xl),

          Text(
            'Loading saved meals...',
            style: AppTextStyles.h4.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),

          SizedBox(height: AppSpacing.sm),

          Text(
            'Please wait a moment',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.error.withOpacity(0.2),
                    AppColors.error.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: 48,
              ),
            ).animate().scale(curve: Curves.elasticOut),

            SizedBox(height: AppSpacing.xl),

            Text(
              'An Error Occurred',
              style: AppTextStyles.h4.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),

            SizedBox(height: AppSpacing.md),

            Text(
              errorMessage!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),

            SizedBox(height: AppSpacing.xl),

            ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    _fetchSavedMeals();
                  },
                  icon: Icon(Icons.refresh_rounded, size: 18),
                  label: Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                    ),
                  ),
                )
                .animate()
                .fadeIn(delay: 600.ms)
                .scale(begin: const Offset(0.8, 0.8)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.lightGrey.withOpacity(0.3),
                    AppColors.lightGrey.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.bookmark_border_rounded,
                color: AppColors.textSecondary,
                size: 56,
              ),
            ).animate().scale(curve: Curves.elasticOut),

            SizedBox(height: AppSpacing.xl),

            Text(
              'No Saved Meals Yet',
              style: AppTextStyles.h4.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),

            SizedBox(height: AppSpacing.md),

            Text(
              'Save your favorite meals for easier access later',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),

            SizedBox(height: AppSpacing.xl),

            ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.restaurant_menu_rounded, size: 18),
                  label: Text('Explore Food'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                    ),
                  ),
                )
                .animate()
                .fadeIn(delay: 600.ms)
                .scale(begin: const Offset(0.8, 0.8)),
          ],
        ),
      ),
    );
  }

  Widget _buildMealsList() {
    return RefreshIndicator(
      onRefresh: _fetchSavedMeals,
      color: AppColors.primary,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: EdgeInsets.all(AppSpacing.lg),
        itemCount: savedMeals.length,
        separatorBuilder: (_, __) => SizedBox(height: AppSpacing.xs),
        itemBuilder: (context, index) {
          final meal = savedMeals[index];
          return _buildMealCard(meal, index);
        },
      ),
    );
  }

  Widget _buildMealCard(Map<String, dynamic> meal, int index) {
    final mealName = meal['nama_makanan'] ?? 'Unknown Food';

    return Container(
          margin: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: AppColors.lightGrey.withOpacity(0.3),
              width: 0.5,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Custom Header with meal name and time in column
                Row(
                  children: [
                    // Food Image or Icon
                    _buildMealImage(meal),
                    SizedBox(width: AppSpacing.sm),
                    // Title and meal time in column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Meal name
                          Text(
                            mealName,
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: AppSpacing.xs),
                          // Meal time with icon
                          Row(
                            children: [
                              Icon(
                                _getMealTimeIcon(
                                  meal['waktu_makan'] ?? 'saved',
                                ),
                                size: AppIcons.xs,
                                color: AppColors.info,
                              ),
                              SizedBox(width: AppSpacing.xs),
                              Text(
                                _getMealTimeText(meal['waktu_makan']),
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Delete button
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: AppColors.error,
                          size: AppIcons.sm,
                        ),
                        onPressed: () => _showDeleteDialog(meal),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.md),
                // Content
                _buildMealContent(meal),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 100 * index), duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildMealContent(Map<String, dynamic> meal) {
    // Ensure all values are converted to double/int safely
    double toDouble(dynamic value) {
      if (value is int) return value.toDouble();
      if (value is double) return value;
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    final calories = toDouble(meal['kalori_total']).toInt();
    final protein = toDouble(meal['protein_total']).toInt();
    final carbs = toDouble(meal['karbohidrat_total']).toInt();
    final fats = toDouble(meal['lemak_total']).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nutrition pills (similar to recipe.dart)
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            _NutriPill(
              icon: Icons.local_fire_department_rounded,
              color: AppColors.blue,
              label: '${calories}cal',
            ),
            _NutriPill(
              icon: Icons.fitness_center_rounded,
              color: AppColors.red,
              label: '${protein}g',
            ),
            _NutriPill(
              icon: Icons.bakery_dining_rounded,
              color: AppColors.warning,
              label: '${carbs}g',
            ),
            _NutriPill(
              icon: Icons.eco_rounded,
              color: AppColors.success,
              label: '${fats}g',
            ),
          ],
        ),
      ],
    );
  }

  void _showPremiumSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
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
        backgroundColor: isSuccess ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
        ),
        margin: EdgeInsets.all(AppSpacing.md),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showDeleteDialog(Map<String, dynamic> meal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              margin: EdgeInsets.all(AppSpacing.lg),
              padding: EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                boxShadow: AppShadows.floating,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.error.withOpacity(0.2),
                          AppColors.error.withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.error,
                      size: 28,
                    ),
                  ),

                  SizedBox(height: AppSpacing.lg),

                  Text(
                    'Delete Saved Meal',
                    style: AppTextStyles.h4.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: AppSpacing.sm),

                  Text(
                    'Are you sure you want to delete "${meal['nama_makanan'] ?? 'this meal'}" from saved list?',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: AppSpacing.xl),

                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppBorderRadius.md,
                              ),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: AppSpacing.md),

                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: AppColors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppBorderRadius.md,
                              ),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            'Delete',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 200.ms).scale(begin: const Offset(0.8, 0.8)),
    );

    if (confirmed == true && meal['id'] != null) {
      await _unsaveMeal(meal['id'].toString());
    }
  }

  Future<void> _unsaveMeal(String konsumsiId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      print('DEBUG: Akan unsave konsumsiId: $konsumsiId');

      if (token == null) {
        _showPremiumSnackBar('Login session has expired', isSuccess: false);
        return;
      }

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
        _showPremiumSnackBar(
          'Meal successfully deleted from saved list',
          isSuccess: true,
        );
        _fetchSavedMeals();
      } else {
        String errorMsg = 'Failed to delete saved meal';
        try {
          final err = jsonDecode(response.body);
          if (err is Map && err['error'] != null) {
            errorMsg = err['error'];
          }
        } catch (_) {}

        print('DEBUG: Error saat unsave: $errorMsg');
        _showPremiumSnackBar(errorMsg, isSuccess: false);
      }
    } catch (e) {
      print('DEBUG: Exception saat unsave: $e');
      _showPremiumSnackBar(
        'An error occurred: ${e.toString()}',
        isSuccess: false,
      );
    }
  }

  // Helper functions for meal time
  IconData _getMealTimeIcon(String? mealTime) {
    switch (mealTime?.toLowerCase()) {
      case 'breakfast':
        return Icons.wb_sunny;
      case 'lunch':
        return Icons.wb_sunny_outlined;
      case 'dinner':
        return Icons.nights_stay;
      case 'snack':
        return Icons.coffee;
      default:
        return Icons.bookmark_rounded; // For saved meals without time
    }
  }

  String _getMealTimeText(String? mealTime) {
    switch (mealTime?.toLowerCase()) {
      case 'breakfast':
        return 'Breakfast';
      case 'lunch':
        return 'Lunch';
      case 'dinner':
        return 'Dinner';
      case 'snack':
        return 'Snack';
      default:
        return 'Food'; // For saved meals without time
    }
  }

  Widget _buildMealImage(Map<String, dynamic> meal) {
    final bool isFoto = meal['is_foto'] == true;
    final String image = meal['foto'] ?? '';

    if (isFoto && image.isNotEmpty && image.startsWith('http')) {
      // Network image
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppBorderRadius.sm),
          border: Border.all(
            color: AppColors.lightGrey.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppBorderRadius.sm),
          child: Image.network(
            image,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholderImage();
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: 60,
                height: 60,
                color: AppColors.lightGrey.withOpacity(0.1),
                child: Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    } else if (isFoto && image.isNotEmpty && !image.startsWith('http')) {
      // Local file image
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppBorderRadius.sm),
          border: Border.all(
            color: AppColors.lightGrey.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppBorderRadius.sm),
          child: Image.file(
            File(image),
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholderImage();
            },
          ),
        ),
      );
    } else {
      // No image - show styled icon placeholder
      return _buildPlaceholderImage();
    }
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
      ),
      child: Icon(
        Icons.restaurant_menu_rounded,
        color: AppColors.primary,
        size: 20,
      ),
    );
  }
}

// Nutrition pill widget (similar to recipe.dart)
class _NutriPill extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _NutriPill({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }
}
