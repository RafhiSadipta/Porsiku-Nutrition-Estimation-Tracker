import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../constants/constants.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _AnalyticsCard(
                title: 'Calories Consumption',
                barColor: const Color(0xFF2196F3),
                value: 810,
                valueColor: const Color(0xFF2196F3),
                chartData: [600, 400, 500, 500, 700, 800, 810],
              ),
              const SizedBox(height: 16),
              _AnalyticsCard(
                title: 'Protein Consumption',
                barColor: const Color(0xFFE57373),
                value: 810,
                valueColor: const Color(0xFFE57373),
                chartData: [600, 400, 500, 500, 700, 800, 810],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  final String title;
  final Color barColor;
  final int value;
  final Color valueColor;
  final List<int> chartData;
  const _AnalyticsCard({
    required this.title,
    required this.barColor,
    required this.value,
    required this.valueColor,
    required this.chartData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppTexts.md,
                  color: AppColors.black,
                ),
              ),
              const Spacer(),
              _Dropdown('May'),
              const SizedBox(width: 8),
              _Dropdown('Week 2'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceEvenly,
                maxY: 900,
                minY: 0,
                gridData: FlGridData(show: false),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    left: BorderSide(color: Colors.black, width: 2),
                    bottom: BorderSide(color: Colors.black, width: 2),
                    right: BorderSide.none,
                    top: BorderSide.none,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
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
                      getTitlesWidget: (value, meta) {
                        const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        int idx = value.toInt();
                        if (idx < 0 || idx > 6) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            days[idx],
                            style: TextStyle(
                              fontWeight:
                                  idx == 6
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                              fontSize: AppTexts.sm,
                              color: idx == 6 ? Colors.black : Colors.grey[600],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(7, (i) {
                  final isLast = i == 6;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: chartData[i].toDouble(),
                        color: isLast ? barColor : Colors.grey[350],
                        width: 18,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }),
                barTouchData: BarTouchData(enabled: false),
              ),
            ),
          ),
          // Value label di atas bar terakhir
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 120),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: valueColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  value.toString(),
                  style: TextStyle(
                    color: valueColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dropdown extends StatelessWidget {
  final String value;
  const _Dropdown(this.value);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: AppTexts.sm,
              color: AppColors.black,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.keyboard_arrow_down,
            size: 18,
            color: AppColors.grey,
          ),
        ],
      ),
    );
  }
}
