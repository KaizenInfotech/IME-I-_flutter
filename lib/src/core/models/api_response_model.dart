/// Generic API response wrapper matching iOS JSON response structure.
///
/// iOS API returns JSON with top-level keys:
/// - "status": String ("0" = success, "2" = session timeout)
/// - "message": String ("success" or error description)
/// - "data" or "list" or nested object: response payload
/// - "serverError": String (from ServiceManager on failure)
/// - "ErrorName": String (e.g. "Request time out.")
///
/// All fields nullable. No force unwraps.
class ApiResponseModel {
  final String? status;
  final String? message;
  final dynamic data;
  final String? error;
  final String? serverError;
  final String? errorName;

  ApiResponseModel({
    this.status,
    this.message,
    this.data,
    this.error,
    this.serverError,
    this.errorName,
  });

  /// iOS: status == "0" || message == "success"
  bool get isSuccess =>
      status == '0' || status == 'success' || message == 'success';

  /// iOS: status == "2" — session expired / timeout.
  bool get isSessionTimeout => status == '2';

  /// iOS: ServiceManager returns {"serverError": "Error"} on failure.
  bool get isServerError => serverError != null;

  /// Get the user-facing error message.
  String get errorMessage {
    if (serverError != null) return errorName ?? 'Server error';
    if (message != null && !isSuccess) return message!;
    if (error != null) return error!;
    return 'Unknown error';
  }

  /// Parse from raw JSON map.
  factory ApiResponseModel.fromJson(Map<String, dynamic> json) {
    return ApiResponseModel(
      status: _safeString(json['status']),
      message: _safeString(json['message']),
      data: json['data'] ?? json['list'] ?? json['ds'],
      error: _safeString(json['error']),
      serverError: _safeString(json['serverError']),
      errorName: _safeString(json['ErrorName']),
    );
  }

  /// Create a generic error response.
  factory ApiResponseModel.error(String message) {
    return ApiResponseModel(
      status: '-1',
      message: message,
      error: message,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data,
      'error': error,
      'serverError': serverError,
      'ErrorName': errorName,
    };
  }

  static String? _safeString(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }
}
