import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:porsiku/components/section_card.dart';
import 'package:porsiku/components/navbar.dart';
import 'package:porsiku/components/calories_progress_indicator.dart';
import 'package:porsiku/components/nutrient_progress_row.dart';
import 'package:porsiku/view/main/analytics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:porsiku/service/api_service.dart';
import 'package:porsiku/view/main/scan.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:porsiku/view/main/recipe.dart';
import 'package:porsiku/view/main/recipe_open.dart';
import 'package:porsiku/constants/constants.dart';
import 'package:porsiku/view/main/textinput.dart';
import 'package:porsiku/view/main/audioinput.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with WidgetsBindingObserver {
  int _selectedIndex = 0;
  int _currentCarouselIndex = 0;

  // Tambahan: Timer untuk auto-refresh saat hari berganti
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initDailyTarget();
    _fetchTodayGoalAndRecentActivity();
    _fetchRecipeRecommendations();
    _startMidnightTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _midnightTimer?.cancel();
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
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    final token = prefs.getString('token');
    if (userId == null || token == null) return;
    try {
      // Fetch daily target
      final targetResp = await http.get(
        Uri.parse('http://192.168.0.105:8080/api/daily_target/$userId'),
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
        Uri.parse('http://192.168.0.105:8080/api/konsumsi/$userId'),
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
              'title': item['nama_makanan'] ?? '-',
              'calories': (item['kalori_total'] ?? 0).round(),
              'mass': item['waktu_makan'] ?? '',
              'image':
                  (item['foto'] != null && item['foto'].toString().isNotEmpty)
                      ? item['foto']
                      : 'assets/images/placeholder.png',
              'is_foto': item['is_foto'] ?? false,
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
        Uri.parse('http://192.168.0.105:8080/api/resep'),
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
  }

  void _onItemTapped(int index) {
    // If the 'Add' button is tapped, show the dialog
    if (index == 2) {
      _showAddOptionsDialog(context);
    } else {
      // For other items, update the selected index and navigate
      setState(() {
        _selectedIndex = index;
      });
      if (index == 0) {
        // Navigate to Home (already on dashboard, so do nothing or refresh)
      } else if (index == 1) {
        // Navigate to Recipes Page by name
        // Navigator.pushNamed(context, '/recipes'); // Assuming you have a recipes page
      } else if (index == 3) {
        // Navigate to Analytics Page by name
        // Navigator.pushNamed(context, '/analytics');
      } else if (index == 4) {
        // Navigate to More/Profile Page by name
        // Navigator.pushNamed(context, '/profile');
      }
    }
  }

  void _showAddOptionsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Center(
                child: Text(
                  "Add Food Entry",
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  _buildDialogOption(
                    context,
                    icon: Icons.camera_alt_outlined,
                    label: "Capture",
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
                  _buildDialogOption(
                    context,
                    icon: Icons.text_fields,
                    label: "Text",
                    onTap: () async {
                      Navigator.pop(context);
                      await TextInputPage.show(context);
                      _fetchTodayGoalAndRecentActivity();
                    },
                  ),
                  _buildDialogOption(
                    context,
                    icon: Icons.mic_none_outlined,
                    label: "Speech",
                    onTap: () async {
                      Navigator.pop(context);
                      await AudioInputPage.show(context);
                      _fetchTodayGoalAndRecentActivity();
                    },
                  ),
                  _buildDialogOption(
                    context,
                    icon: Icons.bookmark_border_outlined,
                    label: "Saved",
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navigate to Saved Meals page
                      // Navigator.pushNamed(context, '/saved-meals');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDialogOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Icon(icon, size: 24.0, color: Colors.blue),
            ),
            const SizedBox(height: 8.0),
            Text(
              label,
              style: TextStyle(fontSize: 14.0, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildDashboardContent(),
            const RecipePage(),
            Container(), // This corresponds to index 2, which is 'Add'
            const AnalyticsPage(),
            // Placeholder for More/Profile Page (index 4)
            // Container(child: Center(child: Text("More/Profile Page"))),
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
      return const Center(
        child: Text('User ID tidak ditemukan. Silakan login ulang.'),
      );
    }
    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          _fetchTodayGoalAndRecentActivity(),
          _fetchRecipeRecommendations(),
        ]);
      },
      child: FutureBuilder<Map<String, dynamic>>(
        future: _futureDailyTarget,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: \\${snapshot.error}'));
          }

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16.0),
                SectionCard(
                  title: "Today's Goal",
                  contentChild: _buildTodayGoalContent(todayGoal),
                ),
                const SizedBox(height: 16.0),
                SectionCard(
                  title: "Recipe Recommendation",
                  contentChild: _buildRecommendationContent(
                    recipeRecommendations,
                  ),
                ),
                const SizedBox(height: 16.0),
                SectionCard(
                  title: "Today's Meal Log",
                  contentChild: _buildRecentActivityContent(recentActivity),
                ),
                const SizedBox(height: 16.0),
              ],
            ),
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
                progressColor: Colors.red,
              ),
              const SizedBox(height: 8),
              NutrientProgressRow(
                title: 'Fat',
                currentValue: toDouble(todayGoal['fat']['current']).toInt(),
                targetValue: toDouble(todayGoal['fat']['target']).toInt(),
                progressColor: Colors.green,
              ),
              const SizedBox(height: 8),
              NutrientProgressRow(
                title: 'Carbs',
                currentValue: toDouble(todayGoal['carbs']['current']).toInt(),
                targetValue: toDouble(todayGoal['carbs']['target']).toInt(),
                progressColor: Colors.yellow,
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

  Widget _buildRecentActivityContent(
    List<Map<String, dynamic>> recentActivity,
  ) {
    if (recentActivity.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(
            "You don't have any meal log yet. Capture your meal now!",
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
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recentActivity.length,
      itemBuilder: (context, index) {
        final activity = recentActivity[index];
        final isFoto = activity['is_foto'] == true;
        final image = activity['image'] ?? 'assets/images/placeholder.png';
        Widget imageWidget;
        if (isFoto && image.toString().startsWith('http')) {
          imageWidget = Image.network(
            image,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder:
                (context, error, stackTrace) => Image.asset(
                  'assets/images/placeholder.png',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
          );
        } else if (isFoto &&
            image.toString().isNotEmpty &&
            !image.toString().startsWith('http')) {
          imageWidget = Image.file(
            File(image),
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder:
                (context, error, stackTrace) => Image.asset(
                  'assets/images/placeholder.png',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
          );
        } else {
          imageWidget = Image.asset(
            'assets/images/placeholder.png',
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          );
        }
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: imageWidget,
          ),
          title: Text(
            activity['title']! as String,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text('${activity['calories']} cal, ${activity['mass']}'),
          trailing: IconButton(
            icon: Icon(Icons.close, color: Colors.grey, size: 20.0),
            onPressed: () {
              // TODO: Implement delete recent activity
              setState(() {
                // recentActivity.removeAt(index);
              });
            },
          ),
          contentPadding: EdgeInsets.zero,
        );
      },
      separatorBuilder:
          (context, index) => const Divider(height: 1, indent: 66),
    );
  }
}

class _RecipeCarousel extends StatelessWidget {
  final List<Map<String, dynamic>> recommendations;
  final int currentCarouselIndex;
  final Function(int, CarouselPageChangedReason) onPageChanged;

  const _RecipeCarousel({
    required this.recommendations,
    required this.currentCarouselIndex,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 200.0,
            autoPlay: false,
            enlargeCenterPage: false,
            viewportFraction: 0.9,
            aspectRatio: 2.0,
            onPageChanged: onPageChanged,
          ),          items: recommendations.map((rec) {
            return Builder(
              builder: (BuildContext context) {
                return GestureDetector(
                  onTap: () {
                    // Navigate to recipe detail page
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => RecipeOpenPage(recipe: rec),
                      ),
                    );
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppBorderRadius.md),
                      image: DecorationImage(
                        image: NetworkImage(rec['image']),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Stack(
                        children: [
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(
                                    AppBorderRadius.md,
                                  ),
                                  bottomRight: Radius.circular(
                                    AppBorderRadius.md,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    rec['title'],
                                    style: TextStyle(
                                      fontSize: AppTexts.md,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${rec['calories']}cal',
                                        style: TextStyle(
                                          fontSize: AppTexts.sm,
                                          color: AppColors.white,
                                        ),
                                      ),
                                      Text(
                                        '${rec['protein']}g Prot',
                                        style: TextStyle(
                                          fontSize: AppTexts.sm,
                                          color: AppColors.white,
                                        ),
                                      ),
                                      Text(
                                        '${rec['weight']}g',
                                        style: TextStyle(
                                          fontSize: AppTexts.sm,
                                          color: AppColors.white,
                                        ),
                                      ),
                                      Text(
                                        '${rec['fiber']}g Fiber',
                                        style: TextStyle(
                                          fontSize: AppTexts.sm,
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (rec['duration'] != null)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(
                                    AppBorderRadius.sm,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.timer_outlined,
                                      color: AppColors.white,
                                      size: AppTexts.sm,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      rec['duration'],
                                      style: TextStyle(
                                        fontSize: AppTexts.xs,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ],
                                ),                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }).toList(),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(recommendations.length, (index) {
            bool isActive = index == currentCarouselIndex;
            return Container(
              width: isActive ? AppBorderRadius.lg : AppBorderRadius.sm,
              height: AppBorderRadius.sm,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppBorderRadius.infinity),
                color: isActive ? AppColors.black : AppColors.lightGrey,
              ),
            );
          }),
        ),
      ],
    );
  }
}
