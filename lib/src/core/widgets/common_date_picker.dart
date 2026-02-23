import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_colors.dart';

/// Replaces iOS SimpleCustomView.swift UIDatePicker XIB.
/// Supports: date only, time only (12h/24h), date+time modes.
class CommonDatePicker {
  CommonDatePicker._();

  /// Show date-only picker.
  /// iOS: SimpleCustomView with lblTitle == "Date"
  /// Returns selected date formatted as "yyyy-MM-dd".
  static Future<String?> showDateOnly(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime(2100),
      builder: (context, child) => _themedPicker(context, child),
    );
    if (picked == null) return null;
    return DateFormat('yyyy-MM-dd').format(picked);
  }

  /// Show time-only picker (12-hour with AM/PM).
  /// iOS: SimpleCustomView with lblTitle == "Time12Hours"
  /// Returns selected time as "hh:mm a".
  static Future<String?> showTime12Hour(
    BuildContext context, {
    TimeOfDay? initialTime,
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
      builder: (context, child) => _themedPicker(
        context,
        MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        ),
      ),
    );
    if (picked == null) return null;
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
    return DateFormat('hh:mm a').format(dt);
  }

  /// Show time-only picker (24-hour without AM/PM).
  /// iOS: SimpleCustomView with lblTitle == "Time"
  /// Returns selected time as "HH:mm".
  static Future<String?> showTime24Hour(
    BuildContext context, {
    TimeOfDay? initialTime,
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
      builder: (context, child) => _themedPicker(
        context,
        MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        ),
      ),
    );
    if (picked == null) return null;
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
    return DateFormat('HH:mm').format(dt);
  }

  /// Show date + time picker.
  /// iOS: SimpleCustomView with lblTitle == "DateAndTime"
  /// Returns "yyyy-MM-dd hh:mm a".
  static Future<String?> showDateTime(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    TimeOfDay? initialTime,
  }) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime(2100),
      builder: (context, child) => _themedPicker(context, child),
    );
    if (pickedDate == null) return null;

    if (!context.mounted) return null;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
      builder: (context, child) => _themedPicker(context, child),
    );
    if (pickedTime == null) return null;

    final dt = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
    return DateFormat('yyyy-MM-dd hh:mm a').format(dt);
  }

  /// Apply app theme to pickers.
  static Widget _themedPicker(BuildContext context, Widget? child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: AppColors.textOnPrimary,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
      ),
      child: child!,
    );
  }
}
