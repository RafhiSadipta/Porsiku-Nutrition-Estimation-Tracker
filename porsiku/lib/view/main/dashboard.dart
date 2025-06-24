import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:porsiku/components/section_card.dart';
import 'package:porsiku/components/navbar.dart';
import 'package:porsiku/components/calories_progress_indicator.dart';
import 'package:porsiku/components/nutrient_progress_row.dart';
import 'package:porsiku/view/main/analytics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:porsiku/services/api_service.dart';
import 'package:porsiku/view/main/scan.dart';
import 'package:porsiku/view/main/more.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:porsiku/view/main/recipe.dart';
import 'package:porsiku/view/main/recipe_open.dart';
import 'package:porsiku/constants/constants.dart';
import 'package:porsiku/view/main/textinput.dart';
import 'package:porsiku/view/main/audioinput.dart';
import 'package:porsiku/view/main/result.dart';
import 'package:porsiku/components/saved_meal_bottom_sheet.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  int _selectedIndex = 0;
  int _currentCarouselIndex = 0;

  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // Loading states
  bool _isInitialLoading = true;
  bool _isRefreshing = false;
  // Tambahan: Timer untuk auto-refresh saat hari berganti
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize animation controllers
    _initializeAnimations();

    // Initialize data
    _initDailyTarget();
    _fetchTodayGoalAndRecentActivity();
    _fetchRecipeRecommendations();
    _startMidnightTimer();

    // Start entrance animations
    _startEntranceAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: AppAnimations.slow,
      vsync: this,
    );

    _slideController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );
  }

  void _startEntranceAnimations() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _fadeController.forward();
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _midnightTimer?.cancel();
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchTodayGoalAndRecentActivity();
    }
  }

  Timer? _midnightTimer;
  void _startMidnightTimer() {
    _midnightTimer?.cancel();
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final duration = tomorrow.difference(now);
    _midnightTimer = Timer(duration, () {
      // Setelah tengah malam, refresh data dan restart timer
      _fetchTodayGoalAndRecentActivity();
      _startMidnightTimer();
    });
  }

  Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  Future<Map<String, dynamic>>? _futureDailyTarget;

  // Tambahkan di dalam _DashboardPageState:
  Map<String, dynamic> todayGoal = {
    'calories': {'current': 0, 'target': 0},
    'protein': {'current': 0, 'target': 0},
    'fat': {'current': 0, 'target': 0},
    'carbs': {'current': 0, 'target': 0},
  };
  List<Map<String, dynamic>> recentActivity = [];
  List<Map<String, dynamic>> recipeRecommendations = [];
  bool isLoadingRecipes = true;

  void _initDailyTarget() async {
    final userId = await _getUserId();
    if (userId != null) {
      setState(() {
        _futureDailyTarget = fetchDailyTarget(userId);
      });
    }
  }

  Future<void> _fetchTodayGoalAndRecentActivity() async {
    if (!_isRefreshing) {
      setState(() {
        _isRefreshing = true;
      });
    }

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    final token = prefs.getString('token');
    if (userId == null || token == null) {
      setState(() {
        _isRefreshing = false;
        _isInitialLoading = false;
      });
      return;
    }

    try {
      // Fetch daily target
      final targetResp = await http.get(
        Uri.parse(
          'https://porsiku-nutrition-estimation-tracker-production.up.railway.app/api/daily_target/$userId',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (targetResp.statusCode == 200) {
        final data = jsonDecode(targetResp.body);
        setState(() {
          todayGoal['calories']['target'] =
              (data['kalori_harian'] ?? 0).round();
          todayGoal['protein']['target'] =
              (data['protein_harian'] ?? 0).round();
          todayGoal['fat']['target'] = (data['lemak_harian'] ?? 0).round();
          todayGoal['carbs']['target'] = (data['karbo_harian'] ?? 0).round();
        });
      }
      // Fetch daily consumption summary
      final konsumsiResp = await http.get(
        Uri.parse(
          'https://porsiku-nutrition-estimation-tracker-production.up.railway.app/api/konsumsi/$userId',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (konsumsiResp.statusCode == 200) {
        final konsumsiData = jsonDecode(konsumsiResp.body);
        double totalKal = 0, totalPro = 0, totalLem = 0, totalKar = 0;
        List<Map<String, dynamic>> logs = [];
        final now = DateTime.now();
        for (var item in konsumsiData['data'] ?? []) {
          if (item['soft_deleted'] == true) continue;
          final tanggalStr = item['tanggal'] ?? '';
          if (tanggalStr.isEmpty) continue;
          final tanggal = DateTime.tryParse(tanggalStr)?.toLocal();
          if (tanggal == null) continue;
          // Only include logs from today
          if (tanggal.year == now.year &&
              tanggal.month == now.month &&
              tanggal.day == now.day) {
            totalKal += (item['kalori_total'] ?? 0).toDouble();
            totalPro += (item['protein_total'] ?? 0).toDouble();
            totalLem += (item['lemak_total'] ?? 0).toDouble();
            totalKar += (item['karbohidrat_total'] ?? 0).toDouble();
            logs.add({
              'id': item['id'],
              'title': item['nama_makanan'] ?? '-',
              'calories': (item['kalori_total'] ?? 0).round(),
              'mass': item['waktu_makan'] ?? '',
              'image':
                  (item['foto'] != null && item['foto'].toString().isNotEmpty)
                      ? item['foto']
                      : 'assets/images/placeholder.png',
              'is_foto': item['is_foto'] ?? false,
              'nutritionResult': [item],
            });
          }
        }
        setState(() {
          todayGoal['calories']['current'] = totalKal.round();
          todayGoal['protein']['current'] = totalPro.round();
          todayGoal['fat']['current'] = totalLem.round();
          todayGoal['carbs']['current'] = totalKar.round();
          recentActivity = logs.reversed.toList();
        });
      }
    } catch (e) {
      // ignore error, optionally show snackbar
    } finally {
      setState(() {
        _isRefreshing = false;
        _isInitialLoading = false;
      });
    }
  }

  Future<void> _fetchRecipeRecommendations() async {
    setState(() {
      isLoadingRecipes = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      // Prepare the request payload for random recipes
      Map<String, dynamic> payload = {
        'number': 4, // Fetch 4 recipes
        'sort': 'random', // Random sorting if supported
        'addRecipeNutrition': true,
        'addRecipeInformation': true,
      };

      final response = await http.post(
        Uri.parse(
          'https://porsiku-nutrition-estimation-tracker-production.up.railway.app/api/resep',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null &&
            data['data']['results'] != null &&
            data['data']['results'] is List) {
          final recipes = List<Map<String, dynamic>>.from(
            data['data']['results'],
          );

          // Transform the recipe data to match the expected format for the dashboard
          final transformedRecipes =
              recipes.take(4).map((recipe) {
                return {
                  'id': recipe['id'],
                  'image':
                      recipe['image'] ??
                      'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&h=180&q=80',
                  'title': recipe['title'] ?? 'Unknown Recipe',
                  'calories':
                      ((recipe['calories'] as num?)?.toInt() ?? 0).toString(),
                  'protein':
                      ((recipe['protein'] as num?)?.toInt() ?? 0).toString(),
                  'weight': '500', // Default weight since not provided by API
                  'fiber':
                      ((recipe['carbs'] as num?)?.toInt() ?? 0)
                          .toString(), // Using carbs as fiber placeholder
                  'duration':
                      recipe['readyInMinutes'] != null
                          ? '${recipe['readyInMinutes']}min'
                          : '30min',
                  'isBookmarked': false,
                };
              }).toList();

          setState(() {
            recipeRecommendations = transformedRecipes;
            isLoadingRecipes = false;
          });
        } else {
          // Fallback to dummy data if API response is invalid
          setState(() {
            recipeRecommendations = List<Map<String, dynamic>>.from(
              dummyRecipes.take(4),
            );
            isLoadingRecipes = false;
          });
        }
      } else {
        // Fallback to dummy data if API call fails
        setState(() {
          recipeRecommendations = List<Map<String, dynamic>>.from(
            dummyRecipes.take(4),
          );
          isLoadingRecipes = false;
        });
      }
    } catch (e) {
      // Fallback to dummy data if there's an error
      setState(() {
        recipeRecommendations = List<Map<String, dynamic>>.from(
          dummyRecipes.take(4),
        );
        isLoadingRecipes = false;
      });
    }
  }  void _onItemTapped(int index) {
    // If the 'Add' button is tapped, show the dialog
    if (index == 2) {
      _showAddOptionsDialog(context);
    } else {
      // For other items, update the selected index to show the corresponding page
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _showAddOptionsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (BuildContext context) {
        return Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24.0),
                ),
                boxShadow: AppShadows.floating,
              ),
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: EdgeInsets.only(bottom: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.lightGrey,
                          borderRadius: BorderRadius.circular(
                            AppBorderRadius.sm,
                          ),
                        ),
                      ),
                    ).animate().scale(
                      duration: AppAnimations.medium,
                      curve: Curves.elasticOut,
                    ),

                    // Title
                    Center(
                          child: Text(
                            "Add Food Entry",
                            style: AppTextStyles.h3.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(duration: AppAnimations.medium, delay: 100.ms)
                        .slideY(
                          begin: 0.3,
                          duration: AppAnimations.medium,
                          curve: Curves.easeOutCubic,
                        ),

                    SizedBox(height: AppSpacing.lg),

                    // Options grid
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        _buildEnhancedDialogOption(
                          context,
                          icon: Icons.camera_alt_outlined,
                          label: "Capture",
                          color: AppColors.primary,
                          delay: 0,
                          onTap: () async {
                            Navigator.pop(context);
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const ScanPage(),
                              ),
                            );
                            if (result == 'refresh') {
                              _fetchTodayGoalAndRecentActivity();
                            }
                          },
                        ),
                        _buildEnhancedDialogOption(
                          context,
                          icon: Icons.text_fields,
                          label: "Text",
                          color: AppColors.info,
                          delay: 100,
                          onTap: () async {
                            Navigator.pop(context);
                            await TextInputPage.show(context);
                            _fetchTodayGoalAndRecentActivity();
                          },
                        ),
                        _buildEnhancedDialogOption(
                          context,
                          icon: Icons.mic_none_outlined,
                          label: "Speech",
                          color: AppColors.success,
                          delay: 200,
                          onTap: () async {
                            Navigator.pop(context);
                            await AudioInputPage.show(context);
                            _fetchTodayGoalAndRecentActivity();
                          },
                        ),
                        _buildEnhancedDialogOption(
                          context,
                          icon: Icons.bookmark_border_outlined,
                          label: "Saved",
                          color: AppColors.warning,
                          delay: 300,
                          onTap: () {
                            Navigator.pop(context);
                            _showSavedMealBottomSheet();
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            )
            .animate()
            .slideY(
              begin: 1.0,
              duration: AppAnimations.medium,
              curve: Curves.easeOutCubic,
            )
            .fadeIn(duration: AppAnimations.medium);
      },
    );
  }

  Widget _buildEnhancedDialogOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required int delay,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppBorderRadius.md),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Icon container with gradient background
            Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                    border: Border.all(color: color.withOpacity(0.2), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, size: AppIcons.lg, color: color),
                )
                .animate()
                .scale(
                  delay: Duration(milliseconds: delay),
                  duration: AppAnimations.medium,
                  curve: Curves.elasticOut,
                )
                .fadeIn(
                  delay: Duration(milliseconds: delay),
                  duration: AppAnimations.medium,
                ),

            SizedBox(height: AppSpacing.sm),

            // Label
            Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: AppTexts.medium,
                  ),
                )
                .animate()
                .fadeIn(
                  delay: Duration(milliseconds: delay + 100),
                  duration: AppAnimations.medium,
                )
                .slideY(
                  begin: 0.3,
                  delay: Duration(milliseconds: delay + 100),
                  duration: AppAnimations.medium,
                  curve: Curves.easeOutCubic,
                ),
          ],
        ),
      ),
    );
  }

  void _showSavedMealBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => SavedMealBottomSheet(
            onMealSelected: (Map<String, dynamic> selectedMeal) async {
              // Transform saved meal data to match ResultPage requirements
              final nutritionItems =
                  selectedMeal['nutrition_items'] as List? ?? [];

              // Create nutrition result format for ResultPage
              final nutritionResult =
                  nutritionItems.isNotEmpty
                      ? nutritionItems
                      : [
                        {
                          'nama_makanan':
                              selectedMeal['nama_makanan'] ?? 'Unknown Product',
                          'kalori_total': selectedMeal['kalori_total'] ?? 0,
                          'protein_total': selectedMeal['protein_total'] ?? 0,
                          'lemak_total': selectedMeal['lemak_total'] ?? 0,
                          'karbohidrat_total':
                              selectedMeal['karbohidrat_total'] ?? 0,
                          'waktu_makan':
                              selectedMeal['waktu_makan'] ?? 'breakfast',
                        },
                      ]; // Navigate to result page with the selected saved meal
              print(
                'DEBUG: Navigating to ResultPage with foto: ${selectedMeal['foto']}',
              );
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ResultPage(
                        foodListText:
                            selectedMeal['nama_makanan'] ?? 'Saved Meal',
                        nutritionResult: nutritionResult,
                        imagePath:
                            selectedMeal['foto'] ??
                            '', // Use saved photo or empty
                        isViewMode:
                            false, // Allow editing and saving as new entry
                        existingKonsumsiId:
                            null, // This is a new entry from saved meal
                      ),
                ),
              );
              // Refresh dashboard after returning
              _fetchTodayGoalAndRecentActivity();
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildDashboardContent(),
            const RecipePage(),
            Container(), // This corresponds to index 2, which is 'Add'
            const AnalyticsPage(),
            const MorePage(),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavbar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildDashboardContent() {
    if (_futureDailyTarget == null) {
      return Center(
        child: Text(
          'User ID tidak ditemukan. Silakan login ulang.',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      onRefresh: () async {
        setState(() {
          _isRefreshing = true;
        });

        await Future.wait([
          _fetchTodayGoalAndRecentActivity(),
          _fetchRecipeRecommendations(),
        ]);

        // Add a small delay for smooth UX
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: FutureBuilder<Map<String, dynamic>>(
        future: _futureDailyTarget,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              _isInitialLoading) {
            return _buildLoadingState();
          }
          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          return AnimatedBuilder(
            animation: Listenable.merge([
              _fadeController,
              _slideController,
              _scaleController,
            ]),
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Welcome header
                          _buildWelcomeHeader()
                              .animate()
                              .fadeIn(
                                duration: AppAnimations.medium,
                                delay: 200.ms,
                              )
                              .slideX(
                                begin: -0.3,
                                duration: AppAnimations.medium,
                                curve: Curves.easeOutCubic,
                              ),

                          SizedBox(height: AppSpacing.lg), // Today's Goal Card
                          SectionCard(
                                title: "Today's Goal",
                                headerIcon: Icons.track_changes,
                                showGradientAccent: false,
                                contentChild: _buildTodayGoalContent(todayGoal),
                              )
                              .animate()
                              .fadeIn(
                                duration: AppAnimations.medium,
                                delay: 400.ms,
                              )
                              .slideY(
                                begin: 0.3,
                                duration: AppAnimations.medium,
                                curve: Curves.easeOutCubic,
                              ),

                          SizedBox(height: AppSpacing.md),

                          // Recipe Recommendation Card
                          SectionCard(
                                title: "Recipe Recommendation",
                                headerIcon: Icons.restaurant_menu,
                                isLoading: isLoadingRecipes,
                                contentChild: _buildRecommendationContent(
                                  recipeRecommendations,
                                ),
                              )
                              .animate()
                              .fadeIn(
                                duration: AppAnimations.medium,
                                delay: 600.ms,
                              )
                              .slideY(
                                begin: 0.3,
                                duration: AppAnimations.medium,
                                curve: Curves.easeOutCubic,
                              ),

                          SizedBox(height: AppSpacing.md),

                          // Today's Meal Log Card
                          SectionCard(
                                title: "Today's Meal Log",
                                headerIcon: Icons.food_bank,
                                contentChild: _buildRecentActivityContent(
                                  recentActivity,
                                ),
                              )
                              .animate()
                              .fadeIn(
                                duration: AppAnimations.medium,
                                delay: 800.ms,
                              )
                              .slideY(
                                begin: 0.3,
                                duration: AppAnimations.medium,
                                curve: Curves.easeOutCubic,
                              ),

                          SizedBox(height: AppSpacing.xl),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTodayGoalContent(Map<String, dynamic> todayGoal) {
    // Pastikan semua value dikonversi ke double
    double toDouble(dynamic value) {
      if (value is int) return value.toDouble();
      if (value is double) return value;
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: CaloriesProgressIndicator(
            currentCalories: toDouble(todayGoal['calories']['current']).toInt(),
            targetCalories: toDouble(todayGoal['calories']['target']).toInt(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              NutrientProgressRow(
                title: 'Protein',
                currentValue: toDouble(todayGoal['protein']['current']).toInt(),
                targetValue: toDouble(todayGoal['protein']['target']).toInt(),
                progressColor: AppColors.red,
              ),
              const SizedBox(height: 8),
              NutrientProgressRow(
                title: 'Carbs',
                currentValue: toDouble(todayGoal['carbs']['current']).toInt(),
                targetValue: toDouble(todayGoal['carbs']['target']).toInt(),
                progressColor: AppColors.yellow,
              ),
              const SizedBox(height: 8),
              NutrientProgressRow(
                title: 'Fats',
                currentValue: toDouble(todayGoal['fat']['current']).toInt(),
                targetValue: toDouble(todayGoal['fat']['target']).toInt(),
                progressColor: AppColors.green,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationContent(
    List<Map<String, dynamic>> recommendations,
  ) {
    if (isLoadingRecipes) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (recommendations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(
            "No recipe recommendations available at the moment.",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return _RecipeCarousel(
      recommendations: recommendations,
      currentCarouselIndex: _currentCarouselIndex,
      onPageChanged: (index, reason) {
        setState(() {
          _currentCarouselIndex = index;
        });
      },
    );
  }

  Future<void> _deleteConsumption(Map<String, dynamic> activity) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;
    // Asumsikan backend butuh id konsumsi, pastikan field id tersedia di activity
    final konsumsiId = activity['id'] ?? activity['konsumsi_id'];
    if (konsumsiId == null) return;
    final response = await http.delete(
      Uri.parse(
        'https://porsiku-nutrition-estimation-tracker-production.up.railway.app/api/konsumsi/$konsumsiId',
      ),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      _fetchTodayGoalAndRecentActivity();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Konsumsi berhasil dihapus')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menghapus konsumsi')));
    }
  }

  Future<Map<String, dynamic>?> fetchKonsumsiDetail(int konsumsiId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return null;
    final response = await http.get(
      Uri.parse(
        'https://porsiku-nutrition-estimation-tracker-production.up.railway.app/api/konsumsi/item/$konsumsiId',
      ),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['data'] != null &&
          data['data'] is List &&
          data['data'].isNotEmpty) {
        return data['data'][0];
      }
    }
    return null;
  }

  Widget _buildRecentActivityContent(
    List<Map<String, dynamic>> recentActivity,
  ) {
    if (recentActivity.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Column(
          children: [
            // Empty state illustration
            Container(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    gradient: AppGradients.subtle,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.restaurant_menu,
                    size: 48,
                    color: AppColors.white,
                  ),
                )
                .animate()
                .scale(duration: AppAnimations.medium, curve: Curves.elasticOut)
                .fadeIn(),

            SizedBox(height: AppSpacing.md),

            Text(
                  "No meals logged yet",
                  style: AppTextStyles.h4.copyWith(
                    color: AppColors.textPrimary,
                  ),
                )
                .animate()
                .fadeIn(delay: 200.ms)
                .slideY(begin: 0.3, duration: AppAnimations.medium),

            SizedBox(height: AppSpacing.sm),

            Text(
                  "Capture your meal now to start tracking your nutrition!",
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                )
                .animate()
                .fadeIn(delay: 400.ms)
                .slideY(begin: 0.3, duration: AppAnimations.medium),

            SizedBox(height: AppSpacing.lg),

            // Call-to-action button
            ElevatedButton.icon(
                  onPressed: () => _onItemTapped(2), // Trigger add options
                  icon: Icon(Icons.add_a_photo, size: AppIcons.sm),
                  label: Text('Add Your First Meal'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    ),
                    elevation: 4,
                  ),
                )
                .animate()
                .fadeIn(delay: 600.ms)
                .scale(
                  begin: const Offset(0.8, 0.8),
                  duration: AppAnimations.medium,
                  curve: Curves.elasticOut,
                ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recentActivity.length,
      itemBuilder: (context, index) {
        final activity = recentActivity[index];
        final isFoto = activity['is_foto'] == true;
        final image = activity['image'] ?? 'assets/images/placeholder.png';

        Widget imageWidget = _buildMealImage(isFoto, image);

        return Container(
              margin: EdgeInsets.only(bottom: AppSpacing.xs),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
                border: Border.all(
                  color: AppColors.lightGrey.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  onTap: () => _handleMealTap(activity),
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    child: Row(
                      children: [
                        // Enhanced meal image
                        Hero(
                          tag: 'meal_${activity['id']}',
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                AppBorderRadius.md,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppBorderRadius.md,
                              ),
                              child: imageWidget,
                            ),
                          ),
                        ),

                        SizedBox(width: AppSpacing.md),

                        // Enhanced meal info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Meal name with truncation
                              Text(
                                activity['title']! as String,
                                style: AppTextStyles.label.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),

                              SizedBox(height: AppSpacing.xs),

                              // Enhanced meal details
                              Row(
                                children: [
                                  // Calories with icon
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.local_fire_department,
                                        size: AppIcons.xs,
                                        color: AppColors.warning,
                                      ),
                                      SizedBox(width: 2),
                                      Text(
                                        '${activity['calories']} cal',
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),

                                  Text(
                                    ' • ',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),

                                  // Meal time with icon
                                  Row(
                                    children: [
                                      Icon(
                                        _getMealTimeIcon(
                                          activity['mass'] ?? '',
                                        ),
                                        size: AppIcons.xs,
                                        color: AppColors.info,
                                      ),
                                      SizedBox(width: 2),
                                      Text(
                                        activity['mass'] ?? '',
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Enhanced action buttons
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(width: AppSpacing.xs),
                            // Delete button
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                  AppBorderRadius.sm,
                                ),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: AppColors.error,
                                  size: AppIcons.sm,
                                ),
                                onPressed:
                                    () => _showDeleteConfirmation(activity),
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
            .animate(delay: Duration(milliseconds: index * 100))
            .fadeIn(duration: AppAnimations.medium, curve: Curves.easeOut)
            .slideX(
              begin: 0.3,
              duration: AppAnimations.medium,
              curve: Curves.easeOutCubic,
            );
      },
      separatorBuilder: (context, index) => SizedBox(height: AppSpacing.xs),
    );
  }

  Widget _buildMealImage(bool isFoto, String image) {
    if (isFoto && image.isNotEmpty && image.startsWith('http')) {
      return Image.network(
        image,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(AppBorderRadius.sm),
            ),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
      );
    } else if (isFoto && image.isNotEmpty && !image.startsWith('http')) {
      return Image.file(
        File(image),
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
      );
    } else {
      return _buildPlaceholderImage();
    }
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: AppGradients.subtle,
        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
      ),
      child: Icon(Icons.restaurant, color: AppColors.white, size: AppIcons.md),
    );
  }

  IconData _getMealTimeIcon(String mealTime) {
    switch (mealTime.toLowerCase()) {
      case 'breakfast':
        return Icons.wb_sunny;
      case 'lunch':
        return Icons.wb_sunny_outlined;
      case 'dinner':
        return Icons.nights_stay;
      case 'snack':
        return Icons.coffee;
      default:
        return Icons.restaurant;
    }
  }

  void _handleMealTap(Map<String, dynamic> activity) async {
    final konsumsiIdRaw = activity['id'];
    if (konsumsiIdRaw == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID konsumsi tidak ditemukan')),
      );
      return;
    }

    final konsumsiId =
        konsumsiIdRaw is int
            ? konsumsiIdRaw
            : int.tryParse(konsumsiIdRaw.toString());

    if (konsumsiId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ID konsumsi tidak valid')));
      return;
    }

    // Show loading with better UX
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Center(
            child: Container(
              padding: EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
                boxShadow: AppShadows.floating,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.blue),
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'Loading meal details...',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
    );

    final konsumsiDetail = await fetchKonsumsiDetail(konsumsiId);

    // Close loading
    if (Navigator.canPop(context)) Navigator.pop(context);

    if (konsumsiDetail != null) {
      final nutritionItems =
          konsumsiDetail['nutrition_items'] as List<dynamic>?;
      final nutritionResult =
          nutritionItems != null
              ? nutritionItems
                  .map(
                    (item) => {
                      'nama_makanan': item['nama_makanan'] ?? '',
                      'jumlah': item['jumlah'] ?? '',
                      'waktu_makan': konsumsiDetail['waktu_makan'] ?? 'Dinner',
                      'is_saved': konsumsiDetail['is_saved'] ?? false,
                      'nutrition_total': {
                        'kalori': item['kalori'] ?? 0,
                        'protein': item['protein'] ?? 0.0,
                        'lemak': item['lemak'] ?? 0.0,
                        'karbohidrat': item['karbohidrat'] ?? 0.0,
                      },
                    },
                  )
                  .toList()
              : [
                {
                  'nama_makanan': konsumsiDetail['nama_makanan'] ?? '',
                  'jumlah': '1 serving',
                  'waktu_makan': konsumsiDetail['waktu_makan'] ?? 'Dinner',
                  'is_saved': konsumsiDetail['is_saved'] ?? false,
                  'nutrition_total': {
                    'kalori': konsumsiDetail['kalori_total'] ?? 0,
                    'protein': konsumsiDetail['protein_total'] ?? 0,
                    'lemak': konsumsiDetail['lemak_total'] ?? 0,
                    'karbohidrat': konsumsiDetail['karbohidrat_total'] ?? 0,
                  },
                },
              ];

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ResultPage(
                foodListText: konsumsiDetail['nama_makanan'] ?? '',
                nutritionResult: nutritionResult,
                imagePath: konsumsiDetail['foto'] ?? '',
                existingKonsumsiId: konsumsiId.toString(),
                isViewMode: true,
              ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengambil detail konsumsi')),
      );
    }
  }

  void _showDeleteConfirmation(Map<String, dynamic> activity) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
            ),
            title: Text('Delete Meal', style: AppTextStyles.h4),
            content: Text(
              'Are you sure you want to delete "${activity['title']}"?',
              style: AppTextStyles.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteConsumption(activity);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.white,
                ),
                child: Text('Delete'),
              ),
            ],
          ),
    );
  }

  // Loading state with shimmer effects
  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Loading welcome header
          Container(
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppAnimationPresets.shimmerBase,
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
            ),
          ),

          SizedBox(height: AppSpacing.lg),

          // Loading cards
          ...List.generate(
            3,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.md),
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppAnimationPresets.shimmerBase,
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Error state with retry option
  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),

            SizedBox(height: AppSpacing.md),

            Text(
              'Oops! Something went wrong',
              style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: AppSpacing.sm),

            Text(
              error,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: AppSpacing.lg),

            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _futureDailyTarget =
                      _fetchTodayGoalAndRecentActivity()
                          as Future<Map<String, dynamic>>?;
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Enhanced welcome header with delightful animations and interactions
  Widget _buildWelcomeHeader() {
    final hour = DateTime.now().hour;
    String greeting;
    IconData greetingIcon;
    Color gradientStart;
    Color gradientEnd;

    if (hour < 12) {
      greeting = 'Good Morning';
      greetingIcon = Icons.wb_sunny;
      gradientStart = const Color(0xFFFFD54F);
      gradientEnd = AppColors.primary;
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
      greetingIcon = Icons.wb_sunny_outlined;
      gradientStart = AppColors.primary;
      gradientEnd = const Color(0xFFFF8A65);
    } else {
      greeting = 'Good Evening';
      greetingIcon = Icons.nights_stay;
      gradientStart = const Color(0xFF5C6BC0);
      gradientEnd = const Color(0xFF283593);
    }

    return Container(
          margin: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              onTap: () {
                // Show a delightful greeting animation or user profile
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Hello! Have a wonderful day! 🌟'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                    ),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [gradientStart, gradientEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                  boxShadow: [
                    BoxShadow(
                      color: gradientEnd.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Animated greeting icon
                    Container(
                          padding: EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(
                              AppBorderRadius.md,
                            ),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            greetingIcon,
                            color: Colors.white,
                            size: 32,
                          ),
                        )
                        .animate(
                          onPlay:
                              (controller) => controller.repeat(reverse: true),
                        )
                        .scale(
                          duration: const Duration(seconds: 2),
                          begin: const Offset(1.0, 1.0),
                          end: const Offset(1.1, 1.1),
                          curve: Curves.easeInOut,
                        ),

                    SizedBox(width: AppSpacing.md),

                    // Enhanced greeting content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Enhanced greeting text with typewriter effect
                          AnimatedTextKit(
                            animatedTexts: [
                              TypewriterAnimatedText(
                                greeting,
                                textStyle: AppTextStyles.h3.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      offset: const Offset(0, 2),
                                      blurRadius: 4,
                                      color: Colors.black.withOpacity(0.2),
                                    ),
                                  ],
                                ),
                                speed: const Duration(milliseconds: 100),
                              ),
                            ],
                            isRepeatingAnimation: false,
                            displayFullTextOnTap: true,
                          ),

                          SizedBox(height: AppSpacing.xs),

                          // Motivational subtitle with shimmer effect
                          Text(
                                'Ready to nourish your body? ✨',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                  shadows: [
                                    Shadow(
                                      offset: const Offset(0, 1),
                                      blurRadius: 2,
                                      color: Colors.black.withOpacity(0.2),
                                    ),
                                  ],
                                ),
                              )
                              .animate()
                              .fadeIn(delay: const Duration(milliseconds: 800))
                              .slideX(
                                begin: -0.3,
                                duration: AppAnimations.medium,
                                curve: Curves.easeOutCubic,
                              ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: AppAnimations.medium, curve: Curves.easeOut)
        .slideY(
          begin: -0.5,
          duration: AppAnimations.medium,
          curve: Curves.easeOutCubic,
        );
  }
}

class _RecipeCarousel extends StatefulWidget {
  final List<Map<String, dynamic>> recommendations;
  final int currentCarouselIndex;
  final Function(int, CarouselPageChangedReason) onPageChanged;

  const _RecipeCarousel({
    required this.recommendations,
    required this.currentCarouselIndex,
    required this.onPageChanged,
  });

  @override
  State<_RecipeCarousel> createState() => _RecipeCarouselState();
}

class _RecipeCarouselState extends State<_RecipeCarousel>
    with TickerProviderStateMixin {
  late List<AnimationController> _cardControllers;
  late List<Animation<double>> _cardAnimations;
  late AnimationController _indicatorController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Initialize card animations
    _cardControllers = List.generate(
      widget.recommendations.length,
      (index) =>
          AnimationController(duration: AppAnimations.medium, vsync: this),
    );

    _cardAnimations =
        _cardControllers.map((controller) {
          return CurvedAnimation(parent: controller, curve: Curves.easeOutBack);
        }).toList();

    // Start animations with staggered delay
    for (int i = 0; i < _cardControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) {
          _cardControllers[i].forward();
        }
      });
    }

    // Initialize indicator animation
    _indicatorController = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    _indicatorController.forward();
  }

  @override
  void dispose() {
    for (final controller in _cardControllers) {
      controller.dispose();
    }
    _indicatorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.recommendations.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Enhanced carousel with animations
        SizedBox(
          height: 220,
          child: CarouselSlider.builder(
            itemCount: widget.recommendations.length,
            options: CarouselOptions(
              height: 220,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 4),
              autoPlayAnimationDuration: AppAnimations.medium,
              enlargeCenterPage: true,
              enlargeFactor: 0.2,
              viewportFraction: 0.85,
              onPageChanged: widget.onPageChanged,
            ),
            itemBuilder: (context, index, realIndex) {
              return AnimatedBuilder(
                animation: _cardAnimations[index],
                builder: (context, child) {
                  return Transform.scale(
                    scale: 0.8 + (_cardAnimations[index].value * 0.2),
                    child: Opacity(
                      opacity: _cardAnimations[index].value,
                      child: _buildRecipeCard(
                        widget.recommendations[index],
                        index,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),

        SizedBox(height: AppSpacing.sm),

        // Enhanced page indicators
        AnimatedBuilder(
          animation: _indicatorController,
          builder: (context, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.recommendations.length,
                (index) => _buildPageIndicator(index),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecipeCard(Map<String, dynamic> recipe, int index) {
    return Hero(
      tag: 'recipe_${recipe['id'] ?? index}',
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: AppColors.primary.withOpacity(0.05),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
            onTap: () => _navigateToRecipe(recipe),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  stops: const [0.4, 1.0],
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background image with loading state
                    _buildRecipeImage(recipe['image']),

                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.8),
                          ],
                          stops: const [0.5, 1.0],
                        ),
                      ),
                    ),

                    // Content overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Recipe title
                            Text(
                              recipe['title'] ?? 'Delicious Recipe',
                              style: AppTextStyles.h4.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),

                            SizedBox(height: AppSpacing.xs),

                            // Nutrition badges
                            Wrap(
                              spacing: AppSpacing.xs,
                              runSpacing: AppSpacing.xs,
                              children: [
                                _buildNutritionBadge(
                                  Icons.local_fire_department,
                                  '${recipe['calories'] ?? 0}',
                                  'cal',
                                  AppColors.warning,
                                ),
                                if (recipe['duration'] != null)
                                  _buildNutritionBadge(
                                    Icons.timer_outlined,
                                    recipe['duration'],
                                    '',
                                    AppColors.white,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Top badges
                    Positioned(
                      top: AppSpacing.sm,
                      right: AppSpacing.sm,
                      child: Column(
                        children: [
                          // Favorite button
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.bookmark_outline_rounded,
                                color: AppColors.primary,
                                size: AppIcons.sm,
                              ),
                              onPressed: () => _toggleFavorite(recipe),
                              constraints: const BoxConstraints(
                                minWidth: 36,
                                minHeight: 36,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          ),

                          if (recipe['difficulty'] != null) ...[
                            SizedBox(height: AppSpacing.xs),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.xs,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getDifficultyColor(
                                  recipe['difficulty'],
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppBorderRadius.sm,
                                ),
                              ),
                              child: Text(
                                recipe['difficulty'].toString().toUpperCase(),
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        color: AppColors.lightGrey.withOpacity(0.3),
        child: Icon(
          Icons.restaurant_menu,
          size: 64,
          color: AppColors.textSecondary,
        ),
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;

        return Container(
          color: AppColors.lightGrey.withOpacity(0.3),
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                value:
                    loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
              ),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: AppColors.lightGrey.withOpacity(0.3),
          child: Icon(
            Icons.broken_image_outlined,
            size: 64,
            color: AppColors.textSecondary,
          ),
        );
      },
    );
  }

  Widget _buildNutritionBadge(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          SizedBox(width: 4),
          Text(
            '$value${label.isNotEmpty ? ' $label' : ''}',
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    final isActive = index == widget.currentCarouselIndex;

    return AnimatedContainer(
      duration: AppAnimations.fast,
      curve: Curves.easeInOut,
      width: isActive ? 24 : 8,
      height: 8,
      margin: EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
        color:
            isActive ? AppColors.primary : AppColors.lightGrey.withOpacity(0.5),
        boxShadow:
            isActive
                ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
                : null,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(
          color: AppColors.lightGrey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu_outlined,
              size: 48,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'No recipes available',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(dynamic difficulty) {
    final difficultyStr = difficulty.toString().toLowerCase();
    switch (difficultyStr) {
      case 'easy':
        return AppColors.success;
      case 'medium':
        return AppColors.warning;
      case 'hard':
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }

  void _navigateToRecipe(Map<String, dynamic> recipe) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                RecipeOpenPage(recipe: recipe),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          );
        },
      ),
    );
  }

  void _toggleFavorite(Map<String, dynamic> recipe) {
    // TODO: Implement favorite functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added to favorites!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.sm),
        ),
      ),
    );
  }
}
