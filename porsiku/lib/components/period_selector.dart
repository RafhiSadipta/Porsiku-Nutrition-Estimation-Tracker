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

  String _getWeekRangeFromDate(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    return '${weekStart.day}/${weekStart.month} - ${weekEnd.day}/${weekEnd.month}';
  }

  DateTime _getMondayOfWeek(int weeksBack) {
    final now = DateTime.now();
    // Get current Monday (weekday 1 = Monday)
    final currentMonday = now.subtract(Duration(days: now.weekday - 1));
    // Go back the specified number of weeks
    return currentMonday.subtract(Duration(days: weeksBack * 7));
  }

  @override
  Widget build(BuildContext context) {
    final currentWeekStart = _getMondayOfWeek(selectedWeek);
    final currentWeekRange = _getWeekRangeFromDate(currentWeekStart);

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
          const SizedBox(width: 12),          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Period',
                  style: TextStyle(fontSize: 12, color: AppColors.grey),
                ),
                Text(
                  currentWeekRange,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<int>(
            icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.grey),
            onSelected: onWeekSelected,
            itemBuilder:
                (context) => List.generate(4, (index) {
                  final weekStart = _getMondayOfWeek(index);
                  final weekRange = _getWeekRangeFromDate(weekStart);
                  final isSelected = index == selectedWeek;

                  return PopupMenuItem(
                    value: index,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              weekRange,
                              style: TextStyle(
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                color:
                                    isSelected
                                        ? AppColors.black
                                        : AppColors.grey,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check,
                              color: AppColors.black,
                              size: 16,
                            ),
                        ],
                      ),
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }
}
