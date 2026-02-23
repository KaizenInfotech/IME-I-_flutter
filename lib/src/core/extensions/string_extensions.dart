/// Port of iOS CommonExtension.swift String extensions.
/// Dart extension on String? for null-safe string utilities.
extension NullableStringExtension on String? {
  /// Check if string is null or empty.
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Check if string is not null and not empty.
  bool get isNotNullOrEmpty => this != null && this!.isNotEmpty;

  /// Return trimmed string or empty string if null.
  String get orEmpty => this?.trim() ?? '';

  /// Return trimmed string or null if empty after trim.
  String? get trimmedOrNull {
    final trimmed = this?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }
}

/// Port of iOS String.isEmail and other String utilities.
extension StringExtension on String {
  /// iOS: String.isEmail — exact same regex from CommonExtension.swift
  bool get isEmail {
    final emailRegEx =
        RegExp(r'^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,20}$');
    return emailRegEx.hasMatch(this);
  }

  /// Check if string contains only digits.
  /// Port of iOS functionForTextFieldAcceptOnlyDigit
  bool get isDigitsOnly {
    return RegExp(r'^[0-9]+$').hasMatch(this);
  }

  /// Phone number validation (xxx-xxx-xxxx format).
  /// Port of iOS commonClassFunction.validate
  bool get isPhoneFormatted {
    final phoneRegex = RegExp(r'^\d{3}-\d{3}-\d{4}$');
    return phoneRegex.hasMatch(this);
  }

  /// Basic phone number validation (10+ digits).
  bool get isValidPhone {
    final digits = replaceAll(RegExp(r'[^0-9]'), '');
    return digits.length >= 10;
  }

  /// URL validation.
  bool get isValidUrl {
    return Uri.tryParse(this)?.hasAbsolutePath == true;
  }

  /// Remove single quotes (matching iOS replacingOccurrences of "'" with "").
  String get removeSingleQuotes => replaceAll("'", '');

  /// Capitalize first letter.
  String get capitalizeFirst {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Get initials from a name string (e.g. "John Doe" -> "JD").
  String get initials {
    final parts = trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '';
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
