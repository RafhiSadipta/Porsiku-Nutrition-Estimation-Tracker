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
  });

  @override
  Widget build(BuildContext context) {
    final currentValue = chartData.last;
    final previousValue = chartData[chartData.length - 2];
    final changePercent =
        ((currentValue - previousValue) / previousValue * 100);

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
