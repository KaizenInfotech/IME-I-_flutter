import 'package:intl/intl.dart';

/// Port of iOS commonClassFunction date methods from CommonExtension.swift.
/// Static utility methods for date formatting, month parsing, and comparisons.
class AppDateUtils {
  AppDateUtils._();

  // ═══════════════════════════════════════════════════════
  // Month number to abbreviation maps
  // ═══════════════════════════════════════════════════════

  /// iOS: functionForMonthWordWise — month number to abbreviated name.
  static const Map<String, String> _monthAbbreviations = {
    '01': 'Jan', '1': 'Jan',
    '02': 'Feb', '2': 'Feb',
    '03': 'Mar', '3': 'Mar',
    '04': 'April', '4': 'April',
    '05': 'May', '5': 'May',
    '06': 'Jun', '6': 'Jun',
    '07': 'Jul', '7': 'Jul',
    '08': 'Aug', '8': 'Aug',
    '09': 'Sep', '9': 'Sep',
    '10': 'Oct',
    '11': 'Nov',
    '12': 'Dec',
  };

  /// iOS: functionForMonthWordWiseNEwdate — alternate month abbreviations.
  static const Map<String, String> _monthAbbreviationsAlt = {
    '01': 'Jan', '1': 'Jan',
    '02': 'Feb', '2': 'Feb',
    '03': 'Mar', '3': 'Mar',
    '04': 'Apr', '4': 'Apr',
    '05': 'May', '5': 'May',
    '06': 'Jun', '6': 'Jun',
    '07': 'Jul', '7': 'Jul',
    '08': 'Aug', '8': 'Aug',
    '09': 'Sept', '9': 'Sept',
    '10': 'Oct',
    '11': 'Nov',
    '12': 'Dec',
  };

  /// Port of iOS functionForMonthWordWise.
  /// Returns abbreviated month name for a given month number string.
  static String monthWordWise(String? monthNumber) {
    if (monthNumber == null || monthNumber.isEmpty) return '';
    return _monthAbbreviations[monthNumber] ?? '';
  }

  /// Port of iOS functionForMonthWordWiseNEwdate.
  /// Returns alternate abbreviated month name (Sept vs Sep).
  static String monthWordWiseAlt(String? monthNumber) {
    if (monthNumber == null || monthNumber.isEmpty) return '';
    return _monthAbbreviationsAlt[monthNumber] ?? '';
  }

  // ═══════════════════════════════════════════════════════
  // Today / Current date helpers
  // ═══════════════════════════════════════════════════════

  /// iOS: functionForGetTodatDate — returns today as "MMdd".
  static String getTodayMMdd() {
    return DateFormat('MMdd').format(DateTime.now());
  }

  /// iOS: functionForGetTodatDayMonthYear — returns today as "yyyy-MM-dd".
  static String getTodayYMD() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  /// iOS: functionForGetCurrentYear — returns current year as "yyyy".
  static String getCurrentYear() {
    return DateFormat('yyyy').format(DateTime.now());
  }

  // ═══════════════════════════════════════════════════════
  // Date formatting (functionForDateMonthYearProper)
  // ═══════════════════════════════════════════════════════

  /// Port of iOS functionForDateMonthYearProper.
  /// Parses a date string and reformats it.
  ///
  /// [fullDate]: the raw date string (e.g. "15-06-2020" or "15/06/2020")
  /// [separator]: the separator in the source ("-" or "/")
  /// [monthFormat]: "Digit" if month is numeric, "Alpha" if already text
  /// [outputFormat]: "ddmm", "ddmmyy", "mmddyy", "yymmdd"
  /// [outputSeparator]: separator for output (e.g. " " or "-")
  static String formatDateProper({
    required String? fullDate,
    String separator = '-',
    String monthFormat = 'Digit',
    String outputFormat = 'ddmm',
    String outputSeparator = ' ',
  }) {
    if (fullDate == null || fullDate.isEmpty) return '';

    final parts = fullDate.split(separator);
    if (parts.length < 3) return fullDate;

    String day = parts[0];
    String month = parts[1];
    String year = parts[2];

    // Convert numeric month to abbreviation if needed
    if (monthFormat == 'Digit') {
      month = _monthAbbreviations[month] ?? month;
    }

    // Build output based on format
    switch (outputFormat) {
      case 'ddmm':
        return '$day$outputSeparator$month';
      case 'ddmmyy':
        return '$day$outputSeparator$month$outputSeparator$year';
      case 'mmddyy':
        return '$month$outputSeparator$day$outputSeparator$year';
      case 'yymmdd':
        return '$year$outputSeparator$month$outputSeparator$day';
      default:
        return '$day$outputSeparator$month';
    }
  }

  // ═══════════════════════════════════════════════════════
  // Date comparison (functionForCompareDatewithTime)
  // ═══════════════════════════════════════════════════════

  /// Port of iOS functionForCompareDatewithTime.
  /// Compares two date strings and returns "Descending", "Same", or "Ascending".
  ///
  /// [first] and [second] are date strings in "yyyy-MM-dd hh:mm a" format.
  static String compareDateStrings(String? first, String? second) {
    if (first == null ||
        second == null ||
        first.length <= 2 ||
        second.length <= 2) {
      return '';
    }

    // Try parsing with the expected format
    final format = DateFormat('yyyy-MM-dd hh:mm a');
    DateTime? firstDate;
    DateTime? secondDate;

    try {
      firstDate = format.parse(first);
    } catch (_) {
      // Fallback: string comparison (matching iOS behavior)
      final cmp = first.compareTo(second);
      if (cmp > 0) return 'Descending';
      if (cmp == 0) return 'Same';
      return 'Ascending';
    }

    try {
      secondDate = format.parse(second);
    } catch (_) {
      return '';
    }

    if (firstDate.isAfter(secondDate)) return 'Descending';
    if (firstDate.isAtSameMomentAs(secondDate)) return 'Same';
    return 'Ascending';
  }

  // ═══════════════════════════════════════════════════════
  // Notification date helpers
  // ═══════════════════════════════════════════════════════

  /// Get notification date string matching iOS df.dateFormat="dd MMM yyyy hh:mm a".
  static String notificationDateString() {
    return DateFormat('dd MMM yyyy hh:mm a').format(DateTime.now());
  }

  /// Get expiry date (3 days from now) matching iOS notification expiry logic.
  /// iOS: Calendar.current.date + 3 days, format "dd/MM/yyyy"
  static String notificationExpiryString() {
    final expiry = DateTime.now().add(const Duration(days: 3));
    return DateFormat('dd/MM/yyyy').format(expiry);
  }

  // ═══════════════════════════════════════════════════════
  // Generic parse/format helpers
  // ═══════════════════════════════════════════════════════

  /// Safe date parse — returns null if parsing fails.
  static DateTime? tryParse(String? dateString, String format) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateFormat(format).parse(dateString);
    } catch (_) {
      return null;
    }
  }

  /// Safe date format — returns empty string on null input.
  static String safeFormat(DateTime? date, String format) {
    if (date == null) return '';
    try {
      return DateFormat(format).format(date);
    } catch (_) {
      return '';
    }
  }

  /// Check if a date string represents a valid date.
  static bool isValidDate(String? dateString, String format) {
    return tryParse(dateString, format) != null;
  }
}
