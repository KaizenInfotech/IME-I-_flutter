/// Abstract base class for all feature models.
/// Provides safe type casting helpers to prevent force unwrap crashes
/// when the API returns unexpected types.
///
/// All fields in subclasses should be nullable.
abstract class BaseModel {
  /// Subclasses must implement fromJson.
  /// Usage: MyModel.fromJson(json)
  Map<String, dynamic> toJson();

  // ═══════════════════════════════════════════════════════
  // SAFE TYPE CASTING HELPERS
  // ═══════════════════════════════════════════════════════

  /// Safely cast to String?.
  /// Handles: null, String, int, double, bool.
  static String? safeString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  /// Safely cast to int?.
  /// Handles: null, int, String (parseable), double.
  static int? safeInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Safely cast to double?.
  /// Handles: null, double, int, String (parseable).
  static double? safeDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Safely cast to bool?.
  /// Handles: null, bool, String ("true"/"false"/"1"/"0"), int (1/0).
  static bool? safeBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true' || lower == '1' || lower == 'yes') return true;
      if (lower == 'false' || lower == '0' || lower == 'no') return false;
    }
    return null;
  }

  /// Safely cast to a typed List using a fromJson factory.
  /// Handles: null, List of maps.
  static List<T>? safeList<T>(
    dynamic value,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (value == null) return null;
    if (value is! List) return null;
    try {
      return value
          .whereType<Map<String, dynamic>>()
          .map((e) => fromJson(e))
          .toList();
    } catch (_) {
      return null;
    }
  }

  /// Safely cast to a string list.
  static List<String>? safeStringList(dynamic value) {
    if (value == null) return null;
    if (value is! List) return null;
    try {
      return value.map((e) => e.toString()).toList();
    } catch (_) {
      return null;
    }
  }

  /// Safely cast a nested Map to a model using fromJson.
  static T? safeModel<T>(
    dynamic value,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (value == null) return null;
    if (value is! Map<String, dynamic>) return null;
    try {
      return fromJson(value);
    } catch (_) {
      return null;
    }
  }

  /// Safely parse a DateTime from String.
  static DateTime? safeDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
