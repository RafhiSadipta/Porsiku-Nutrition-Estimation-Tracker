import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/constants.dart';
import '../../components/period_selector.dart';
import '../../components/analytics_card.dart';
import '../../service/api_service.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  int selectedWeek = 0;
  int selectedMonth = DateTime.now().month - 1;
  int selectedYear = DateTime.now().year;
  bool isLoading = true;
  String? userId;

  // Real data from backend
  Map<String, List<double>> weeklyData = {
    'calories': [0, 0, 0, 0, 0, 0, 0],
    'protein': [0, 0, 0, 0, 0, 0, 0],
    'carbs': [0, 0, 0, 0, 0, 0, 0],
    'fat': [0, 0, 0, 0, 0, 0, 0],
  };

  List<String> weekDates = [];

  final List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('user_id'); // Use 'user_id' like in dashboard
      if (userId != null) {
        await _fetchAnalyticsData();
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchAnalyticsData() async {
    if (userId == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await fetchAnalyticsData(userId!, week: selectedWeek);

      // Add null safety checks
      if (response['data'] == null || response['data']['week_data'] == null) {
        // If no data, use default empty data
        setState(() {
          weeklyData = {
            'calories': [0, 0, 0, 0, 0, 0, 0],
            'protein': [0, 0, 0, 0, 0, 0, 0],
            'carbs': [0, 0, 0, 0, 0, 0, 0],
            'fat': [0, 0, 0, 0, 0, 0, 0],
          };
          weekDates = _generateDefaultWeekDates();
        });
        return;
      }

      final weekData = response['data']['week_data'] as List;

      // Initialize arrays
      List<double> calories = [];
      List<double> protein = [];
      List<double> carbs = [];
      List<double> fat = [];
      List<String> dates = [];

      // Process the data with null safety
      for (var dayData in weekData) {
        calories.add(((dayData['kalori_total'] as num?) ?? 0).toDouble());
        protein.add(((dayData['protein_total'] as num?) ?? 0).toDouble());
        carbs.add(((dayData['karbohidrat_total'] as num?) ?? 0).toDouble());
        fat.add(((dayData['lemak_total'] as num?) ?? 0).toDouble());

        // Convert date to display format with null safety
        try {
          DateTime date = DateTime.parse(dayData['date'] ?? '');
          dates.add('${date.day}/${date.month}');
        } catch (e) {
          // If date parsing fails, use current date
          final now = DateTime.now();
          dates.add('${now.day}/${now.month}');
        }
      }

      setState(() {
        weeklyData = {
          'calories': calories,
          'protein': protein,
          'carbs': carbs,
          'fat': fat,
        };
        weekDates = dates;
      });
    } catch (e) {
      print('Error fetching analytics data: $e');
      // Keep default empty data on error
      setState(() {
        weeklyData = {
          'calories': [0, 0, 0, 0, 0, 0, 0],
          'protein': [0, 0, 0, 0, 0, 0, 0],
          'carbs': [0, 0, 0, 0, 0, 0, 0],
          'fat': [0, 0, 0, 0, 0, 0, 0],
        };
        weekDates = _generateDefaultWeekDates();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<String> getWeekDates() {
    return weekDates.isNotEmpty ? weekDates : _generateDefaultWeekDates();
  }

  List<String> _generateDefaultWeekDates() {
    final now = DateTime.now();
    final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStart = currentWeekStart.subtract(
      Duration(days: selectedWeek * 7),
    );

    return List.generate(7, (index) {
      final date = weekStart.add(Duration(days: index));
      return '${date.day}/${date.month}';
    });
  }

  String getWeekRange() {
    final now = DateTime.now();
    final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStart = currentWeekStart.subtract(
      Duration(days: selectedWeek * 7),
    );
    final weekEnd = weekStart.add(const Duration(days: 6));

    return '${weekStart.day}/${weekStart.month} - ${weekEnd.day}/${weekEnd.month}';
  }

  void onWeekSelected(int week) {
    setState(() {
      selectedWeek = week;
    });
    _fetchAnalyticsData(); // Fetch new data when week changes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : userId == null
                ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Please login to view analytics',
                        style: TextStyle(fontSize: 16, color: AppColors.grey),
                      ),
                    ],
                  ),
                )
                : LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Date Range Selector
                          PeriodSelector(
                            selectedWeek: selectedWeek,
                            selectedMonth: selectedMonth,
                            selectedYear: selectedYear,
                            weekRange: getWeekRange(),
                            months: months,
                            onWeekSelected: onWeekSelected,
                          ),
                          const SizedBox(height: 20),

                          // Analytics Cards
                          AnalyticsCard(
                            title: 'Calories Consumption',
                            unit: 'kcal',
                            barColor: const Color(0xFF2196F3),
                            gradientColors: [
                              const Color(0xFF64B5F6),
                              const Color(0xFF2196F3),
                            ],
                            icon: Icons.local_fire_department,
                            chartData:
                                weeklyData['calories'] ?? [0, 0, 0, 0, 0, 0, 0],
                            weekDates: getWeekDates(),
                          ),
                          const SizedBox(height: 16),

                          AnalyticsCard(
                            title: 'Protein Consumption',
                            unit: 'g',
                            barColor: const Color(0xFFE57373),
                            gradientColors: [
                              const Color(0xFFEF5350),
                              const Color(0xFFE57373),
                            ],
                            icon: Icons.fitness_center,
                            chartData:
                                weeklyData['protein'] ?? [0, 0, 0, 0, 0, 0, 0],
                            weekDates: getWeekDates(),
                          ),
                          const SizedBox(height: 16),

                          AnalyticsCard(
                            title: 'Carbohydrates Consumption',
                            unit: 'g',
                            barColor: const Color(0xFFFFB74D),
                            gradientColors: [
                              const Color(0xFFFFCA28),
                              const Color(0xFFFFB74D),
                            ],
                            icon: Icons.grain,
                            chartData:
                                weeklyData['carbs'] ?? [0, 0, 0, 0, 0, 0, 0],
                            weekDates: getWeekDates(),
                          ),
                          const SizedBox(height: 16),

                          AnalyticsCard(
                            title: 'Fat Consumption',
                            unit: 'g',
                            barColor: const Color(0xFF81C784),
                            gradientColors: [
                              const Color(0xFF66BB6A),
                              const Color(0xFF81C784),
                            ],
                            icon: Icons.water_drop,
                            chartData:
                                weeklyData['fat'] ?? [0, 0, 0, 0, 0, 0, 0],
                            weekDates: getWeekDates(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
