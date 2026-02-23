import 'dart:convert';
import 'package:http/http.dart' as http;

/// Generic API response wrapper.
/// All fields nullable, no force unwraps.
/// Matches iOS response pattern where JSON has top-level
/// "status"/"message" fields with nested data.
class ApiResponse<T> {
  final bool? success;
  final String? message;
  final T? data;
  final int? statusCode;

  ApiResponse({
    this.success,
    this.message,
    this.data,
    this.statusCode,
  });

  /// Factory from raw JSON map with an optional data converter.
  /// Matches iOS pattern: dictResponseData.valueForKey("Result")
  factory ApiResponse.fromJson(
    Map<String, dynamic>? json, {
    T Function(Map<String, dynamic>)? converter,
  }) {
    if (json == null) {
      return ApiResponse(success: false);
    }

    // iOS uses "message" key for status text, "status" for code
    final message = json['message'] as String?;
    final status = json['status'];
    final isSuccess = message?.toLowerCase() == 'success' ||
        status == '0' ||
        status == 0;

    T? data;
    if (converter != null && json['data'] is Map<String, dynamic>) {
      data = converter(json['data'] as Map<String, dynamic>);
    } else if (json['data'] is T) {
      data = json['data'] as T?;
    }

    return ApiResponse(
      success: isSuccess,
      message: message,
      data: data,
      statusCode: int.tryParse(status?.toString() ?? ''),
    );
  }

  /// Factory from http.Response with an optional data converter.
  /// Parses HTTP response body as JSON and wraps in ApiResponse.
  factory ApiResponse.fromHttpResponse(
    http.Response response, {
    T Function(Map<String, dynamic>)? converter,
  }) {
    try {
      if (response.body.isEmpty) {
        return ApiResponse(
          success: false,
          message: 'Empty response',
          statusCode: response.statusCode,
        );
      }

      final decoded = json.decode(response.body);
      if (decoded is Map<String, dynamic>) {
        final apiResponse = ApiResponse<T>.fromJson(
          decoded,
          converter: converter,
        );
        return ApiResponse(
          success: apiResponse.success,
          message: apiResponse.message,
          data: apiResponse.data,
          statusCode: response.statusCode,
        );
      }

      return ApiResponse(
        success: response.statusCode >= 200 && response.statusCode < 300,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Failed to parse response',
        statusCode: response.statusCode,
      );
    }
  }

  /// Convenience factory for error states.
  factory ApiResponse.error(String errorMessage) {
    return ApiResponse(
      success: false,
      message: errorMessage,
    );
  }
}
