import 'package:flutter/material.dart';
import '../constants/constants.dart';
import 'metric_header.dart';
import 'nutrition_bar_chart.dart';
import 'weekly_summary.dart';

class AnalyticsCard extends StatelessWidget {
  final String title;
  final String unit;
  final Color barColor;
  final List<Color> gradientColors;
  final IconData icon;
  final List<double> chartData;
  final List<String> weekDates;

  const AnalyticsCard({
    super.key,
    required this.title,
    required this.unit,
    required this.barColor,
    required this.gradientColors,
    required this.icon,
    required this.chartData,
    required this.weekDates,
  });  @override
  Widget build(BuildContext context) {
    // Find the most recent non-zero value as current
    double currentValue = 0.0;
    double previousValue = 0.0;
    
    // Find current value (most recent non-zero or last value)
    for (int i = chartData.length - 1; i >= 0; i--) {
      if (chartData[i] > 0) {
        currentValue = chartData[i];
        break;
      }
    }
    
    // If all values are 0, use the last value
    if (currentValue == 0) {
      currentValue = chartData.last;
    }
    
    // Find previous value (previous non-zero value before current)
    int currentIndex = chartData.lastIndexWhere((value) => value == currentValue);
    for (int i = currentIndex - 1; i >= 0; i--) {
      if (chartData[i] > 0) {
        previousValue = chartData[i];
        break;
      }
    }
    
    // Calculate change percent with proper handling
    double changePercent = 0.0;
    if (previousValue > 0 && !previousValue.isNaN && !currentValue.isNaN) {
      changePercent = ((currentValue - previousValue) / previousValue * 100);
      // Ensure the result is finite
      if (!changePercent.isFinite) {
        changePercent = 0.0;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          MetricHeader(
            title: title,
            unit: unit,
            barColor: barColor,
            icon: icon,
            currentValue: currentValue,
            changePercent: changePercent,
          ),
          const SizedBox(height: 20),

          // Chart
          NutritionBarChart(
            chartData: chartData,
            weekDates: weekDates,
            barColor: barColor,
            gradientColors: gradientColors,
            unit: unit,
          ),

          // Weekly Summary
          const SizedBox(height: 16),
          WeeklySummary(barColor: barColor, unit: unit, chartData: chartData),
        ],
      ),
    );
  }
}
