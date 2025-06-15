import 'package:flutter/material.dart';

class WeeklySummary extends StatelessWidget {
  final Color barColor;
  final String unit;
  final List<double> chartData;

  const WeeklySummary({
    super.key,
    required this.barColor,
    required this.unit,
    required this.chartData,
  });

  @override
  Widget build(BuildContext context) {
    final weeklyTotal = chartData.reduce((a, b) => a + b);
    final weeklyAverage = weeklyTotal / 7;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: barColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekly Average',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  '${weeklyAverage.toStringAsFixed(0)} $unit',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: barColor,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekly Total',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  '${weeklyTotal.toStringAsFixed(0)} $unit',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: barColor,
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
