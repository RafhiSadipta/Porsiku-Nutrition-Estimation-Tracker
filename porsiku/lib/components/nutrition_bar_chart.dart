import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

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

class _NutritionBarChartState extends State<NutritionBarChart> {
  int? touchedIndex;
  @override
  Widget build(BuildContext context) {
    // Create display data with minimum value of 1 for chart visualization
    final displayData =
        widget.chartData.map((value) => value == 0 ? 1.0 : value).toList();
    final maxValue = displayData.reduce((a, b) => a > b ? a : b);

    // Ensure maxValue is not zero to avoid horizontalInterval being zero
    final chartMaxValue = maxValue == 0 ? 100.0 : maxValue;
    final horizontalInterval = chartMaxValue * 0.2;
    return SizedBox(
      height: 200, // Increase height to accommodate bottom titles
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceEvenly,
          maxY: chartMaxValue * 1.2,
          minY: 0,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval:
                horizontalInterval > 0 ? horizontalInterval : 20.0,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.2),
                strokeWidth: 1,
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
                interval:
                    chartMaxValue > 0
                        ? chartMaxValue * 0.4
                        : 20.0, // Safe interval
                getTitlesWidget: (value, meta) {
                  // Show original value scale, not display value scale
                  final originalMaxValue = widget.chartData.reduce(
                    (a, b) => a > b ? a : b,
                  );
                  final displayValue =
                      originalMaxValue > 0
                          ? (value * originalMaxValue / chartMaxValue).toInt()
                          : value.toInt();

                  return Text(
                    displayValue.toString(),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50, // Increase reserved size to prevent overflow
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

                  // Calculate if this day is today based on Monday-start week
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
                    padding: const EdgeInsets.only(
                      top: 4,
                    ), // Reduce top padding
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          days[idx],
                          style: TextStyle(
                            fontWeight:
                                isToday ? FontWeight.bold : FontWeight.normal,
                            fontSize: 10, // Reduce font size
                            color: isToday ? widget.barColor : Colors.grey[600],
                          ),
                        ),
                        Text(
                          widget.weekDates[idx],
                          style: TextStyle(
                            fontSize: 8, // Reduce font size
                            color: Colors.grey[500],
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
            // Calculate if this day is today based on Monday-start week
            final now = DateTime.now();
            final currentMonday = now.subtract(Duration(days: now.weekday - 1));
            final dayInWeek = currentMonday.add(Duration(days: i));
            final isToday =
                dayInWeek.day == now.day &&
                dayInWeek.month == now.month &&
                dayInWeek.year == now.year;
            final isTouched = touchedIndex == i;
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY:
                      displayData[i], // Use displayData for chart visualization
                  gradient:
                      isToday || isTouched
                          ? LinearGradient(
                            colors: widget.gradientColors,
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          )
                          : LinearGradient(
                            colors: [Colors.grey[300]!, Colors.grey[400]!],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                  width: isTouched ? 24 : 20,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            );
          }),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => widget.barColor.withOpacity(0.9),
              tooltipBorder: BorderSide.none,
              tooltipBorderRadius: BorderRadius.circular(8),
              tooltipPadding: const EdgeInsets.all(8),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                // Show original value in tooltip, not display value
                final originalValue = widget.chartData[groupIndex];
                return BarTooltipItem(
                  '${originalValue.toInt()} ${widget.unit}\n',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  children: [
                    TextSpan(
                      text: widget.weekDates[groupIndex],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
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
  }
}
