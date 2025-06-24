import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../constants/constants.dart';

class NutritionBarChart extends StatefulWidget {
  final List<double> chartData;
  final List<String> weekDates;
  final Color barColor;
  final List<Color> gradientColors;
  final String unit;

  const NutritionBarChart({
    super.key,
    required this.chartData,
    required this.weekDates,
    required this.barColor,
    required this.gradientColors,
    required this.unit,
  });

  @override
  State<NutritionBarChart> createState() => _NutritionBarChartState();
}

class _NutritionBarChartState extends State<NutritionBarChart>
    with SingleTickerProviderStateMixin {
  int? touchedIndex;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Create display data with minimum value of 1 for chart visualization
    final displayData =
        widget.chartData.map((value) => value == 0 ? 1.0 : value).toList();
    final maxValue = displayData.reduce((a, b) => a > b ? a : b);

    // Ensure maxValue is not zero to avoid horizontalInterval being zero
    final chartMaxValue = maxValue == 0 ? 100.0 : maxValue;
    final horizontalInterval = chartMaxValue * 0.25;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: 220,
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.background.withOpacity(0.5),
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
            border: Border.all(
              color: widget.barColor.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceEvenly,
              maxY: chartMaxValue * 1.2,
              minY: 0,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval:
                    horizontalInterval > 0 ? horizontalInterval : 25.0,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: AppColors.lightGrey.withOpacity(0.3),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  );
                },
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                show: true,
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: chartMaxValue > 0 ? chartMaxValue * 0.4 : 25.0,
                    getTitlesWidget: (value, meta) {
                      final originalMaxValue = widget.chartData.reduce(
                        (a, b) => a > b ? a : b,
                      );
                      final displayValue =
                          originalMaxValue > 0
                              ? (value * originalMaxValue / chartMaxValue)
                                  .toInt()
                              : value.toInt();

                      return Text(
                        displayValue.toString(),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                          fontWeight: AppTexts.medium,
                        ),
                      );
                    },
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 55,
                    getTitlesWidget: (value, meta) {
                      const days = [
                        'Mon',
                        'Tue',
                        'Wed',
                        'Thu',
                        'Fri',
                        'Sat',
                        'Sun',
                      ];
                      int idx = value.toInt();
                      if (idx < 0 || idx > 6) return const SizedBox();

                      // Calculate if this day is today
                      final now = DateTime.now();
                      final currentMonday = now.subtract(
                        Duration(days: now.weekday - 1),
                      );
                      final dayInWeek = currentMonday.add(Duration(days: idx));
                      final isToday =
                          dayInWeek.day == now.day &&
                          dayInWeek.month == now.month &&
                          dayInWeek.year == now.year;

                      return Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Day label
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xs,
                                vertical: 2,
                              ),
                              decoration:
                                  isToday
                                      ? BoxDecoration(
                                        color: widget.barColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(
                                          AppBorderRadius.xs,
                                        ),
                                      )
                                      : null,
                              child: Text(
                                days[idx],
                                style: AppTextStyles.caption.copyWith(
                                  fontWeight:
                                      isToday
                                          ? AppTexts.semiBold
                                          : AppTexts.medium,
                                  color:
                                      isToday
                                          ? widget.barColor
                                          : AppColors.textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            // Date label
                            Text(
                              widget.weekDates[idx],
                              style: AppTextStyles.caption.copyWith(
                                fontSize: 9,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              barGroups: List.generate(7, (i) {
                // Calculate if this day is today
                final now = DateTime.now();
                final currentMonday = now.subtract(
                  Duration(days: now.weekday - 1),
                );
                final dayInWeek = currentMonday.add(Duration(days: i));
                final isToday =
                    dayInWeek.day == now.day &&
                    dayInWeek.month == now.month &&
                    dayInWeek.year == now.year;
                final isTouched = touchedIndex == i;
                final hasValue = widget.chartData[i] > 0;

                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: displayData[i] * _animation.value,
                      gradient:
                          hasValue
                              ? LinearGradient(
                                colors:
                                    isToday || isTouched
                                        ? widget.gradientColors
                                        : [
                                          widget.barColor.withOpacity(0.7),
                                          widget.barColor.withOpacity(0.4),
                                        ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              )
                              : LinearGradient(
                                colors: [
                                  AppColors.lightGrey.withOpacity(0.3),
                                  AppColors.lightGrey.withOpacity(0.1),
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                      width: isTouched ? 28 : 24,
                      borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                      borderSide:
                          isToday && hasValue
                              ? BorderSide(color: widget.barColor, width: 2)
                              : BorderSide.none,
                    ),
                  ],
                );
              }),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (group) => AppColors.black.withOpacity(0.9),
                  tooltipBorder: BorderSide.none,
                  tooltipBorderRadius: BorderRadius.circular(
                    AppBorderRadius.sm,
                  ),
                  tooltipPadding: const EdgeInsets.all(AppSpacing.md),
                  tooltipMargin: AppSpacing.sm,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final originalValue = widget.chartData[groupIndex];
                    return BarTooltipItem(
                      '${originalValue.toStringAsFixed(originalValue == originalValue.toInt() ? 0 : 1)} ${widget.unit}',
                      AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white,
                        fontWeight: AppTexts.semiBold,
                      ),
                      children: [
                        TextSpan(
                          text: '\n${widget.weekDates[groupIndex]}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                touchCallback: (FlTouchEvent event, barTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        barTouchResponse == null ||
                        barTouchResponse.spot == null) {
                      touchedIndex = null;
                      return;
                    }
                    touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
                  });
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
