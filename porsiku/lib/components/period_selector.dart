import 'package:flutter/material.dart';
import '../constants/constants.dart';

class PeriodSelector extends StatelessWidget {
  final int selectedWeek;
  final int selectedMonth;
  final int selectedYear;
  final String weekRange;
  final List<String> months;
  final Function(int) onWeekSelected;

  const PeriodSelector({
    super.key,
    required this.selectedWeek,
    required this.selectedMonth,
    required this.selectedYear,
    required this.weekRange,
    required this.months,
    required this.onWeekSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, color: AppColors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Period',
                  style: TextStyle(fontSize: 12, color: AppColors.grey),
                ),
                Text(
                  '${months[selectedMonth]} $selectedYear - Week ${selectedWeek + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  weekRange,
                  style: const TextStyle(fontSize: 12, color: AppColors.grey),
                ),
              ],
            ),
          ),
          PopupMenuButton<int>(
            icon: const Icon(Icons.more_vert),
            onSelected: onWeekSelected,
            itemBuilder:
                (context) => List.generate(4, (index) {
                  final weekStart = DateTime.now()
                      .subtract(Duration(days: DateTime.now().weekday - 1))
                      .subtract(Duration(days: index * 7));
                  final weekEnd = weekStart.add(const Duration(days: 6));
                  return PopupMenuItem(
                    value: index,
                    child: Text(
                      'Week ${index + 1} (${weekStart.day}/${weekStart.month} - ${weekEnd.day}/${weekEnd.month})',
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }
}
