import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/constants.dart';
import '../../components/analytics_card.dart';
import '../../services/api_service.dart';

// Import Period Selector separately to avoid conflicts
import '../../components/period_selector.dart' as period_selector;

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage>
    with TickerProviderStateMixin {
  int selectedWeek = 0;
  int selectedMonth = DateTime.now().month - 1;
  int selectedYear = DateTime.now().year;
  bool isLoading = true;
  String? userId;
  late AnimationController _refreshController;
  late AnimationController _cardsController;

  // Real data from backend
  Map<String, List<double>> weeklyData = {
    'calories': [0, 0, 0, 0, 0, 0, 0],
    'protein': [0, 0, 0, 0, 0, 0, 0],
    'carbs': [0, 0, 0, 0, 0, 0, 0],
    'fat': [0, 0, 0, 0, 0, 0, 0],
  };

  List<String> weekDates = [];

  // Analytics summary data
  Map<String, double> weekSummary = {
    'totalCalories': 0,
    'avgCalories': 0,
    'totalProtein': 0,
    'totalCarbs': 0,
    'totalFat': 0,
  };

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
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _cardsController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _loadUserData();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _cardsController.dispose();
    super.dispose();
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
        _calculateWeekSummary();
      });

      // Trigger cards animation
      _cardsController.reset();
      _cardsController.forward();
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
        _calculateWeekSummary();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _calculateWeekSummary() {
    final calories = weeklyData['calories'] ?? [];
    final protein = weeklyData['protein'] ?? [];
    final carbs = weeklyData['carbs'] ?? [];
    final fat = weeklyData['fat'] ?? [];

    weekSummary = {
      'totalCalories': calories.fold(0.0, (sum, val) => sum + val),
      'avgCalories':
          calories.isNotEmpty
              ? calories.fold(0.0, (sum, val) => sum + val) / calories.length
              : 0.0,
      'totalProtein': protein.fold(0.0, (sum, val) => sum + val),
      'totalCarbs': carbs.fold(0.0, (sum, val) => sum + val),
      'totalFat': fat.fold(0.0, (sum, val) => sum + val),
    };
  }

  List<String> getWeekDates() {
    return weekDates.isNotEmpty ? weekDates : _generateDefaultWeekDates();
  }

  List<String> _generateDefaultWeekDates() {
    final now = DateTime.now();
    // Get Monday of current week (weekday 1 = Monday)
    final currentMonday = now.subtract(Duration(days: now.weekday - 1));
    // Go back the specified number of weeks from current Monday
    final weekStart = currentMonday.subtract(Duration(days: selectedWeek * 7));

    return List.generate(7, (index) {
      final date = weekStart.add(Duration(days: index));
      return '${date.day}/${date.month}';
    });
  }

  String getWeekRange() {
    final now = DateTime.now();
    // Get Monday of current week (weekday 1 = Monday)
    final currentMonday = now.subtract(Duration(days: now.weekday - 1));
    // Go back the specified number of weeks from current Monday
    final weekStart = currentMonday.subtract(Duration(days: selectedWeek * 7));
    final weekEnd = weekStart.add(const Duration(days: 6));

    return '${weekStart.day}/${weekStart.month} - ${weekEnd.day}/${weekEnd.month}';
  }

  void onWeekSelected(int week) {
    setState(() {
      selectedWeek = week;
    });
    HapticFeedback.lightImpact();
    _fetchAnalyticsData(); // Fetch new data when week changes
  }

  // Pull to refresh function
  Future<void> _onRefresh() async {
    HapticFeedback.mediumImpact();
    _refreshController.reset();
    _refreshController.forward();
    await _fetchAnalyticsData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child:
            isLoading
                ? _buildLoadingState()
                : userId == null
                ? _buildErrorState()
                : RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: AppColors.primary,
                  backgroundColor: AppColors.white,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // Period Selector
                      SliverToBoxAdapter(child: _buildPeriodSelector()),

                      // Week Summary Cards
                      SliverToBoxAdapter(child: _buildWeekSummary()),

                      // Analytics Charts
                      SliverToBoxAdapter(child: _buildAnalyticsCards()),

                      // Bottom spacing
                      SliverToBoxAdapter(
                        child: SizedBox(height: AppSpacing.xl),
                      ),
                    ],
                  ),
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
                  gradient: AppGradients.primary,
                  borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  size: 40,
                  color: AppColors.white,
                ),
              )
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 1200.ms)
              .scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1.1, 1.1),
                duration: 1000.ms,
                curve: Curves.easeInOut,
              ),
          SizedBox(height: AppSpacing.lg),
          Text(
                'Loading Analytics...',
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.textSecondary,
                ),
              )
              .animate()
              .fadeIn(duration: 600.ms, delay: 300.ms)
              .slideY(begin: 0.3, end: 0),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Container(
            margin: EdgeInsets.all(AppSpacing.lg),
            padding: EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              boxShadow: AppShadows.card,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    size: 40,
                    color: AppColors.error,
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
                Text(
                  'Unable to Load Analytics',
                  style: AppTextStyles.h4,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'Please check your connection and try again',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  onPressed: _loadUserData,
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
                  child: const Text('Retry'),
                ),
              ],
            ),
          )
          .animate()
          .fadeIn(duration: 600.ms)
          .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0)),
    );
  }

  Widget _buildWeekSummary() {
    return Container(
      margin: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                    'Weekly Overview',
                    style: AppTextStyles.h4.copyWith(
                      fontWeight: AppTexts.semiBold,
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 100.ms)
                  .slideX(begin: -0.3, end: 0),
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
                      getWeekRange(),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: AppTexts.medium,
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 200.ms)
                  .scale(begin: const Offset(0.8, 0.8)),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Calories',
                  weekSummary['totalCalories']?.toStringAsFixed(0) ?? '0',
                  'kcal',
                  AppColors.blue,
                  Icons.local_fire_department_rounded,
                  0,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildSummaryCard(
                  'Daily Average',
                  weekSummary['avgCalories']?.toStringAsFixed(0) ?? '0',
                  'kcal',
                  AppColors.primary,
                  Icons.trending_up_rounded,
                  1,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Protein',
                  weekSummary['totalProtein']?.toStringAsFixed(1) ?? '0',
                  'g',
                  AppColors.red,
                  Icons.fitness_center_rounded,
                  2,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildSummaryCard(
                  'Carbs',
                  weekSummary['totalCarbs']?.toStringAsFixed(1) ?? '0',
                  'g',
                  AppColors.yellow,
                  Icons.bakery_dining_rounded,
                  3,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildSummaryCard(
                  'Fat',
                  weekSummary['totalFat']?.toStringAsFixed(1) ?? '0',
                  'g',
                  AppColors.green,
                  Icons.eco_rounded,
                  4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    String unit,
    Color color,
    IconData icon,
    int index,
  ) {
    return AnimatedBuilder(
      animation: _cardsController,
      builder: (context, child) {
        final animation = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: _cardsController,
            curve: Interval(
              index * 0.1,
              0.6 + (index * 0.1),
              curve: Curves.easeOutBack,
            ),
          ),
        );

        return Transform.scale(
          scale: animation.value,
          child: Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              boxShadow: AppShadows.card,
              border: Border.all(color: color.withOpacity(0.1), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  title,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: AppTexts.medium,
                  ),
                ),
                const SizedBox(height: 2),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: value,
                        style: AppTextStyles.h4.copyWith(
                          color: color,
                          fontWeight: AppTexts.bold,
                        ),
                      ),
                      TextSpan(
                        text: ' $unit',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      margin: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md, // Added consistent top margin
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: period_selector.PeriodSelector(
            selectedWeek: selectedWeek,
            selectedMonth: selectedMonth,
            selectedYear: selectedYear,
            weekRange: getWeekRange(),
            months: months,
            onWeekSelected: onWeekSelected,
          )
          .animate()
          .fadeIn(duration: 600.ms, delay: 300.ms)
          .slideY(begin: 0.3, end: 0),
    );
  }

  Widget _buildAnalyticsCards() {
    final cardsData = [
      {
        'title': 'Calories',
        'unit': 'kcal',
        'color': AppColors.blue,
        'gradientColors': [AppColors.blue, const Color(0xFF64B5F6)],
        'icon': Icons.local_fire_department_rounded,
        'data': weeklyData['calories'] ?? [],
      },
      {
        'title': 'Protein',
        'unit': 'g',
        'color': AppColors.red,
        'gradientColors': [AppColors.red, const Color(0xFFEF5350)],
        'icon': Icons.fitness_center_rounded,
        'data': weeklyData['protein'] ?? [],
      },
      {
        'title': 'Carbs',
        'unit': 'g',
        'color': AppColors.yellow,
        'gradientColors': [AppColors.yellow, const Color(0xFFFFB74D)],
        'icon': Icons.bakery_dining_rounded,
        'data': weeklyData['carbs'] ?? [],
      },
      {
        'title': 'Fat',
        'unit': 'g',
        'color': AppColors.green,
        'gradientColors': [AppColors.green, const Color(0xFF81C784)],
        'icon': Icons.eco_rounded,
        'data': weeklyData['fat'] ?? [],
      },
    ];

    return Container(
      margin: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
                'Weekly Breakdown',
                style: AppTextStyles.h4.copyWith(fontWeight: AppTexts.semiBold),
              )
              .animate()
              .fadeIn(duration: 600.ms, delay: 400.ms)
              .slideX(begin: -0.3, end: 0),
          SizedBox(height: AppSpacing.sm),
          ...cardsData.asMap().entries.map((entry) {
            final index = entry.key;
            final card = entry.value;

            return AnimatedBuilder(
              animation: _cardsController,
              builder: (context, child) {
                final animation = Tween<double>(begin: 0, end: 1).animate(
                  CurvedAnimation(
                    parent: _cardsController,
                    curve: Interval(
                      0.3 + (index * 0.15),
                      0.8 + (index * 0.1),
                      curve: Curves.easeOutBack,
                    ),
                  ),
                );

                return Transform.translate(
                  offset: Offset(0, 50 * (1 - animation.value)),
                  child: Opacity(
                    opacity: animation.value,
                    child: Container(
                      margin: EdgeInsets.only(
                        bottom:
                            index < cardsData.length - 1 ? AppSpacing.lg : 0,
                      ),
                      child: AnalyticsCard(
                        title: card['title'] as String,
                        unit: card['unit'] as String,
                        barColor: card['color'] as Color,
                        gradientColors: card['gradientColors'] as List<Color>,
                        icon: card['icon'] as IconData,
                        chartData: card['data'] as List<double>,
                        weekDates: getWeekDates(),
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ],
      ),
    );
  }
}
