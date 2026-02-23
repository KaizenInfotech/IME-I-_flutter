import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Port of iOS CVCalendar-based month view — simplified using table_calendar.
/// Shows calendar grid with event markers, month navigation.
class CelebrationCalendarGrid extends StatelessWidget {
  const CelebrationCalendarGrid({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.eventDates,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Set<DateTime> eventDates;
  final void Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;
  final ValueChanged<DateTime> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      firstDay: DateTime(2015, 1, 1),
      lastDay: DateTime(2035, 12, 31),
      focusedDay: focusedDay,
      selectedDayPredicate: (day) =>
          selectedDay != null && isSameDay(selectedDay, day),
      eventLoader: (day) {
        final normalizedDay = DateTime(day.year, day.month, day.day);
        return eventDates.contains(normalizedDay) ? ['event'] : [];
      },
      enabledDayPredicate: (day) {
        final today = DateTime.now();
        final normalizedToday = DateTime(today.year, today.month, today.day);
        final normalizedDay = DateTime(day.year, day.month, day.day);
        return !normalizedDay.isBefore(normalizedToday);
      },
      onDaySelected: onDaySelected,
      onPageChanged: onPageChanged,
      calendarFormat: CalendarFormat.month,
      availableCalendarFormats: const {CalendarFormat.month: 'Month'},
      startingDayOfWeek: StartingDayOfWeek.sunday,
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: const TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        leftChevronIcon: const Icon(
          Icons.chevron_left,
          color: AppColors.primary,
        ),
        rightChevronIcon: const Icon(
          Icons.chevron_right,
          color: AppColors.primary,
        ),
      ),
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
        weekendStyle: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ),
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: AppColors.primary.withAlpha(51),
          shape: BoxShape.circle,
        ),
        todayTextStyle: const TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
        selectedDecoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        selectedTextStyle: const TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textOnPrimary,
        ),
        defaultTextStyle: const TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
        weekendTextStyle: const TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
        disabledTextStyle: const TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 14,
          color: AppColors.grayMedium,
        ),
        outsideTextStyle: const TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 14,
          color: AppColors.grayMedium,
        ),
        markerDecoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        markerSize: 5,
        markersMaxCount: 1,
        markerMargin: const EdgeInsets.symmetric(horizontal: 0.5),
      ),
    );
  }
}
