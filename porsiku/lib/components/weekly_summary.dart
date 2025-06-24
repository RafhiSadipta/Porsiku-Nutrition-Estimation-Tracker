import 'package:flutter/material.dart';
import '../constants/constants.dart';

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
    final weeklyTotal = chartData.fold(0.0, (sum, value) => sum + value);
    final weeklyAverage = weeklyTotal / 7;
    final highestDay = chartData.reduce((a, b) => a > b ? a : b);
    final daysWithData = chartData.where((value) => value > 0).length;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [barColor.withOpacity(0.08), barColor.withOpacity(0.03)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(color: barColor.withOpacity(0.15), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: barColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppBorderRadius.xs),
                ),
                child: Icon(
                  Icons.analytics_outlined,
                  color: barColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Week Summary',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: AppTexts.semiBold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Statistics
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Daily Average',
                  weeklyAverage.toStringAsFixed(
                    weeklyAverage == weeklyAverage.toInt() ? 0 : 1,
                  ),
                  unit,
                  barColor,
                  Icons.trending_up_rounded,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildStatItem(
                  'Weekly Total',
                  weeklyTotal.toStringAsFixed(
                    weeklyTotal == weeklyTotal.toInt() ? 0 : 1,
                  ),
                  unit,
                  barColor,
                  Icons.summarize_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Highest Day',
                  highestDay.toStringAsFixed(
                    highestDay == highestDay.toInt() ? 0 : 1,
                  ),
                  unit,
                  barColor,
                  Icons.arrow_upward_rounded,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildStatItem(
                  'Active Days',
                  daysWithData.toString(),
                  'days',
                  barColor,
                  Icons.calendar_today_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    String unit,
    Color color,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color.withOpacity(0.7)),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: AppTexts.medium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: AppTexts.bold,
                  color: color,
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
    );
  }
}
