import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import 'api_interceptor.dart';
import 'connectivity_service.dart';

/// Singleton API client matching iOS WebserviceClass.sharedInstance pattern.
/// Uses the dart "http" package (package:http/http.dart).
///
/// iOS patterns replicated:
/// - ServiceManager.httpMakeRequest: POST with JSONEncoding.default
/// - ServiceManager celebrations check: 120s timeout for /Celebrations/ URLs
/// - WebserviceClass.signinTapped: URLEncoding.default for login
/// - Auth header: "Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ=="
/// - User identity via body params (masterUID, grpID, profileId), NOT headers
class ApiClient {
  ApiClient._();

  static ApiClient? _instance;
  static ApiClient get instance => _instance ??= ApiClient._();

  late http.Client _client;

  /// Initialize the HTTP client. Call once at app startup.
  void init() {
    _client = http.Client();
  }

  /// Dispose the HTTP client.
  void dispose() {
    _client.close();
  }

  // ─── GET ─────────────────────────────────────────────
  // Matches iOS: URLSession GET requests (e.g. Member/GetMemberDetails).
  // Used where iOS sends GET with query parameters.
  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? queryParams,
    Map<String, String>? additionalHeaders,
    Duration? timeout,
  }) async {
    final connected = await ConnectivityService.instance.isConnected;
    if (!connected) {
      return http.Response(
        '{"message":"No internet connection"}',
        503,
      );
    }

    var url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    if (queryParams != null && queryParams.isNotEmpty) {
      url = url.replace(queryParameters: queryParams);
    }

    final requestTimeout = timeout ?? ApiConstants.defaultTimeout;

    ApiRequestHelper.logRequest('GET', url.toString());

    try {
      final headers = ApiRequestHelper.getDefaultHeaders();
      if (additionalHeaders != null) {
        headers.addAll(additionalHeaders);
      }
      final response = await _client
          .get(url, headers: headers)
          .timeout(requestTimeout);

      ApiRequestHelper.logResponse(response);
      return response;
    } on TimeoutException {
      debugPrint('Request timed out: $url');
      return http.Response(
        '{"serverError":"Error","ErrorName":"Request time out."}',
        408,
      );
    } on SocketException {
      debugPrint('Socket exception: $url');
      return http.Response(
        '{"serverError":"Error"}',
        503,
      );
    } catch (e) {
      debugPrint('Request error: $e');
      return http.Response(
        '{"serverError":"Error"}',
        500,
      );
    }
  }

  // ─── POST (JSON-encoded body) ─────────────────────────
  // Matches iOS: Alamofire.request(url, .post, params, JSONEncoding.default)
  // Used for nearly ALL API calls except login.
  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Duration? timeout,
  }) async {
    // Check connectivity (matches iOS Reachability check)
    final connected = await ConnectivityService.instance.isConnected;
    if (!connected) {
      return http.Response(
        '{"message":"No internet connection"}',
        503,
      );
    }

    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');

    // iOS ServiceManager uses 120s timeout for Celebrations URLs
    final requestTimeout = timeout ??
        (endpoint.contains('Celebrations/')
            ? ApiConstants.celebrationTimeout
            : ApiConstants.defaultTimeout);

    ApiRequestHelper.logRequest('POST', url.toString(), body: body);

    try {
      final response = await _client
          .post(
            url,
            headers: ApiRequestHelper.getDefaultHeaders(),
            body: body != null ? json.encode(body) : null,
          )
          .timeout(requestTimeout);

      ApiRequestHelper.logResponse(response);
      return response;
    } on TimeoutException {
      debugPrint('Request timed out: $url');
      return http.Response(
        '{"serverError":"Error","ErrorName":"Request time out."}',
        408,
      );
    } on SocketException {
      debugPrint('Socket exception: $url');
      return http.Response(
        '{"serverError":"Error"}',
        503,
      );
    } catch (e) {
      debugPrint('Request error: $e');
      return http.Response(
        '{"serverError":"Error"}',
        500,
      );
    }
  }

  // ─── POST URL-ENCODED ─────────────────────────────────
  // Matches iOS: Alamofire.request(url, .post, params, URLEncoding.default)
  // Used specifically for login (WebserviceClass.signinTapped).
  Future<http.Response> postUrlEncoded(
    String endpoint, {
    Map<String, String>? body,
  }) async {
    final connected = await ConnectivityService.instance.isConnected;
    if (!connected) {
      return http.Response(
        '{"message":"No internet connection"}',
        503,
      );
    }

    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');

    ApiRequestHelper.logRequest('POST (URL-encoded)', url.toString(),
        body: body);

    try {
      final response = await _client
          .post(
            url,
            headers: ApiRequestHelper.getUrlEncodedHeaders(),
            body: body,
          )
          .timeout(ApiConstants.defaultTimeout);

      ApiRequestHelper.logResponse(response);
      return response;
    } on TimeoutException {
      debugPrint('Request timed out: $url');
      return http.Response(
        '{"serverError":"Error","ErrorName":"Request time out."}',
        408,
      );
    } on SocketException {
      debugPrint('Socket exception: $url');
      return http.Response(
        '{"serverError":"Error"}',
        503,
      );
    } catch (e) {
      debugPrint('Request error: $e');
      return http.Response(
        '{"serverError":"Error"}',
        500,
      );
    }
  }

  // ─── MULTIPART FILE UPLOAD ────────────────────────────
  // Matches iOS ServiceManager.httpMakeRequestIMNAGE / Alamofire multipart upload.
  // Used for image uploads (UploadImage?module=announcement, profile photos, etc.)
  Future<http.StreamedResponse?> uploadFile(
    String endpoint, {
    required Map<String, String> fields,
    required String filePath,
    required String fileFieldName,
  }) async {
    final connected = await ConnectivityService.instance.isConnected;
    if (!connected) {
      debugPrint('No internet connection for upload');
      return null;
    }

    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');

    ApiRequestHelper.logRequest('MULTIPART', url.toString(), body: fields);

    try {
      final request = http.MultipartRequest('POST', url);

      // Add auth headers
      request.headers.addAll(ApiRequestHelper.getDefaultHeaders());
      request.headers.remove('Content-Type'); // Let multipart set its own

      // Add form fields
      request.fields.addAll(fields);

      // Add file
      final file = await http.MultipartFile.fromPath(
        fileFieldName,
        filePath,
      );
      request.files.add(file);

      final response = await request.send().timeout(ApiConstants.celebrationTimeout);

      if (kDebugMode) {
        debugPrint('Upload response status: ${response.statusCode}');
      }

      return response;
    } on TimeoutException {
      debugPrint('Upload timed out: $url');
      return null;
    } on SocketException {
      debugPrint('Socket exception during upload: $url');
      return null;
    } catch (e) {
      debugPrint('Upload error: $e');
      return null;
    }
  }

  // ─── FILE DOWNLOAD WITH PROGRESS ──────────────────────
  // Matches iOS URLSessionDownloadDelegate pattern for file downloads.
  Future<String?> downloadFile(
    String url,
    String savePath, {
    void Function(int received, int total)? onProgress,
  }) async {
    final connected = await ConnectivityService.instance.isConnected;
    if (!connected) {
      debugPrint('No internet connection for download');
      return null;
    }

    ApiRequestHelper.logRequest('DOWNLOAD', url);

    try {
      final request = http.Request('GET', Uri.parse(url));
      request.headers.addAll(ApiRequestHelper.getDefaultHeaders());

      final response = await _client.send(request).timeout(
            ApiConstants.celebrationTimeout,
          );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint('Download failed with status: ${response.statusCode}');
        return null;
      }

      final totalBytes = response.contentLength ?? -1;
      int receivedBytes = 0;
      final bytes = <int>[];

      await for (final chunk in response.stream) {
        bytes.addAll(chunk);
        receivedBytes += chunk.length;
        onProgress?.call(receivedBytes, totalBytes);
      }

      final file = File(savePath);
      await file.writeAsBytes(bytes);

      if (kDebugMode) {
        debugPrint('Download complete: $savePath ($receivedBytes bytes)');
      }

      return savePath;
    } on TimeoutException {
      debugPrint('Download timed out: $url');
      return null;
    } on SocketException {
      debugPrint('Socket exception during download: $url');
      return null;
    } catch (e) {
      debugPrint('Download error: $e');
      return null;
    }
  }
}
