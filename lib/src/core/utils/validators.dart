/// Port of iOS ValidationExtension.swift + validation methods from CommonExtension.swift.
/// All validators return String? — null means valid, String means error message.
class Validators {
  Validators._();

  /// Required field validator.
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Email validator — uses exact same regex as iOS String.isEmail.
  /// iOS regex: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,20}"
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegEx =
        RegExp(r'^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,20}$');
    if (!emailRegEx.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Phone number validator — matches iOS commonClassFunction.validate.
  /// iOS regex: "^\\d{3}-\\d{3}-\\d{4}$"
  static String? phoneFormatted(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^\d{3}-\d{3}-\d{4}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Please enter a valid phone number (xxx-xxx-xxxx)';
    }
    return null;
  }

  /// Basic phone validator (10+ digits).
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 10) {
      return 'Phone number must be at least 10 digits';
    }
    return null;
  }

  /// Password validator — port of iOS commonClassFunction.isPwdLenth.
  /// iOS checks: password.characters.count <= 7
  static String? password(String? value, {int minLength = 8}) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    return null;
  }

  /// Confirm password — port of iOS commonClassFunction.isPasswordSame.
  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Digits only — port of iOS functionForTextFieldAcceptOnlyDigit.
  /// iOS checks: rangeOfCharacter(from: NSCharacterSet.letters) == nil
  static String? digitsOnly(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
      return '$fieldName must contain only digits';
    }
    return null;
  }

  /// Minimum length validator.
  static String? minLength(String? value, int min,
      [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    if (value.trim().length < min) {
      return '$fieldName must be at least $min characters';
    }
    return null;
  }

  /// Maximum length validator.
  static String? maxLength(String? value, int max,
      [String fieldName = 'This field']) {
    if (value != null && value.trim().length > max) {
      return '$fieldName must not exceed $max characters';
    }
    return null;
  }

  /// URL validator.
  static String? url(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'URL is required';
    }
    final uri = Uri.tryParse(value.trim());
    if (uri == null || !uri.hasAbsolutePath) {
      return 'Please enter a valid URL';
    }
    return null;
  }

  /// Numeric value validator.
  static String? numeric(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    if (double.tryParse(value.trim()) == null) {
      return '$fieldName must be a valid number';
    }
    return null;
  }
}
