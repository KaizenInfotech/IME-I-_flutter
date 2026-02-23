# Phase 3: Core Network Layer (http Client + Interceptors)

## Priority: 3
## Depends On: Phase 2

---

## Command Prompt

```
I am migrating an iOS app to Flutter.

Read these iOS source files:
1. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/ServiceManager/ServiceManager.swift
2. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/ServiceManager/WebserviceClass.swift (read first 200 lines for the class setup, headers, base URL patterns)
3. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Connectivity.swift
4. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/AppDelegate/Reach.swift

Also read:
5. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/api_details.md (Section 3 for network setup reference)

Now create these files in /Users/ios2/Documents/Mani_mac_folder/touchbase_flutter/:

1. lib/src/core/network/api_client.dart
   - Singleton pattern matching iOS WebserviceClass singleton
   - Use the dart "http" package (package:http/http.dart)
   - Base URL from api_constants.dart: "https://api.imeiconnect.com/api/"
   - Default headers: Accept: application/json, Content-Type: application/json,
     Authorization: Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ== (exact same as iOS ServiceManager)
   - Timeout: 30s default, 120s for celebration APIs
   - Methods:
     a. post(String endpoint, {Map<String, dynamic>? body}) -> Future<http.Response>
        JSON-encoded body, matching iOS JSONEncoding.default
     b. postUrlEncoded(String endpoint, {Map<String, String>? body}) -> Future<http.Response>
        Form-URL-encoded body, matching iOS URLEncoding.default (used for login)
     c. uploadFile(String endpoint, {required Map<String, String> fields, required String filePath, required String fileFieldName}) -> Future<http.StreamedResponse>
        Multipart request matching iOS image upload pattern
     d. downloadFile(String url, String savePath, {void Function(int received, int total)? onProgress}) -> Future<String>
        File download with progress, matching iOS URLSessionDownloadDelegate
   - All methods must check connectivity before making request
   - All methods must handle errors gracefully, return null-safe responses
   - Log requests and responses in debug mode

2. lib/src/core/network/api_interceptor.dart
   - ApiRequestHelper class with static methods:
     a. getDefaultHeaders() -> Map<String, String> with auth header
        "Authorization": "Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==" (exact same as iOS)
     b. handleResponse(http.Response response) -> Map<String, dynamic>?
        Parse JSON, handle status codes, return null on failure
     c. handleError(dynamic error) -> String
        Return user-friendly error message
   - Handle 401 response for session expiry

3. lib/src/core/network/api_response.dart
   - Generic ApiResponse<T> wrapper class
   - Fields: bool? success, String? message, T? data, int? statusCode
   - Factory fromJson that takes a data converter function
   - Factory fromHttpResponse(http.Response response, T Function(Map<String, dynamic>)? converter)
   - All fields nullable, no force unwraps

4. lib/src/core/network/connectivity_service.dart
   - Singleton using connectivity_plus package
   - Future<bool> get isConnected
   - Stream<ConnectivityResult> get onConnectivityChanged
   - Match the exact reachability logic from iOS Reach.swift

STRICT RULES:
- Use "http" package (package:http/http.dart), NOT dio
- EXACT same auth header as iOS: "Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ=="
- EXACT same timeout values as iOS
- All fields nullable, no force unwraps
- User identity passed via body parameters (masterUID, grpID, profileId) NOT via headers - same as iOS
```

---

## iOS Source Files to Read
- `TouchBase/ServiceManager/ServiceManager.swift`
- `TouchBase/ServiceManager/WebserviceClass.swift` (first 200 lines)
- `TouchBase/Connectivity.swift`
- `AppDelegate/Reach.swift`
- `api_details.md` (Section 3)

## Expected Output Files
- `lib/src/core/network/api_client.dart`
- `lib/src/core/network/api_interceptor.dart`
- `lib/src/core/network/api_response.dart`
- `lib/src/core/network/connectivity_service.dart`
