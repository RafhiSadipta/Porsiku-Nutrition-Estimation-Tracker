import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        boxShadow: AppShadows.card,
        border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 1),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.05),
                  AppColors.primaryLight.withOpacity(0.02),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppBorderRadius.lg),
                topRight: Radius.circular(AppBorderRadius.lg),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppGradients.primary,
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  ),
                  child: const Icon(
                    Icons.calendar_today_rounded,
                    color: AppColors.white,
                    size: 20,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Week Period',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: AppTexts.medium,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        currentWeekRange,
                        style: AppTextStyles.h4.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: AppTexts.semiBold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ), // Week selector dropdown
          Container(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Week',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: AppTexts.medium,
                  ),
                ),
                SizedBox(height: AppSpacing.md),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: selectedWeek,
                      isExpanded: true,
                      onChanged: (int? newValue) {
                        if (newValue != null) {
                          HapticFeedback.lightImpact();
                          onWeekSelected(newValue);
                        }
                      },
                      dropdownColor: AppColors.white,
                      borderRadius: BorderRadius.circular(AppBorderRadius.md),
                      elevation: 8,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      icon: Container(
                        margin: EdgeInsets.only(right: AppSpacing.md),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      items: List.generate(8, (index) {
                        final weekStart = _getMondayOfWeek(index);
                        final range = _getWeekRangeFromDate(weekStart);
                        final isCurrentWeek = index == 0;

                        return DropdownMenuItem<int>(
                          value: index,
                          child: Container(
                            constraints: const BoxConstraints(maxHeight: 40),
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 4,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Compact week indicator
                                Icon(
                                  isCurrentWeek
                                      ? Icons.today_rounded
                                      : Icons.calendar_month_rounded,
                                  size: 14,
                                  color:
                                      isCurrentWeek
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
                                ),
                                SizedBox(width: AppSpacing.sm),
                                // Compact week details
                                Flexible(
                                  child: Text(
                                    isCurrentWeek
                                        ? 'This Week ($range)'
                                        : 'Week ${index + 1} ($range)',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color:
                                          isCurrentWeek
                                              ? AppColors.primary
                                              : AppColors.textPrimary,
                                      fontWeight:
                                          isCurrentWeek
                                              ? AppTexts.semiBold
                                              : AppTexts.medium,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      selectedItemBuilder: (BuildContext context) {
                        return List.generate(8, (index) {
                          final isCurrentWeek = index == 0;

                          return Container(
                            constraints: const BoxConstraints(maxHeight: 48),
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    gradient:
                                        isCurrentWeek
                                            ? AppGradients.primary
                                            : null,
                                    color:
                                        isCurrentWeek
                                            ? null
                                            : AppColors.primary.withOpacity(
                                              0.1,
                                            ),
                                    borderRadius: BorderRadius.circular(
                                      AppBorderRadius.sm,
                                    ),
                                  ),
                                  child: Icon(
                                    isCurrentWeek
                                        ? Icons.today_rounded
                                        : Icons.calendar_month_rounded,
                                    size: 14,
                                    color:
                                        isCurrentWeek
                                            ? AppColors.white
                                            : AppColors.primary,
                                  ),
                                ),
                                SizedBox(width: AppSpacing.sm),
                                Flexible(
                                  child: Text(
                                    isCurrentWeek
                                        ? 'This Week'
                                        : 'Week ${index + 1}',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: AppTexts.semiBold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        });
                      },
                    ),
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
