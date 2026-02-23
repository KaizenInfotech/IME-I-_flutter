import 'package:intl/intl.dart';

/// Port of iOS date-related extensions and utilities.
/// Dart extension on DateTime? for null-safe date operations.
extension NullableDateExtension on DateTime? {
  /// Format date or return empty string if null.
  String format(String pattern) {
    if (this == null) return '';
    try {
      return DateFormat(pattern).format(this!);
    } catch (_) {
      return '';
    }
  }

  /// Check if date is null.
  bool get isNull => this == null;
}

/// Date extensions on non-null DateTime.
extension DateExtension on DateTime {
  /// Format as "dd MMM yyyy" (e.g. "29 Jun 2020").
  String get dayMonthYear => DateFormat('dd MMM yyyy').format(this);

  /// Format as "dd MMM yyyy hh:mm a" matching iOS notification date format.
  String get dayMonthYearTime => DateFormat('dd MMM yyyy hh:mm a').format(this);

  /// Format as "yyyy-MM-dd" matching iOS functionForGetTodatDayMonthYear.
  String get isoDate => DateFormat('yyyy-MM-dd').format(this);

  /// Format as "MMdd" matching iOS functionForGetTodatDate.
  String get monthDay => DateFormat('MMdd').format(this);

  /// Format as "yyyy" matching iOS functionForGetCurrentYear.
  String get yearOnly => DateFormat('yyyy').format(this);

  /// Format as "dd/MM/yyyy".
  String get slashDate => DateFormat('dd/MM/yyyy').format(this);

  /// Check if this date is the same day as another.
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// Check if this date is today.
  bool get isToday => isSameDay(DateTime.now());

  /// Check if this date is yesterday.
  bool get isYesterday =>
      isSameDay(DateTime.now().subtract(const Duration(days: 1)));

  /// Check if this date is tomorrow.
  bool get isTomorrow =>
      isSameDay(DateTime.now().add(const Duration(days: 1)));

  /// Port of iOS Calendar.current.date + 3 days (expiry date calc).
  DateTime get plusThreeDays => add(const Duration(days: 3));

  /// Port of iOS functionForCompareDatewithTime — compare two dates.
  /// Returns "Descending", "Same", or "Ascending".
  String compareTo2(DateTime other) {
    if (isAfter(other)) return 'Descending';
    if (isAtSameMomentAs(other)) return 'Same';
    return 'Ascending';
  }

  /// Relative date string for display.
  String get relativeString {
    final now = DateTime.now();
    final diff = now.difference(this);
    if (diff.inDays == 0 && day == now.day) return 'Today';
    if (diff.inDays == 1 || (diff.inHours < 48 && day == now.day - 1)) {
      return 'Yesterday';
    }
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return dayMonthYear;
  }
}

/// Extension on String for date parsing.
extension DateParsingExtension on String {
  /// Try to parse a date string with the given format.
  DateTime? tryParseDate(String format) {
    try {
      return DateFormat(format).parse(this);
    } catch (_) {
      return null;
    }
  }

  /// Try to parse common date formats used in the app.
  DateTime? get tryParseAnyDate {
    final formats = [
      'yyyy-MM-dd HH:mm:ss',
      'yyyy-MM-dd hh:mm a',
      'yyyy-MM-dd',
      'dd-MM-yyyy',
      'dd/MM/yyyy',
      'dd MMM yyyy',
      'dd MMM yyyy hh:mm a',
      'MM/dd/yyyy',
    ];
    for (final fmt in formats) {
      try {
        return DateFormat(fmt).parse(this);
      } catch (_) {
        continue;
      }
    }
    return DateTime.tryParse(this);
  }
}
