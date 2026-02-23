# IMEI-iConnect: API Details for Flutter Migration

## Table of Contents

1. [API Architecture Overview](#1-api-architecture-overview)
2. [Base URL Configuration](#2-base-url-configuration)
3. [ApiClient Setup](#3-apiclient-setup)
4. [Authentication Flow](#4-authentication-flow)
5. [API Endpoints - Complete Reference](#5-api-endpoints---complete-reference)
6. [Dart Models (json_serializable, all nullable)](#6-dart-models-json_serializable-all-nullable)
7. [Provider Integration Examples](#7-provider-integration-examples)
8. [Error Handling Strategy](#8-error-handling-strategy)
9. [File Upload Pattern](#9-file-upload-pattern)
10. [Offline & Caching Strategy](#10-offline--caching-strategy)

---

## 1. API Architecture Overview

### Original iOS Networking Stack

```
┌─────────────────────────────────────────────┐
│ ViewControllers (70+ screens)               │
│ ↕ webServiceDelegate protocol (70+ methods) │
├─────────────────────────────────────────────┤
│ WebserviceClass.swift (Singleton, 3900+ lines)│
│ - 100+ API methods                          │
│ - Alamofire.request(url, .post, params)     │
│ - SVProgressHUD for loading                 │
├─────────────────────────────────────────────┤
│ ServiceManager.swift (Secondary manager)    │
│ - Generic POST wrapper                      │
│ - 120s timeout for Celebrations API         │
│ - Image upload handling                     │
├─────────────────────────────────────────────┤
│ Alamofire (URLEncoding / JSONEncoding)       │
└─────────────────────────────────────────────┘
```

### Flutter Replacement Architecture

```
┌─────────────────────────────────────────────┐
│ Screens (Consumer<Provider> widgets)        │
│ ↕ Provider.notifyListeners()                │
├─────────────────────────────────────────────┤
│ Feature Providers (ChangeNotifier classes)   │
│ - AuthProvider, DashboardProvider, etc.      │
│ - Each provider calls ApiClient             │
├─────────────────────────────────────────────┤
│ ApiClient (Singleton)                       │
│ - post(), postUrlEncoded()                  │
│ - uploadFile(), downloadFile()              │
│ - Basic Auth header, 30s default timeout    │
├─────────────────────────────────────────────┤
│ package:http                                │
└─────────────────────────────────────────────┘
```

### Key Patterns Observed in iOS Code

1. **HTTP Method:** Nearly ALL requests use **POST** (even data fetches)
2. **Encoding:** Mix of `URLEncoding.default` and `JSONEncoding.default`
3. **Headers:** Most requests send `headers: nil` (no explicit auth headers)
4. **Auth:** Uses a hardcoded Basic Auth header in ServiceManager: `"Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ=="` (Base64 of "Aladdin:open sesame")
5. **Session:** User identity passed via body parameters (`masterUID`, `grpID`, `profileId`) - NOT via headers
6. **Response:** JSON with top-level `status`/`message` fields and nested data

---

## 2. Base URL Configuration

### iOS Original (from APIConstant.swift)

```swift
// Production (currently active - hardcoded in WebserviceClass)
"https://api.imeiconnect.com/api/"

// Legacy URLs (commented out):
// "https://apitest.jitoworld.org/V1/api/"
// "http://rowtestapi.rosteronwheels.com/V4/api/"
// "http://apitest.rotary-india.org/V4/api/"

// Static HTML pages:
var baseUrlTermsnCondition = "http://touchbase.in/mobile/term-n-conditions.html"
var baseUrlSubscribes = "http://touchbase.in/mobile/subscribes.html"
```

### Flutter Dart Configuration

```dart
// lib/src/core/constants/api_constants.dart

class ApiConstants {
  ApiConstants._();

  /// Production base URL
  static const String baseUrl = 'https://api.imeiconnect.com/api/';

  /// Static web pages
  static const String termsAndConditionsUrl =
      'http://touchbase.in/mobile/term-n-conditions.html';
  static const String subscribesUrl =
      'http://touchbase.in/mobile/subscribes.html';

  /// Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration celebrationTimeout = Duration(seconds: 120);

  // ─── LOGIN ───────────────────────────────────────────
  static const String loginUserLogin = 'Login/UserLogin';
  static const String loginPostOtp = 'Login/PostOTP';
  static const String loginGetWelcomeScreen = 'Login/GetWelcomeScreen';
  static const String loginGetMemberDetails = 'Login/GetMemberDetails';
  static const String loginRegistration = 'Login/Registration';

  // ─── GROUP ───────────────────────────────────────────
  static const String groupGetAllCountriesAndCategories =
      'Group/GetAllCountriesAndCategories';
  static const String groupGetAllGroupsList = 'Group/GetAllGroupsList';
  static const String groupCreateGroup = 'Group/CreateGroup';
  static const String groupCreateSubGroup = 'Group/CreateSubGroup';
  static const String groupGetGroupDetail = 'Group/GetGroupDetail';
  static const String groupGetSubGroupList = 'Group/GetSubGroupList';
  static const String groupGetSubGroupDetail = 'Group/GetSubGroupDetail';
  static const String groupAddMemberToGroup = 'Group/AddMemberToGroup';
  static const String groupAddMultipleMemberToGroup =
      'Group/AddMultipleMemberToGroup';
  static const String groupGlobalSearchGroup = 'Group/GlobalSearchGroup';
  static const String groupDeleteByModuleName = 'Group/DeleteByModuleName';
  static const String groupDeleteImage = 'Group/DeleteImage';
  static const String groupUpdateModuleDashboard =
      'Group/UpdateModuleDashboard';
  static const String groupRemoveGroupCategory = 'Group/RemoveGroupCategory';
  static const String groupUpdateMemberGroupCategory =
      'Group/UpdateMemberGroupCategory';
  static const String groupGetGroupModulesList = 'Group/GetGroupModulesList';
  static const String groupGetNotificationCount = 'Group/GetNotificationCount';
  static const String groupGetEmail = 'Group/GetEmail';
  static const String groupGetNewDashboard = 'Group/GetNewDashboard';
  static const String groupGetRotaryLibraryData = 'Group/GetRotaryLibraryData';
  static const String groupGetAdminSubModules = 'Group/getAdminSubModules';
  static const String groupGetEntityInfo = 'Group/GetEntityInfo';
  static const String groupGetAllGroupListSync = 'Group/GetAllGroupListSync';
  static const String groupGetClubDetails = 'Group/GetClubDetails';
  static const String groupGetClubHistory = 'Group/GetClubHistory';
  static const String groupFeedback = 'Group/Feedback';
  static const String groupGetZoneList = 'Group/getZonelist';
  static const String groupGetMobilePupup = 'Group/getMobilePupup';
  static const String groupUpdateMobilePupupFlag =
      'Group/UpdateMobilePupupflag';

  // ─── MEMBER ──────────────────────────────────────────
  static const String memberUpdateProfile = 'Member/UpdateProfile';
  static const String memberGetDirectoryList = 'Member/GetDirectoryList';
  static const String memberGetMember = 'Member/GetMember';
  static const String memberGetMemberListSync = 'Member/GetMemberListSync';
  static const String memberUpdateProfileDetails =
      'member/UpdateProfileDetails';
  static const String memberUpdateAddressDetails =
      'Member/UpdateAddressDetails';
  static const String memberUpdateFamilyDetails = 'Member/UpdateFamilyDetails';
  static const String memberGetUpdatedProfileDetails =
      'Member/GetUpdatedmemberProfileDetails';
  static const String memberUploadProfilePhoto = 'Member/UploadProfilePhoto';
  static const String memberGetBodList = 'Member/GetBODList';

  // ─── EVENT ───────────────────────────────────────────
  static const String eventGetEventDetails = 'Event/GetEventDetails';
  static const String eventGetEventList = 'Event/GetEventList';
  static const String eventAddEventNew = 'Event/AddEvent_New';
  static const String eventAnsweringEvent = 'Event/AnsweringEvent';
  static const String eventGetSmsCountDetails = 'Event/Getsmscountdetails';

  // ─── ANNOUNCEMENT ────────────────────────────────────
  static const String announcementGetDetails =
      'Announcement/GetAnnouncementDetails';
  static const String announcementAdd = 'Announcement/AddAnnouncement';

  // ─── DOCUMENT ────────────────────────────────────────
  static const String documentAdd = 'DocumentSafe/AddDocument';
  static const String documentGetList = 'DocumentSafe/GetDocumentList';
  static const String documentUpdateIsRead =
      'DocumentSafe/UpdateDocumentIsRead';

  // ─── E-BULLETIN ──────────────────────────────────────
  static const String ebulletinAdd = 'Ebulletin/AddEbulletin';
  static const String ebulletinGetYearWiseList =
      'Ebulletin/GetYearWiseEbulletinList';

  // ─── GALLERY ─────────────────────────────────────────
  static const String galleryGetAlbumsList = 'Gallery/GetAlbumsList';
  static const String galleryGetAlbumPhotoList = 'Gallery/GetAlbumPhotoList';
  static const String galleryAddUpdateAlbum = 'Gallery/AddUpdateAlbum';
  static const String galleryDeleteAlbumPhoto = 'Gallery/DeleteAlbumPhoto';
  static const String galleryGetAlbumDetails = 'Gallery/GetAlbumDetails';

  // ─── ATTENDANCE ──────────────────────────────────────
  static const String attendanceGetList = 'Attendance/GetAttendanceList';

  // ─── CELEBRATIONS ────────────────────────────────────
  static const String celebrationGetMonthEventList =
      'Celebrations/GetMonthEventList';
  static const String celebrationGetEventMinDetails =
      'Celebrations/GetEventMinDetails';
  static const String celebrationGetMonthEventListTypeWise =
      'Celebrations/GetMonthEventListTypeWise';
  static const String celebrationGetMonthEventListDetails =
      'Celebrations/GetMonthEventListDetails';
  static const String celebrationGetTodaysBirthday =
      'Celebrations/GetTodaysBirthday';

  // ─── SERVICE DIRECTORY ───────────────────────────────
  static const String serviceDirectoryGetCategories =
      'ServiceDirectory/GetServiceCategoriesData';
  static const String serviceDirectoryGetList =
      'ServiceDirectory/GetServiceDirectoryCategories';

  // ─── SETTINGS ────────────────────────────────────────
  static const String settingGetTouchbaseSetting =
      'setting/GetTouchbaseSetting';
  static const String settingTouchbaseSetting = 'setting/TouchbaseSetting';
  static const String settingGroupSetting = 'Setting/GroupSetting';
  static const String settingGetGroupSetting = 'Setting/GetGroupSetting';

  // ─── FIND CLUB ───────────────────────────────────────
  static const String findClubGetClubList = 'FindClub/GetClubList';
  static const String findClubGetClubDetails = 'FindClub/GetClubDetails';
  static const String findClubGetClubsNearMe = 'FindClub/GetClubsNearMe';
  static const String findClubGetPublicAlbumsList =
      'FindClub/GetPublicAlbumsList';
  static const String findClubGetPublicEventsList =
      'FindClub/GetPublicEventsList';
  static const String findClubGetPublicNewsletterList =
      'FindClub/GetPublicNewsletterList';
  static const String findClubGetClubMembers = 'FindClub/GetClubMembers';

  // ─── FIND ROTARIAN ──────────────────────────────────
  static const String findRotarianGetZoneChapterList =
      'FindRotarian/GetZonechapterlist';
  static const String findRotarianGetList = 'FindRotarian/GetRotarianList';
  static const String findRotarianGetDetails =
      'FindRotarian/GetRotarianDetails';
  static const String findRotarianGetDetailsAlt =
      'FindRotarian/GetrotarianDetails';

  // ─── DISTRICT ────────────────────────────────────────
  static const String districtGetMemberListSync =
      'District/GetDistrictMemberListSync';
  static const String districtGetClubs = 'District/GetClubs';
  static const String districtGetCommittee = 'District/GetDistrictCommittee';

  // ─── OFFLINE DATA ───────────────────────────────────
  static const String offlineGetServiceDirectoryListSync =
      'OfflineData/GetServiceDirectoryListSync';

  // ─── PAST PRESIDENTS ────────────────────────────────
  static const String pastPresidentsGetList =
      'PastPresidents/getPastPresidentsList';

  // ─── WEB LINK ───────────────────────────────────────
  static const String webLinkGetList = 'WebLink/GetWebLinksList';

  // ─── JITO ───────────────────────────────────────────
  static const String jitoGetRotaryLibraryData = 'Jito/GetRotaryLibraryData';

  // ─── UPLOAD ─────────────────────────────────────────
  static const String uploadImage = 'upload/UploadImage';
}
```

---

## 3. ApiClient Setup

### iOS Original (ServiceManager.swift headers)

```swift
let headers = [
    "Authorization": "Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==",
    "Accept": "application/json"
]

// Most requests use:
Alamofire.request(urlStr, method: .post, parameters: parameters as? [String: AnyObject],
                 encoding: JSONEncoding.default, headers: nil)

// Login specifically uses URLEncoding:
Alamofire.request(url, method: .post, parameters: params,
                 encoding: URLEncoding.default, headers: nil)
```

### Flutter Dio Client

```dart
// lib/src/core/network/dio_client.dart

import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../storage/local_storage.dart';
import 'connectivity_service.dart';

class DioClient {
  DioClient._();

  static DioClient? _instance;
  static DioClient get instance => _instance ??= DioClient._();

  late final Dio _dio;

  Dio get dio => _dio;

  void init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      AuthInterceptor(),
      ConnectivityInterceptor(),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    ]);
  }

  /// POST request (primary method - mirrors iOS Alamofire pattern)
  Future<Response<dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    Duration? timeout,
  }) async {
    final opts = options ?? Options();
    if (timeout != null) {
      opts.receiveTimeout = timeout;
    }
    return _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: opts,
    );
  }

  /// POST with URL encoding (for login endpoints)
  Future<Response<dynamic>> postUrlEncoded(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    return _dio.post(
      path,
      data: data,
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
  }

  /// Multipart upload (for image/document uploads)
  Future<Response<dynamic>> uploadFile(
    String path, {
    required FormData formData,
    void Function(int, int)? onSendProgress,
  }) async {
    return _dio.post(
      path,
      data: formData,
      onSendProgress: onSendProgress,
      options: Options(
        contentType: 'multipart/form-data',
      ),
    );
  }

  /// Download file with progress
  Future<Response<dynamic>> download(
    String url,
    String savePath, {
    void Function(int, int)? onReceiveProgress,
  }) async {
    return _dio.download(
      url,
      savePath,
      onReceiveProgress: onReceiveProgress,
    );
  }
}
```

### Auth Interceptor

```dart
// lib/src/core/network/api_interceptor.dart

import 'package:dio/dio.dart';
import '../storage/local_storage.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    // iOS original uses Basic Auth in ServiceManager (not always sent):
    // "Authorization": "Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ=="
    //
    // Most iOS requests send headers: nil, relying on body params for identity.
    // Replicate the same pattern here: add Basic Auth if needed.
    options.headers['Authorization'] = 'Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==';

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Handle session expiry - navigate to login
    }
    handler.next(err);
  }
}

class ConnectivityInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final isConnected = await ConnectivityService.instance.isConnected;
    if (!isConnected) {
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: 'No internet connection',
        ),
      );
      return;
    }
    handler.next(options);
  }
}
```

### Connectivity Service

```dart
// lib/src/core/network/connectivity_service.dart

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  ConnectivityService._();

  static ConnectivityService? _instance;
  static ConnectivityService get instance =>
      _instance ??= ConnectivityService._();

  final Connectivity _connectivity = Connectivity();

  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Stream<ConnectivityResult> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;
}
```

---

## 4. Authentication Flow

### iOS Original Flow (WebserviceClass.swift)

**Step 1 - Login Request:**
```swift
// WebserviceClass.signinTapped() - Line 153
func signinTapped(_ mobileNumber: String, countryCode: String, loginType: String) {
    let params = [
        "mobileNo": mobileNumber,
        "deviceToken": defaults.value(forKey: "DeviceToken") as? String ?? "",
        "countryCode": countryCode,
        "loginType": loginType
    ]
    let url = "https://api.imeiconnect.com/api/Login/UserLogin"
    Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil)
}
```

**Step 2 - OTP Verification:**
```swift
// WebserviceClass.OTPverify() - Line 317
func OTPverify(_ mobileNumber: String, deviceTokenStr: String, countryCode: String, loginType: String) {
    let params = [
        "mobileNo": mobileNumber,
        "deviceToken": defaults.value(forKey: "DeviceToken") as? String ?? "",
        "countryCode": countryCode,
        "deviceName": "iOS",
        "imeiNo": UIDevice.current.identifierForVendor!.uuidString,
        "versionNo": verSion,
        "loginType": loginType
    ]
    let url = baseUrl + "Login/PostOTP"
    Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil)
}
```

**Step 3 - Post-OTP: Store credentials in UserDefaults:**
```swift
defaults.set(masterUID, forKey: "masterUID")
defaults.set(grpid0, forKey: "grpId0")
defaults.set(grpid1, forKey: "grpId")
defaults.set(firstName, forKey: "firstName")
defaults.set(memberId, forKey: "memberIdss")
```

**Step 4 - Get Welcome Groups:**
```swift
// WebserviceClass.getAllGroupsWelcome() - Line 488
let params = [
    "memberUID": memberUID,
    "mobileno": mobileno,
    "loginType": loginType
]
let url = baseUrl + "Login/GetWelcomeScreen"
```

### Flutter Auth Implementation

```dart
// lib/src/features/auth/providers/auth_provider.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/storage/local_storage.dart';
import '../models/login_result.dart';
import '../models/login_table.dart';

class AuthProvider extends ChangeNotifier {
  LoginResult? _loginResult;
  LoginTable? _userSession;
  bool _isLoading = false;
  String? _error;

  LoginResult? get loginResult => _loginResult;
  LoginTable? get userSession => _userSession;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _userSession?.masterUID != null;

  /// Step 1: Request OTP via mobile number
  /// Maps to: WebserviceClass.signinTapped()
  Future<void> login({
    required String? mobileNumber,
    required String? countryCode,
    required String? loginType,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final deviceToken = await _getDeviceToken();

      final response = await DioClient.instance.postUrlEncoded(
        ApiConstants.loginUserLogin,
        data: {
          'mobileNo': mobileNumber ?? '',
          'deviceToken': deviceToken ?? '',
          'countryCode': countryCode ?? '',
          'loginType': loginType ?? '',
        },
      );

      final data = response.data as Map<String, dynamic>?;
      if (data != null) {
        _loginResult = LoginResult.fromJson(data);
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Step 2: Verify OTP
  /// Maps to: WebserviceClass.OTPverify()
  Future<void> verifyOtp({
    required String? mobileNumber,
    required String? countryCode,
    required String? loginType,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final deviceToken = await _getDeviceToken();
      final deviceId = await _getDeviceId();
      final versionNo = await _getVersionNumber();

      final response = await DioClient.instance.postUrlEncoded(
        ApiConstants.loginPostOtp,
        data: {
          'mobileNo': mobileNumber ?? '',
          'deviceToken': deviceToken ?? '',
          'countryCode': countryCode ?? '',
          'deviceName': Platform.isIOS ? 'iOS' : 'Android',
          'imeiNo': deviceId ?? '',
          'versionNo': versionNo ?? '',
          'loginType': loginType ?? '',
        },
      );

      final data = response.data as Map<String, dynamic>?;
      if (data != null) {
        _loginResult = LoginResult.fromJson(data);

        // Extract and store session data (matches iOS UserDefaults storage)
        final table = _loginResult?.loginResult?.ds?.table?.firstOrNull;
        if (table != null) {
          _userSession = table;
          await _storeSessionData(table);
        }
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Step 3: Get welcome screen groups
  /// Maps to: WebserviceClass.getAllGroupsWelcome()
  Future<void> getWelcomeGroups({
    required String? memberUID,
    required String? mobileNo,
    required String? loginType,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await DioClient.instance.post(
        ApiConstants.loginGetWelcomeScreen,
        data: {
          'memberUID': memberUID ?? '',
          'mobileno': mobileNo ?? '',
          'loginType': loginType ?? '',
        },
      );
      // Parse WelcomeResult from response
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Step 4: Get member details
  /// Maps to: WebserviceClass.MemberDetail()
  Future<void> getMemberDetails({required String? memberUUID}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await DioClient.instance.post(
        ApiConstants.loginGetMemberDetails,
        data: {
          'memberUUID': memberUUID ?? '',
        },
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logout: Clear all session data
  Future<void> logout() async {
    await LocalStorage.instance.clearAll();
    _loginResult = null;
    _userSession = null;
    notifyListeners();
  }

  /// Restore session from local storage on app start
  Future<void> restoreSession() async {
    final masterUID = await LocalStorage.instance.getString('master_uid');
    if (masterUID != null) {
      _userSession = LoginTable(
        masterUID: int.tryParse(masterUID),
        grpid0: int.tryParse(
            await LocalStorage.instance.getString('group_id_primary') ?? ''),
        grpid1: await LocalStorage.instance.getString('group_id'),
        firstName: await LocalStorage.instance.getString('first_name'),
        memberProfileID: int.tryParse(
            await LocalStorage.instance.getString('member_profile_id') ?? ''),
      );
      notifyListeners();
    }
  }

  // ─── Private Helpers ───────────────────────────────

  Future<String?> _getDeviceToken() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (_) {
      return null;
    }
  }

  Future<String?> _getDeviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor;
      } else {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id;
      }
    } catch (_) {
      return null;
    }
  }

  Future<String?> _getVersionNumber() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (_) {
      return null;
    }
  }

  Future<void> _storeSessionData(LoginTable table) async {
    final storage = LocalStorage.instance;
    await storage.setString('master_uid', '${table.masterUID ?? ''}');
    await storage.setString('group_id_primary', '${table.grpid0 ?? ''}');
    await storage.setString('group_id', table.grpid1 ?? '');
    await storage.setString('first_name', table.firstName ?? '');
    await storage.setString(
        'member_profile_id', '${table.memberProfileID ?? ''}');
    await storage.setString('imei_member_id', table.imeiMemId ?? '');
    await storage.setString('club_name', table.grpName ?? '');
    await storage.setString('profile_image', table.profileImage ?? '');
    await storage.setString('last_name', table.lastName ?? '');
    await storage.setString('middle_name', table.middleName ?? '');
  }
}
```

---

## 5. API Endpoints - Complete Reference

> **Note:** All endpoints are **POST** requests to `https://api.imeiconnect.com/api/{endpoint}`.
> Endpoint paths are **case-sensitive** and match iOS `APIConstant.swift` + actual usage in `WebserviceClass.swift` / ViewControllers.
> Flutter constant names are from `lib/src/core/constants/api_constants.dart`.

### 5.1 Login Module

| # | Flutter Constant | Endpoint | iOS Method | Parameters | Encoding | Purpose |
|---|---|---|---|---|---|---|
| 1 | `loginUserLogin` | `Login/UserLogin` | `signinTapped()` | `mobileNo`, `deviceToken`, `countryCode`, `loginType` | URLEncoded | Request OTP |
| 2 | `loginPostOtp` | `Login/PostOTP` | `OTPverify()` | `mobileNo`, `deviceToken`, `countryCode`, `deviceName`, `imeiNo`, `versionNo`, `loginType` | URLEncoded | Verify OTP |
| 3 | `loginGetWelcomeScreen` | `Login/GetWelcomeScreen` | `getAllGroupsWelcome()` | `masterUID`, `mobileno`, `loginType` | URLEncoded | Get user groups for welcome screen |
| 4 | `loginGetMemberDetails` | `Login/GetMemberDetails` | `MemberDetail()` | `masterUID` | URLEncoded | Get member info after login |
| 5 | `loginRegistration` | `Login/Registration` | `Registration()` | `mobileNo`, `countryCode`, `firstName`, `lastName`, `email` | URLEncoded | New user registration |

### 5.2 Group Module

| # | Flutter Constant | Endpoint | iOS Method | Parameters | Purpose |
|---|---|---|---|---|---|
| 6 | `groupGetAllCountriesAndCategories` | `Group/GetAllCountriesAndCategories` | `getCountryAndCategories()` | (none or minimal) | Fetch country + category lists |
| 7 | `groupGetAllGroupsList` | `Group/GetAllGroupsList` | `getAllGroupsOFUSer()` | `masterUID`, `imeiNo` | Get user's groups |
| 8 | `groupCreateGroup` | `Group/CreateGroup` | `createGroup()` | `grpId`, `grpName`, `grpImageID`, `grpType`, `grpCategory`, `addrss1`, `addrss2`, `city`, `state`, `pincode`, `country`, `emailid`, `mobile`, `userId`, `website`, `other` | Create new group |
| 9 | `groupCreateSubGroup` | `Group/CreateSubGroup` | — | Sub-group creation params | Create sub-group |
| 10 | `groupGetGroupDetail` | `Group/GetGroupDetail` | `getGroupInfoDetail()` | `groupId` | Group info |
| 11 | `groupGetSubGroupList` | `Group/GetSubGroupList` | `getSubGroupsList()` | `groupId` | List sub-groups |
| 12 | `groupGetSubGroupDetail` | `Group/GetSubGroupDetail` | `subGrpDEtailofUserGrp()` | `grpId`, `subgrpId` | Sub-group members |
| 13 | `groupAddMemberToGroup` | `Group/AddMemberToGroup` | — | Member + group IDs | Add single member |
| 14 | `groupAddMultipleMemberToGroup` | `Group/AddMultipleMemberToGroup` | — | Member IDs + group ID | Batch add members |
| 15 | `groupGlobalSearchGroup` | `Group/GlobalSearchGroup` | `getGlobalSearchGroupList()` | `searchText`, `masterUID` | Search groups |
| 16 | `groupDeleteByModuleName` | `Group/DeleteByModuleName` | `deleteDataWebservice()` | `typeID`, `type`, `profileID` | Delete module item (doc/ebulletin/album etc.) |
| 17 | `groupDeleteImage` | `Group/DeleteImage` | — | Image delete params | Remove profile image |
| 18 | `groupUpdateModuleDashboard` | `Group/UpdateModuleDashboard` | `updateMymodulesofGroupsOFUSer()` | `memberProfileId`, `modulelist` | Customize modules |
| 19 | `groupRemoveGroupCategory` | `Group/RemoveGroupCategory` | `removeGroupsOFUSer()` | `memberID`, `memberMainId` | Remove from group |
| 20 | `groupUpdateMemberGroupCategory` | `Group/UpdateMemberGroupCategory` | `updateGroupsOFUSer()` | `memberProfileId`, `mycategory`, `memberMainId` | Update group category |
| 21 | `groupGetGroupModulesList` | `Group/GetGroupModulesList` | `GetallmodulesofGroupsOFUSer()` | `groupId`, `memberProfileId` | List group modules |
| 22 | `groupGetNotificationCount` | `Group/GetNotificationCount` | `getNotifyCount()` | `masterUID` | Notification badge count |
| 23 | `groupGetEmail` | `Group/GetEmail` | — | `grpID`, `moduleID` | Get feedback email |
| 24 | `groupGetNewDashboard` | `Group/GetNewDashboard` | `getNewDashboard()` | `MasterId` | Dashboard data (banner clubs list) |
| 25 | `groupGetRotaryLibraryData` | `Group/GetRotaryLibraryData` | — | Group params | Rotary library content |
| 26 | `groupGetAdminSubModules` | `Group/getAdminSubModules` | — | `fk_groupID`, `fk_ProfileID` | Admin sub-modules |
| 27 | `groupGetEntityInfo` | `Group/GetEntityInfo` | — | `moduleID`, `SearchText`, `grpID` | About/FAQ/Help content |
| 28 | `groupGetAllGroupListSync` | `Group/GetAllGroupListSync` | — | Sync params | Offline group sync |
| 29 | `groupGetClubDetails` | `Group/GetClubDetails` | — | `grpID` | Club info |
| 30 | `groupGetClubHistory` | `Group/GetClubHistory` | — | `grpID` | Club history |
| 31 | `groupFeedback` | `Group/Feedback` | — | Feedback params | Send feedback |
| 32 | `groupGetZoneList` | `Group/getZonelist` | — | `grpId` | Zone list for leaderboard |
| 33 | `groupGetMobilePupup` | `Group/getMobilePupup` | — | Popup params | Mobile popup data |
| 34 | `groupUpdateMobilePupupFlag` | `Group/UpdateMobilePupupflag` | — | Flag params | Update popup seen flag |
| 35 | `groupUpdateDeviceTokenNumber` | `Group/UpdateDeviceTokenNumber` | `functionForSetDeviceToken()` | `MobileNumber`, `DeviceToken` | Register device push token |
| 36 | `groupGetAssistanceGov` | `Group/GetAssistanceGov` | — | `grpID`, `profileId` | ShowHideMonthlyReportModule flag |
| 37 | `groupGetRotaryIndiaAdminModules` | `Group/GetRotaryIndiaAdminModules` | — | Admin module params | Rotary India admin modules |
| 38 | `groupRemoveSelfFromGroup` | `Group/RemoveSelfFromGroup` | — | `memberProfileId`, `grpID` | Leave group |

### 5.3 Member Module

| # | Flutter Constant | Endpoint | iOS Method | Parameters | Purpose |
|---|---|---|---|---|---|
| 39 | `memberUpdateProfile` | `Member/UpdateProfile` | `UpdateMemberDetail()` | `memberUUID`, `memberMobile`, `memberName`, `memberEmailID`, `ProfilePicPath`, `ImageId` | Update basic profile |
| 40 | `memberGetDirectoryList` | `Member/GetDirectoryList` | `getDirectoryListGroupsOFUSer()` | `masterUID`, `grpID`, `searchText`, `page` | Paginated directory |
| 41 | `memberGetMember` | `Member/GetMember` | `getMemberDetail()` | `memberProfID`, `grpID` | Single member detail |
| 42 | `memberGetMemberListSync` | `Member/GetMemberListSync` | — | Sync params | Offline member sync |
| 43 | `memberUpdateProfileDetails` | `member/UpdateProfileDetails` | — | Profile update fields | Update profile details |
| 44 | `memberUpdateAddressDetails` | `Member/UpdateAddressDetails` | — | Address fields | Update address |
| 45 | `memberUpdateFamilyDetails` | `Member/UpdateFamilyDetails` | — | Family member fields | Add/update family |
| 46 | `memberGetUpdatedProfileDetails` | `Member/GetUpdatedmemberProfileDetails` | — | `profileId` | Refreshed profile |
| 47 | `memberUploadProfilePhoto` | `Member/UploadProfilePhoto` | — | Photo upload params | Upload profile pic |
| 48 | `memberGetBodList` | `Member/GetBODList` | — | `grpID` | Board of Directors |
| 49 | `memberGetGoverningCouncil` | `Member/GetGoverningCouncl` | — | `grpID` | Governing council list (note: iOS typo "Councl") |
| 50 | `memberUpdateMember` | `Member/UpdateMemebr` | — | Member update params | Update member (note: iOS typo "Memebr") |
| 51 | `memberUpdateProfilePersonalDetails` | `Member/UpdateProfilePersonalDetails` | — | `profileID`, `key` (JSON array) | Update personal detail fields |
| 52 | `memberSaveProfile` | `Member/Saveprofile` | — | Profile save params | Save profile |

### 5.4 Event Module

| # | Flutter Constant | Endpoint | iOS Method | Parameters | Purpose |
|---|---|---|---|---|---|
| 53 | `eventGetEventDetails` | `Event/GetEventDetails` | `getEventsDetail()` | `groupProfileID`, `grpID`, `eventID` | Single event detail |
| 54 | `eventGetEventList` | `Event/GetEventList` | `getEventList()` | `groupId`, `memberProfileId`, `searchText`, `type`, `isAdmin`, `moduleId` | Event listing |
| 55 | `eventAddEventNew` | `Event/AddEvent_New` | `addEventsResult()` | `eventID`, `questionEnable`, `eventType`, `membersIDs`, `eventImageID`, `evntTitle`, `evntDesc`, `eventVenue`, `venueLat`, `venueLong`, `evntDate`, `publishDate`, `expiryDate`, `notifyDate`, `userID`, `grpID`, `RepeatDateTime`, `questionType`, `questionText`, `option1`, `option2`, `sendSMSNonSmartPh`, `sendSMSAll`, `rsvpEnable`, `displayOnBanners`, `link`, `isSubGrpAdmin` | Create/update event |
| 56 | `eventAnsweringEvent` | `Event/AnsweringEvent` | — | `eventID`, `memberProfileId`, `answer` | RSVP response |
| 57 | `eventGetSmsCountDetails` | `Event/Getsmscountdetails` | — | SMS count params | SMS credit check |

### 5.5 Announcement Module

| # | Flutter Constant | Endpoint | iOS Method | Parameters | Purpose |
|---|---|---|---|---|---|
| 58 | `announcementGetList` | `Announcement/GetAnnouncementList` | — | `groupId`, `memberProfileId`, `searchText` | Announcement listing |
| 59 | `announcementGetDetails` | `Announcement/GetAnnouncementDetails` | `getAnnouceDetail()` | `announID`, `grpID`, `memberProfileID` | Announcement detail |
| 60 | `announcementAdd` | `Announcement/AddAnnouncement` | — | Announcement creation fields | Create announcement |

### 5.6 Document Module

| # | Flutter Constant | Endpoint | iOS Method | Parameters | Purpose |
|---|---|---|---|---|---|
| 61 | `documentAdd` | `DocumentSafe/AddDocument` | — | Document upload params | Upload document |
| 62 | `documentGetList` | `DocumentSafe/GetDocumentList` | — | `groupId`, `memberProfileId`, `searchText` | Document listing |
| 63 | `documentUpdateIsRead` | `DocumentSafe/UpdateDocumentIsRead` | — | `DocID`, `memberProfileID` | Mark doc as read |

### 5.7 E-Bulletin Module

| # | Flutter Constant | Endpoint | iOS Method | Parameters | Purpose |
|---|---|---|---|---|---|
| 64 | `ebulletinAdd` | `Ebulletin/AddEbulletin` | — | E-bulletin creation params | Create newsletter |
| 65 | `ebulletinGetYearWiseList` | `Ebulletin/GetYearWiseEbulletinList` | — | `groupId`, `year`, `searchText` | Year-wise listing |

### 5.8 Gallery Module

| # | Flutter Constant | Endpoint | iOS Method | Parameters | Purpose |
|---|---|---|---|---|---|
| 66 | `galleryGetAlbumsList` | `Gallery/GetAlbumsList` | — | `profileId`, `groupId`, `updatedOn`, `moduleId` | Album listing (old) |
| 67 | `galleryGetAlbumsListNew` | `Gallery/GetAlbumsList_New` | — | Same as above | Album listing (current) |
| 68 | `galleryGetAlbumPhotoList` | `Gallery/GetAlbumPhotoList_New` | — | `albumId`, `groupId`, `updatedOn` | Photos in album (**_New variant — iOS uses this**) |
| 69 | `galleryAddUpdateAlbum` | `Gallery/AddUpdateAlbum_New` | — | Album creation/update fields | Create/update album |
| 70 | `galleryAddUpdateAlbumPhoto` | `Gallery/AddUpdateAlbumPhoto` | — | Photo upload params | Add photo to album |
| 71 | `galleryDeleteAlbumPhoto` | `Gallery/DeleteAlbumPhoto` | — | Photo delete params | Delete photo |
| 72 | `galleryGetAlbumDetails` | `Gallery/GetAlbumDetails_New` | — | `albumId` | Album info |
| 73 | `galleryGetShowcaseDetails` | `Gallery/GetShowcaseDetails` | — | Showcase params | Showcase details |
| 74 | `galleryGetMerList` | `Gallery/GetMER_List` | — | `grpID`, `year` | MER(I)/iMélange list |
| 75 | `galleryGetYear` | `Gallery/GetYear` | — | `grpID` | Year dropdown for MER |
| 76 | `galleryFillYearList` | `Gallery/Fillyearlist` | — | `grpID` | Fill year list |
| 77 | `galleryValidateDirectBeneficiaries` | `Gallery/validateDirectBeneficiaries` | — | Validation params | Validate beneficiaries |
| 78 | `galleryGetBodMemberCount` | `Gallery/GEtBODMember_Cnt` | — | `grpID` | BOD member count |

### 5.9 Attendance Module

| # | Flutter Constant | Endpoint | iOS Method | Parameters | Purpose |
|---|---|---|---|---|---|
| 79 | `attendanceGetList` | `Attendance/GetAttendanceListNew` | — | `groupProfileID`, `month`, `year`, `moduleID` | Attendance records (**ListNew — not old GetAttendanceList**) |
| 80 | `attendanceGetDetails` | `Attendance/getAttendanceDetails` | — | `attendanceID` | Attendance detail |
| 81 | `attendanceAddEdit` | `Attendance/AttendanceAddEdit` | — | Attendance add/edit params | Create/update attendance |
| 82 | `attendanceDelete` | `Attendance/AttendanceDelete` | — | `attendanceID` | Delete attendance |
| 83 | `attendanceGetEventsListNew` | `Attendance/GetAttendanceEventsListNew` | — | Event list params | Attendance events list |
| 84 | `attendanceGetMemberDetails` | `Attendance/getAttendanceMemberDetails` | — | `attendanceID` | Member attendance details |
| 85 | `attendanceGetAnnsDetails` | `Attendance/getAttendanceAnnsDetails` | — | `attendanceID` | Announcement attendance |
| 86 | `attendanceGetAnnetsDetails` | `Attendance/getAttendanceAnnetsDetails` | — | `attendanceID` | Annets attendance |
| 87 | `attendanceGetVisitorsDetails` | `Attendance/getAttendanceVisitorsDetails` | — | `attendanceID` | Visitor attendance |
| 88 | `attendanceGetRotariansDetails` | `Attendance/getAttendanceRotariansDetails` | — | `attendanceID` | Rotarian attendance |
| 89 | `attendanceGetDistrictDelegateDetails` | `Attendance/getAttendanceDistrictDeleagateDetails` | — | `attendanceID` | District delegate attendance (note: iOS typo "Deleagate") |

### 5.10 Celebrations Module

| # | Flutter Constant | Endpoint | iOS Method | Parameters | Purpose |
|---|---|---|---|---|---|
| 90 | `celebrationGetMonthEventList` | `Celebrations/GetMonthEventList` | `getMonthEventList()` | `profileId`, `groupIds`, `selectedDate`, `updatedOns`, `groupCategory` | Month calendar events |
| 91 | `celebrationGetEventMinDetails` | `Celebrations/GetEventMinDetails` | `getEventMinDetails()` | `eventID` | Event mini details |
| 92 | `celebrationGetMonthEventListTypeWise` | `Celebrations/GetMonthEventListTypeWise` | `getMonthEventListTypeWise()` | `profileId`, `groupId`, `SelectedDate`, `Type` (B/A/E), `groupCategory` | Filter by type (club-level) |
| 93 | `celebrationGetMonthEventListDetails` | `Celebrations/GetMonthEventListDetails` | `getMonthEventListDetails()` | `profileId`, `groupId`, `SelectedDate`, `GroupCategory` | Day-wise details (club-level) |
| 94 | `celebrationGetTodaysBirthday` | `Celebrations/GetTodaysBirthday` | `getTodaysBirthday()` | `groupID` | Today's birthdays |
| 95 | `celebrationGetMonthEventListTypeWiseNational` | `Celebrations/GetMonthEventListTypeWise_National` | — | Same as #92 | Filter by type (national/district-level) |
| 96 | `celebrationGetMonthEventListDetailsNational` | `Celebrations/GetMonthEventListDetails_National` | — | Same as #93 | Day-wise details (national/district-level) |

### 5.11 Service Directory Module

| # | Flutter Constant | Endpoint | iOS Method | Parameters | Purpose |
|---|---|---|---|---|---|
| 97 | `serviceDirectoryGetCategories` | `ServiceDirectory/GetServiceCategoriesData` | — | `grpID`, `moduleID` | Service categories |
| 98 | `serviceDirectoryGetList` | `ServiceDirectory/GetServiceDirectoryCategories` | — | Category params | Category listing |
| 99 | `serviceDirectoryGetDetails` | `ServiceDirectory/GetServiceDirectoryDetails` | — | Detail params | Service directory detail |
| 100 | `serviceDirectoryAdd` | `ServiceDirectory/AddServiceDirectory` | — | Service add params | Add service directory entry |
| 101 | `serviceDirectoryGetSync` | `OfflineData/GetServiceDirectoryListSync` | — | Sync params | Offline service dir sync |

### 5.12 Settings Module

| # | Flutter Constant | Endpoint | iOS Method | Parameters | Purpose |
|---|---|---|---|---|---|
| 102 | `settingGetTouchbaseSetting` | `setting/GetTouchbaseSetting` | — | Settings params | Get push settings |
| 103 | `settingTouchbaseSetting` | `setting/TouchbaseSetting` | — | Settings update params | Update push settings |
| 104 | `settingGroupSetting` | `Setting/GroupSetting` | — | Group setting params | Update group settings |
| 105 | `settingGetGroupSetting` | `Setting/GetGroupSetting` | — | `grpID` | Get group settings |

### 5.13 Find Club Module

| # | Flutter Constant | Endpoint | iOS Method | Parameters | Purpose |
|---|---|---|---|---|---|
| 106 | `findClubGetClubList` | `FindClub/GetClubList` | — | `name`, `classification`, `club`, `district_number` | Search clubs |
| 107 | `findClubGetClubDetails` | `FindClub/GetClubDetails` | — | `clubId` | Club detail |
| 108 | `findClubGetClubsNearMe` | `FindClub/GetClubsNearMe` | — | `latitude`, `longitude` | Nearby clubs |
| 109 | `findClubGetPublicAlbumsList` | `FindClub/GetPublicAlbumsList` | — | `grpID` | Public gallery |
| 110 | `findClubGetPublicEventsList` | `FindClub/GetPublicEventsList` | — | `grpID` | Public events |
| 111 | `findClubGetPublicNewsletterList` | `FindClub/GetPublicNewsletterList` | — | `grpID` | Public newsletters |
| 112 | `findClubGetClubMembers` | `FindClub/GetClubMembers` | — | `grpID` | Club members |
| 113 | `findClubGetCommitteeList` | `FindClub/GetCommitteelist` | — | `grpID` | Sub-committee list |

### 5.14 Find Rotarian Module

| # | Flutter Constant | Endpoint | iOS Method | Parameters | Purpose |
|---|---|---|---|---|---|
| 114 | `findRotarianGetZoneChapterList` | `FindRotarian/GetZonechapterlist` | — | `grpID` | Zone + chapter dropdown |
| 115 | `findRotarianGetList` | `FindRotarian/GetRotarianList` | — | `name`, `classification`, `city`, `zone`, `chapter`, `district` | Search rotarians |
| 116 | `findRotarianGetDetails` | `FindRotarian/GetRotarianDetails` | — | `profileID` | Rotarian profile |
| 117 | `findRotarianGetDetailsAlt` | `FindRotarian/GetrotarianDetails` | — | `profileID` | Rotarian details (lowercase alt) |
| 118 | `findRotarianGetCategoryList` | `FindRotarian/GetCategoryList` | — | Category params | Category list for search |
| 119 | `findRotarianGetMemberGradeList` | `FindRotarian/GetMemberGradeList` | — | Grade params | Member grade dropdown |
| 120 | `findRotarianGetClubList` | `FindRotarian/GetClubList` | — | Club filter params | Club dropdown for search |

### 5.15 District Module

| # | Flutter Constant | Endpoint | iOS Method | Parameters | Purpose |
|---|---|---|---|---|---|
| 121 | `districtGetMemberListSync` | `District/GetDistrictMemberListSync` | — | `masterUID`, `grpID`, `searchText`, `pageNo`, `recordCount` | Paginated district members |
| 122 | `districtGetClubs` | `District/GetClubs` | — | `districtId` | District clubs |
| 123 | `districtGetCommittee` | `District/GetDistrictCommittee` | — | `grpID` | District committee |
| 124 | `districtGetClassificationListNew` | `District/GetClassificationList_New` | — | `grpID`, `pageNo`, `recordCount`, `searchText` | Classification list |
| 125 | `districtGetMemberByClassification` | `District/GetMemberByClassification` | — | `classification`, `grpID` | Members by classification |
| 126 | `districtGetMemberWithDynamicFields` | `District/GetMemberWithDynamicFields` | — | `memberProfileId`, `groupId` | Member detail with dynamic fields |

### 5.16 District Committee Module

| # | Flutter Constant | Endpoint | iOS Method | Parameters | Purpose |
|---|---|---|---|---|---|
| 127 | `districtCommitteeDetails` | `DistrictCommittee/districtCommitteeDetails` | — | Committee params | District committee details |

### 5.17 Club Monthly Report Module

| # | Flutter Constant | Endpoint | iOS Method | Parameters | Purpose |
|---|---|---|---|---|---|
| 128 | `clubMonthlyReportGetList` | `ClubMonthlyReport/GetMonthlyReportList` | — | `grpID`, `year` | Monthly report list |
| 129 | `clubMonthlyReportSendSms` | `ClubMonthlyReport/SendSMSAndMailToNonSubmitedReports` | — | SMS params | Send reminder for non-submitted reports |

### 5.18 Other Modules

| # | Flutter Constant | Endpoint | iOS Method | Parameters | Purpose |
|---|---|---|---|---|---|
| 130 | `offlineGetServiceDirectoryListSync` | `OfflineData/GetServiceDirectoryListSync` | — | Sync params | Offline service dir |
| 131 | `pastPresidentsGetList` | `PastPresidents/getPastPresidentsList` | — | `grpID` | Past presidents |
| 132 | `webLinkGetList` | `WebLink/GetWebLinksList` | — | `grpID`, `searchText` | Web links |
| 133 | `jitoGetRotaryLibraryData` | `Jito/GetRotaryLibraryData` | — | Library params | Voice of Jito |
| 134 | `uploadImage` | `upload/UploadImage` | — | `module=announcement` (query), multipart body | Image upload |
| 135 | `getLeaderBoardDetails` | `LeaderBoard/GetLeaderBoardDetails` | — | Leaderboard params | Leaderboard details |
| 136 | `versionGetVersionList` | `versionList/GetVersionList` | — | Version params | App version check |

---

## 6. Dart Models (json_serializable, all nullable)

### 6.1 Generic API Response

```dart
// lib/src/core/models/api_response_model.dart

import 'package:json_annotation/json_annotation.dart';

part 'api_response_model.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  @JsonKey(name: 'status')
  final String? status;

  @JsonKey(name: 'message')
  final String? message;

  @JsonKey(name: 'data')
  final T? data;

  @JsonKey(name: 'error')
  final String? error;

  @JsonKey(name: 'serverError')
  final String? serverError;

  @JsonKey(name: 'ErrorName')
  final String? errorName;

  ApiResponse({
    this.status,
    this.message,
    this.data,
    this.error,
    this.serverError,
    this.errorName,
  });

  bool get isSuccess => status == '0' || status == 'success' || message == 'success';

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$ApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);
}
```

### 6.2 Login Models

```dart
// lib/src/features/auth/models/login_result.dart

import 'package:json_annotation/json_annotation.dart';

part 'login_result.g.dart';

/// Maps to iOS: LoginResultResponseDTO (Swift Decodable struct)
/// Source: Controllers/ControllerObjectiveC/LoginResult/LoginResultResponse.swift
@JsonSerializable()
class LoginResult {
  @JsonKey(name: 'LoginResult')
  final LoginResultData? loginResult;

  LoginResult({this.loginResult});

  factory LoginResult.fromJson(Map<String, dynamic> json) =>
      _$LoginResultFromJson(json);
  Map<String, dynamic> toJson() => _$LoginResultToJson(this);
}

@JsonSerializable()
class LoginResultData {
  @JsonKey(name: 'message')
  final String? message;

  @JsonKey(name: 'status')
  final String? status;

  @JsonKey(name: 'isexists')
  final String? isExists;

  @JsonKey(name: 'ds')
  final LoginDs? ds;

  LoginResultData({this.message, this.status, this.isExists, this.ds});

  factory LoginResultData.fromJson(Map<String, dynamic> json) =>
      _$LoginResultDataFromJson(json);
  Map<String, dynamic> toJson() => _$LoginResultDataToJson(this);
}

@JsonSerializable()
class LoginDs {
  @JsonKey(name: 'Table')
  final List<LoginTable>? table;

  LoginDs({this.table});

  factory LoginDs.fromJson(Map<String, dynamic> json) =>
      _$LoginDsFromJson(json);
  Map<String, dynamic> toJson() => _$LoginDsToJson(this);
}
```

```dart
// lib/src/features/auth/models/login_table.dart

import 'package:json_annotation/json_annotation.dart';

part 'login_table.g.dart';

/// Maps to iOS: Table struct (Swift Decodable)
/// Contains session identity data stored in UserDefaults post-login
@JsonSerializable()
class LoginTable {
  @JsonKey(name: 'masterUID')
  final int? masterUID;

  @JsonKey(name: 'grpid0')
  final int? grpid0;

  @JsonKey(name: 'profileImage')
  final String? profileImage;

  @JsonKey(name: 'GrpName')
  final String? grpName;

  @JsonKey(name: 'grpid1')
  final String? grpid1;

  @JsonKey(name: 'LastName')
  final String? lastName;

  @JsonKey(name: 'IMEI_Mem_Id')
  final String? imeiMemId;

  @JsonKey(name: 'FirstName')
  final String? firstName;

  @JsonKey(name: 'groupMasterID')
  final int? groupMasterID;

  @JsonKey(name: 'memberProfileID')
  final int? memberProfileID;

  @JsonKey(name: 'MiddleName')
  final String? middleName;

  LoginTable({
    this.masterUID,
    this.grpid0,
    this.profileImage,
    this.grpName,
    this.grpid1,
    this.lastName,
    this.imeiMemId,
    this.firstName,
    this.groupMasterID,
    this.memberProfileID,
    this.middleName,
  });

  factory LoginTable.fromJson(Map<String, dynamic> json) =>
      _$LoginTableFromJson(json);
  Map<String, dynamic> toJson() => _$LoginTableToJson(this);
}
```

### 6.3 Group / Dashboard Models

```dart
// lib/src/features/dashboard/models/group_result.dart

import 'package:json_annotation/json_annotation.dart';

part 'group_result.g.dart';

/// Maps to iOS: TBGroupResult (Obj-C model)
@JsonSerializable()
class GroupResult {
  @JsonKey(name: 'message')
  final String? message;

  @JsonKey(name: 'status')
  final String? status;

  @JsonKey(name: 'list')
  final List<GroupItem>? list;

  GroupResult({this.message, this.status, this.list});

  factory GroupResult.fromJson(Map<String, dynamic> json) =>
      _$GroupResultFromJson(json);
  Map<String, dynamic> toJson() => _$GroupResultToJson(this);
}

@JsonSerializable()
class GroupItem {
  @JsonKey(name: 'grpID')
  final int? grpID;

  @JsonKey(name: 'grpName')
  final String? grpName;

  @JsonKey(name: 'grpType')
  final String? grpType;

  @JsonKey(name: 'grpCategory')
  final String? grpCategory;

  @JsonKey(name: 'grpImageID')
  final String? grpImageID;

  @JsonKey(name: 'memberCount')
  final int? memberCount;

  @JsonKey(name: 'isAdmin')
  final String? isAdmin;

  @JsonKey(name: 'isCategory')
  final String? isCategory;

  @JsonKey(name: 'address1')
  final String? address1;

  @JsonKey(name: 'address2')
  final String? address2;

  @JsonKey(name: 'city')
  final String? city;

  @JsonKey(name: 'state')
  final String? state;

  @JsonKey(name: 'pincode')
  final String? pincode;

  @JsonKey(name: 'country')
  final String? country;

  GroupItem({
    this.grpID,
    this.grpName,
    this.grpType,
    this.grpCategory,
    this.grpImageID,
    this.memberCount,
    this.isAdmin,
    this.isCategory,
    this.address1,
    this.address2,
    this.city,
    this.state,
    this.pincode,
    this.country,
  });

  factory GroupItem.fromJson(Map<String, dynamic> json) =>
      _$GroupItemFromJson(json);
  Map<String, dynamic> toJson() => _$GroupItemToJson(this);
}
```

```dart
// lib/src/features/dashboard/models/module_result.dart

import 'package:json_annotation/json_annotation.dart';

part 'module_result.g.dart';

/// Maps to iOS: TBGetGroupModuleResult
@JsonSerializable()
class ModuleResult {
  @JsonKey(name: 'message')
  final String? message;

  @JsonKey(name: 'status')
  final String? status;

  @JsonKey(name: 'list')
  final List<ModuleItem>? list;

  ModuleResult({this.message, this.status, this.list});

  factory ModuleResult.fromJson(Map<String, dynamic> json) =>
      _$ModuleResultFromJson(json);
  Map<String, dynamic> toJson() => _$ModuleResultToJson(this);
}

@JsonSerializable()
class ModuleItem {
  @JsonKey(name: 'moduleID')
  final int? moduleID;

  @JsonKey(name: 'moduleName')
  final String? moduleName;

  @JsonKey(name: 'moduleImage')
  final String? moduleImage;

  @JsonKey(name: 'isActive')
  final String? isActive;

  @JsonKey(name: 'sortOrder')
  final int? sortOrder;

  ModuleItem({
    this.moduleID,
    this.moduleName,
    this.moduleImage,
    this.isActive,
    this.sortOrder,
  });

  factory ModuleItem.fromJson(Map<String, dynamic> json) =>
      _$ModuleItemFromJson(json);
  Map<String, dynamic> toJson() => _$ModuleItemToJson(this);
}
```

```dart
// lib/src/features/dashboard/models/dashboard_result.dart

import 'package:json_annotation/json_annotation.dart';

part 'dashboard_result.g.dart';

/// Maps to iOS: TBDashboardResult (birthday/anniversary/event banners)
@JsonSerializable()
class DashboardResult {
  @JsonKey(name: 'message')
  final String? message;

  @JsonKey(name: 'status')
  final String? status;

  @JsonKey(name: 'BirthdayList')
  final List<CelebrationItem>? birthdayList;

  @JsonKey(name: 'AnniversaryList')
  final List<CelebrationItem>? anniversaryList;

  @JsonKey(name: 'EventList')
  final List<CelebrationItem>? eventList;

  DashboardResult({
    this.message,
    this.status,
    this.birthdayList,
    this.anniversaryList,
    this.eventList,
  });

  factory DashboardResult.fromJson(Map<String, dynamic> json) =>
      _$DashboardResultFromJson(json);
  Map<String, dynamic> toJson() => _$DashboardResultToJson(this);
}

@JsonSerializable()
class CelebrationItem {
  @JsonKey(name: 'name')
  final String? name;

  @JsonKey(name: 'date')
  final String? date;

  @JsonKey(name: 'pic')
  final String? pic;

  @JsonKey(name: 'type')
  final String? type;

  @JsonKey(name: 'id')
  final int? id;

  CelebrationItem({this.name, this.date, this.pic, this.type, this.id});

  factory CelebrationItem.fromJson(Map<String, dynamic> json) =>
      _$CelebrationItemFromJson(json);
  Map<String, dynamic> toJson() => _$CelebrationItemToJson(this);
}
```

### 6.4 Member / Directory Models

```dart
// lib/src/features/directory/models/member_result.dart

import 'package:json_annotation/json_annotation.dart';

part 'member_result.g.dart';

/// Maps to iOS: TBMemberResult (directory listing)
@JsonSerializable()
class MemberListResult {
  @JsonKey(name: 'message')
  final String? message;

  @JsonKey(name: 'status')
  final String? status;

  @JsonKey(name: 'list')
  final List<MemberItem>? list;

  MemberListResult({this.message, this.status, this.list});

  factory MemberListResult.fromJson(Map<String, dynamic> json) =>
      _$MemberListResultFromJson(json);
  Map<String, dynamic> toJson() => _$MemberListResultToJson(this);
}

@JsonSerializable()
class MemberItem {
  @JsonKey(name: 'memberProfileID')
  final int? memberProfileID;

  @JsonKey(name: 'memberName')
  final String? memberName;

  @JsonKey(name: 'firstName')
  final String? firstName;

  @JsonKey(name: 'lastName')
  final String? lastName;

  @JsonKey(name: 'middleName')
  final String? middleName;

  @JsonKey(name: 'mobile')
  final String? mobile;

  @JsonKey(name: 'email')
  final String? email;

  @JsonKey(name: 'pic')
  final String? pic;

  @JsonKey(name: 'designation')
  final String? designation;

  @JsonKey(name: 'classification')
  final String? classification;

  @JsonKey(name: 'clubName')
  final String? clubName;

  @JsonKey(name: 'bloodGroup')
  final String? bloodGroup;

  @JsonKey(name: 'dob')
  final String? dob;

  @JsonKey(name: 'doa')
  final String? doa;

  MemberItem({
    this.memberProfileID,
    this.memberName,
    this.firstName,
    this.lastName,
    this.middleName,
    this.mobile,
    this.email,
    this.pic,
    this.designation,
    this.classification,
    this.clubName,
    this.bloodGroup,
    this.dob,
    this.doa,
  });

  factory MemberItem.fromJson(Map<String, dynamic> json) =>
      _$MemberItemFromJson(json);
  Map<String, dynamic> toJson() => _$MemberItemToJson(this);
}
```

```dart
// lib/src/features/directory/models/member_detail_result.dart

import 'package:json_annotation/json_annotation.dart';

part 'member_detail_result.g.dart';

/// Maps to iOS: MemberListDetailResult
@JsonSerializable()
class MemberDetailResult {
  @JsonKey(name: 'message')
  final String? message;

  @JsonKey(name: 'status')
  final String? status;

  @JsonKey(name: 'PersonalDetails')
  final PersonalDetails? personalDetails;

  @JsonKey(name: 'AddressDetails')
  final List<AddressDetail>? addressDetails;

  @JsonKey(name: 'FamilyDetails')
  final List<FamilyDetail>? familyDetails;

  @JsonKey(name: 'OtherDetails')
  final List<OtherDetail>? otherDetails;

  MemberDetailResult({
    this.message,
    this.status,
    this.personalDetails,
    this.addressDetails,
    this.familyDetails,
    this.otherDetails,
  });

  factory MemberDetailResult.fromJson(Map<String, dynamic> json) =>
      _$MemberDetailResultFromJson(json);
  Map<String, dynamic> toJson() => _$MemberDetailResultToJson(this);
}

@JsonSerializable()
class PersonalDetails {
  @JsonKey(name: 'memberProfileID')
  final int? memberProfileID;

  @JsonKey(name: 'memberName')
  final String? memberName;

  @JsonKey(name: 'mobile')
  final String? mobile;

  @JsonKey(name: 'email')
  final String? email;

  @JsonKey(name: 'pic')
  final String? pic;

  @JsonKey(name: 'designation')
  final String? designation;

  @JsonKey(name: 'classification')
  final String? classification;

  @JsonKey(name: 'bloodGroup')
  final String? bloodGroup;

  @JsonKey(name: 'dob')
  final String? dob;

  @JsonKey(name: 'doa')
  final String? doa;

  @JsonKey(name: 'spouseName')
  final String? spouseName;

  PersonalDetails({
    this.memberProfileID,
    this.memberName,
    this.mobile,
    this.email,
    this.pic,
    this.designation,
    this.classification,
    this.bloodGroup,
    this.dob,
    this.doa,
    this.spouseName,
  });

  factory PersonalDetails.fromJson(Map<String, dynamic> json) =>
      _$PersonalDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$PersonalDetailsToJson(this);
}

@JsonSerializable()
class AddressDetail {
  @JsonKey(name: 'addressType')
  final String? addressType;

  @JsonKey(name: 'address')
  final String? address;

  @JsonKey(name: 'city')
  final String? city;

  @JsonKey(name: 'state')
  final String? state;

  @JsonKey(name: 'country')
  final String? country;

  @JsonKey(name: 'pincode')
  final String? pincode;

  @JsonKey(name: 'phone')
  final String? phone;

  @JsonKey(name: 'fax')
  final String? fax;

  AddressDetail({
    this.addressType,
    this.address,
    this.city,
    this.state,
    this.country,
    this.pincode,
    this.phone,
    this.fax,
  });

  factory AddressDetail.fromJson(Map<String, dynamic> json) =>
      _$AddressDetailFromJson(json);
  Map<String, dynamic> toJson() => _$AddressDetailToJson(this);
}

@JsonSerializable()
class FamilyDetail {
  @JsonKey(name: 'relation')
  final String? relation;

  @JsonKey(name: 'memberName')
  final String? memberName;

  @JsonKey(name: 'contact')
  final String? contact;

  @JsonKey(name: 'email')
  final String? email;

  @JsonKey(name: 'bloodGroup')
  final String? bloodGroup;

  @JsonKey(name: 'dob')
  final String? dob;

  @JsonKey(name: 'doa')
  final String? doa;

  FamilyDetail({
    this.relation,
    this.memberName,
    this.contact,
    this.email,
    this.bloodGroup,
    this.dob,
    this.doa,
  });

  factory FamilyDetail.fromJson(Map<String, dynamic> json) =>
      _$FamilyDetailFromJson(json);
  Map<String, dynamic> toJson() => _$FamilyDetailToJson(this);
}

@JsonSerializable()
class OtherDetail {
  @JsonKey(name: 'key')
  final String? key;

  @JsonKey(name: 'value')
  final String? value;

  OtherDetail({this.key, this.value});

  factory OtherDetail.fromJson(Map<String, dynamic> json) =>
      _$OtherDetailFromJson(json);
  Map<String, dynamic> toJson() => _$OtherDetailToJson(this);
}
```

### 6.5 Event Models

```dart
// lib/src/features/events/models/event_list_result.dart

import 'package:json_annotation/json_annotation.dart';

part 'event_list_result.g.dart';

/// Maps to iOS: EventListDetailResult
@JsonSerializable()
class EventListResult {
  @JsonKey(name: 'message')
  final String? message;

  @JsonKey(name: 'status')
  final String? status;

  @JsonKey(name: 'list')
  final List<EventItem>? list;

  EventListResult({this.message, this.status, this.list});

  factory EventListResult.fromJson(Map<String, dynamic> json) =>
      _$EventListResultFromJson(json);
  Map<String, dynamic> toJson() => _$EventListResultToJson(this);
}

@JsonSerializable()
class EventItem {
  @JsonKey(name: 'eventID')
  final int? eventID;

  @JsonKey(name: 'eventTitle')
  final String? eventTitle;

  @JsonKey(name: 'eventDescription')
  final String? eventDescription;

  @JsonKey(name: 'eventDate')
  final String? eventDate;

  @JsonKey(name: 'eventVenue')
  final String? eventVenue;

  @JsonKey(name: 'venueLat')
  final String? venueLat;

  @JsonKey(name: 'venueLong')
  final String? venueLong;

  @JsonKey(name: 'eventImageID')
  final String? eventImageID;

  @JsonKey(name: 'eventType')
  final String? eventType;

  @JsonKey(name: 'publishDate')
  final String? publishDate;

  @JsonKey(name: 'expiryDate')
  final String? expiryDate;

  @JsonKey(name: 'notifyDate')
  final String? notifyDate;

  @JsonKey(name: 'rsvpEnable')
  final String? rsvpEnable;

  @JsonKey(name: 'questionEnable')
  final String? questionEnable;

  @JsonKey(name: 'questionType')
  final String? questionType;

  @JsonKey(name: 'questionText')
  final String? questionText;

  @JsonKey(name: 'option1')
  final String? option1;

  @JsonKey(name: 'option2')
  final String? option2;

  @JsonKey(name: 'displayOnBanners')
  final String? displayOnBanners;

  @JsonKey(name: 'link')
  final String? link;

  @JsonKey(name: 'isSubGrpAdmin')
  final String? isSubGrpAdmin;

  EventItem({
    this.eventID,
    this.eventTitle,
    this.eventDescription,
    this.eventDate,
    this.eventVenue,
    this.venueLat,
    this.venueLong,
    this.eventImageID,
    this.eventType,
    this.publishDate,
    this.expiryDate,
    this.notifyDate,
    this.rsvpEnable,
    this.questionEnable,
    this.questionType,
    this.questionText,
    this.option1,
    this.option2,
    this.displayOnBanners,
    this.link,
    this.isSubGrpAdmin,
  });

  factory EventItem.fromJson(Map<String, dynamic> json) =>
      _$EventItemFromJson(json);
  Map<String, dynamic> toJson() => _$EventItemToJson(this);
}
```

### 6.6 Gallery Models

```dart
// lib/src/features/gallery/models/album_list_result.dart

import 'package:json_annotation/json_annotation.dart';

part 'album_list_result.g.dart';

/// Maps to iOS: TBAlbumsListResult
@JsonSerializable()
class AlbumListResult {
  @JsonKey(name: 'message')
  final String? message;

  @JsonKey(name: 'status')
  final String? status;

  @JsonKey(name: 'list')
  final List<AlbumItem>? list;

  AlbumListResult({this.message, this.status, this.list});

  factory AlbumListResult.fromJson(Map<String, dynamic> json) =>
      _$AlbumListResultFromJson(json);
  Map<String, dynamic> toJson() => _$AlbumListResultToJson(this);
}

@JsonSerializable()
class AlbumItem {
  @JsonKey(name: 'albumId')
  final int? albumId;

  @JsonKey(name: 'albumName')
  final String? albumName;

  @JsonKey(name: 'albumDescription')
  final String? albumDescription;

  @JsonKey(name: 'albumCoverPhoto')
  final String? albumCoverPhoto;

  @JsonKey(name: 'photoCount')
  final int? photoCount;

  @JsonKey(name: 'createdDate')
  final String? createdDate;

  @JsonKey(name: 'updatedOn')
  final String? updatedOn;

  AlbumItem({
    this.albumId,
    this.albumName,
    this.albumDescription,
    this.albumCoverPhoto,
    this.photoCount,
    this.createdDate,
    this.updatedOn,
  });

  factory AlbumItem.fromJson(Map<String, dynamic> json) =>
      _$AlbumItemFromJson(json);
  Map<String, dynamic> toJson() => _$AlbumItemToJson(this);
}
```

### 6.7 Notification Model

```dart
// lib/src/features/notifications/models/notification_model.dart

import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

/// Maps to iOS: NotificationModel + NotificaioModel
/// Stored in local SQLite (Notification_Table)
@JsonSerializable()
class NotificationItem {
  @JsonKey(name: 'msgID')
  final String? msgID;

  @JsonKey(name: 'title')
  final String? title;

  @JsonKey(name: 'details')
  final String? details;

  @JsonKey(name: 'expiryDate')
  final String? expiryDate;

  @JsonKey(name: 'notifyDate')
  final String? notifyDate;

  @JsonKey(name: 'sortDate')
  final String? sortDate;

  @JsonKey(name: 'flag')
  final String? flag;

  @JsonKey(name: 'notifyType')
  final String? notifyType;

  @JsonKey(name: 'clubDistrictType')
  final String? clubDistrictType;

  @JsonKey(name: 'readStatus')
  final String? readStatus;

  @JsonKey(name: 'jsonData')
  final String? jsonData;

  NotificationItem({
    this.msgID,
    this.title,
    this.details,
    this.expiryDate,
    this.notifyDate,
    this.sortDate,
    this.flag,
    this.notifyType,
    this.clubDistrictType,
    this.readStatus,
    this.jsonData,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      _$NotificationItemFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationItemToJson(this);
}
```

### 6.8 Subgroup Model

```dart
// lib/src/features/subgroups/models/subgroup_result.dart

import 'package:json_annotation/json_annotation.dart';

part 'subgroup_result.g.dart';

/// Maps to iOS: TBGetSubGroupListResult
@JsonSerializable()
class SubgroupListResult {
  @JsonKey(name: 'message')
  final String? message;

  @JsonKey(name: 'status')
  final String? status;

  @JsonKey(name: 'list')
  final List<SubgroupItem>? list;

  SubgroupListResult({this.message, this.status, this.list});

  factory SubgroupListResult.fromJson(Map<String, dynamic> json) =>
      _$SubgroupListResultFromJson(json);
  Map<String, dynamic> toJson() => _$SubgroupListResultToJson(this);
}

@JsonSerializable()
class SubgroupItem {
  @JsonKey(name: 'subGroupId')
  final int? subGroupId;

  @JsonKey(name: 'subGroupName')
  final String? subGroupName;

  @JsonKey(name: 'memberCount')
  final int? memberCount;

  SubgroupItem({this.subGroupId, this.subGroupName, this.memberCount});

  factory SubgroupItem.fromJson(Map<String, dynamic> json) =>
      _$SubgroupItemFromJson(json);
  Map<String, dynamic> toJson() => _$SubgroupItemToJson(this);
}

/// Maps to iOS: TBGetSubGroupDetailListResult
@JsonSerializable()
class SubgroupDetailResult {
  @JsonKey(name: 'message')
  final String? message;

  @JsonKey(name: 'status')
  final String? status;

  @JsonKey(name: 'list')
  final List<SubgroupMemberItem>? list;

  SubgroupDetailResult({this.message, this.status, this.list});

  factory SubgroupDetailResult.fromJson(Map<String, dynamic> json) =>
      _$SubgroupDetailResultFromJson(json);
  Map<String, dynamic> toJson() => _$SubgroupDetailResultToJson(this);
}

@JsonSerializable()
class SubgroupMemberItem {
  @JsonKey(name: 'memname')
  final String? memberName;

  @JsonKey(name: 'mobile')
  final String? mobile;

  @JsonKey(name: 'pic')
  final String? pic;

  @JsonKey(name: 'designation')
  final String? designation;

  @JsonKey(name: 'profileID')
  final int? profileID;

  SubgroupMemberItem({
    this.memberName,
    this.mobile,
    this.pic,
    this.designation,
    this.profileID,
  });

  factory SubgroupMemberItem.fromJson(Map<String, dynamic> json) =>
      _$SubgroupMemberItemFromJson(json);
  Map<String, dynamic> toJson() => _$SubgroupMemberItemToJson(this);
}
```

### 6.9 Find Rotarian / Club Models

```dart
// lib/src/features/find_rotarian/models/rotarian_result.dart

import 'package:json_annotation/json_annotation.dart';

part 'rotarian_result.g.dart';

@JsonSerializable()
class RotarianListResult {
  @JsonKey(name: 'message')
  final String? message;

  @JsonKey(name: 'status')
  final String? status;

  @JsonKey(name: 'list')
  final List<RotarianItem>? list;

  RotarianListResult({this.message, this.status, this.list});

  factory RotarianListResult.fromJson(Map<String, dynamic> json) =>
      _$RotarianListResultFromJson(json);
  Map<String, dynamic> toJson() => _$RotarianListResultToJson(this);
}

@JsonSerializable()
class RotarianItem {
  @JsonKey(name: 'profileID')
  final int? profileID;

  @JsonKey(name: 'memberName')
  final String? memberName;

  @JsonKey(name: 'clubName')
  final String? clubName;

  @JsonKey(name: 'designation')
  final String? designation;

  @JsonKey(name: 'masterUID')
  final int? masterUID;

  @JsonKey(name: 'memberMobile')
  final String? memberMobile;

  @JsonKey(name: 'pic')
  final String? pic;

  RotarianItem({
    this.profileID,
    this.memberName,
    this.clubName,
    this.designation,
    this.masterUID,
    this.memberMobile,
    this.pic,
  });

  factory RotarianItem.fromJson(Map<String, dynamic> json) =>
      _$RotarianItemFromJson(json);
  Map<String, dynamic> toJson() => _$RotarianItemToJson(this);
}

@JsonSerializable()
class ZoneChapterResult {
  @JsonKey(name: 'message')
  final String? message;

  @JsonKey(name: 'status')
  final String? status;

  @JsonKey(name: 'zoneList')
  final List<ZoneItem>? zoneList;

  @JsonKey(name: 'chapterList')
  final List<ChapterItem>? chapterList;

  ZoneChapterResult({
    this.message,
    this.status,
    this.zoneList,
    this.chapterList,
  });

  factory ZoneChapterResult.fromJson(Map<String, dynamic> json) =>
      _$ZoneChapterResultFromJson(json);
  Map<String, dynamic> toJson() => _$ZoneChapterResultToJson(this);
}

@JsonSerializable()
class ZoneItem {
  @JsonKey(name: 'PK_zoneID')
  final int? pkZoneId;

  @JsonKey(name: 'zoneName')
  final String? zoneName;

  ZoneItem({this.pkZoneId, this.zoneName});

  factory ZoneItem.fromJson(Map<String, dynamic> json) =>
      _$ZoneItemFromJson(json);
  Map<String, dynamic> toJson() => _$ZoneItemToJson(this);
}

@JsonSerializable()
class ChapterItem {
  @JsonKey(name: 'PK_chapterID')
  final int? pkChapterId;

  @JsonKey(name: 'chapterName')
  final String? chapterName;

  @JsonKey(name: 'FK_zoneID')
  final int? fkZoneId;

  ChapterItem({this.pkChapterId, this.chapterName, this.fkZoneId});

  factory ChapterItem.fromJson(Map<String, dynamic> json) =>
      _$ChapterItemFromJson(json);
  Map<String, dynamic> toJson() => _$ChapterItemToJson(this);
}
```

```dart
// lib/src/features/find_club/models/club_result.dart

import 'package:json_annotation/json_annotation.dart';

part 'club_result.g.dart';

@JsonSerializable()
class ClubListResult {
  @JsonKey(name: 'message')
  final String? message;

  @JsonKey(name: 'status')
  final String? status;

  @JsonKey(name: 'list')
  final List<ClubItem>? list;

  ClubListResult({this.message, this.status, this.list});

  factory ClubListResult.fromJson(Map<String, dynamic> json) =>
      _$ClubListResultFromJson(json);
  Map<String, dynamic> toJson() => _$ClubListResultToJson(this);
}

@JsonSerializable()
class ClubItem {
  @JsonKey(name: 'clubId')
  final int? clubId;

  @JsonKey(name: 'clubName')
  final String? clubName;

  @JsonKey(name: 'clubType')
  final String? clubType;

  @JsonKey(name: 'districtID')
  final String? districtID;

  @JsonKey(name: 'charterDate')
  final String? charterDate;

  @JsonKey(name: 'website')
  final String? website;

  @JsonKey(name: 'grpID')
  final int? grpID;

  @JsonKey(name: 'meetingDay')
  final String? meetingDay;

  @JsonKey(name: 'meetingTime')
  final String? meetingTime;

  @JsonKey(name: 'distance')
  final String? distance;

  @JsonKey(name: 'addressLine123')
  final String? addressLine;

  @JsonKey(name: 'postalCode')
  final String? postalCode;

  ClubItem({
    this.clubId,
    this.clubName,
    this.clubType,
    this.districtID,
    this.charterDate,
    this.website,
    this.grpID,
    this.meetingDay,
    this.meetingTime,
    this.distance,
    this.addressLine,
    this.postalCode,
  });

  factory ClubItem.fromJson(Map<String, dynamic> json) =>
      _$ClubItemFromJson(json);
  Map<String, dynamic> toJson() => _$ClubItemToJson(this);
}
```

### 6.10 Service Directory Model

```dart
// lib/src/features/service_directory/models/service_directory_result.dart

import 'package:json_annotation/json_annotation.dart';

part 'service_directory_result.g.dart';

/// Maps to iOS: TBServiceDirectoryResult + TBServiceDirectoryListResult
@JsonSerializable()
class ServiceDirectoryResult {
  @JsonKey(name: 'message')
  final String? message;

  @JsonKey(name: 'status')
  final String? status;

  @JsonKey(name: 'list')
  final List<ServiceItem>? list;

  ServiceDirectoryResult({this.message, this.status, this.list});

  factory ServiceDirectoryResult.fromJson(Map<String, dynamic> json) =>
      _$ServiceDirectoryResultFromJson(json);
  Map<String, dynamic> toJson() => _$ServiceDirectoryResultToJson(this);
}

@JsonSerializable()
class ServiceItem {
  @JsonKey(name: 'serviceId')
  final int? serviceId;

  @JsonKey(name: 'serviceName')
  final String? serviceName;

  @JsonKey(name: 'serviceDescription')
  final String? serviceDescription;

  @JsonKey(name: 'categoryId')
  final int? categoryId;

  @JsonKey(name: 'categoryName')
  final String? categoryName;

  @JsonKey(name: 'contactName')
  final String? contactName;

  @JsonKey(name: 'contactPhone')
  final String? contactPhone;

  @JsonKey(name: 'contactEmail')
  final String? contactEmail;

  @JsonKey(name: 'website')
  final String? website;

  @JsonKey(name: 'address')
  final String? address;

  ServiceItem({
    this.serviceId,
    this.serviceName,
    this.serviceDescription,
    this.categoryId,
    this.categoryName,
    this.contactName,
    this.contactPhone,
    this.contactEmail,
    this.website,
    this.address,
  });

  factory ServiceItem.fromJson(Map<String, dynamic> json) =>
      _$ServiceItemFromJson(json);
  Map<String, dynamic> toJson() => _$ServiceItemToJson(this);
}
```

---

## 7. Provider Integration Examples

### 7.1 Dashboard Provider (Complex Example)

```dart
// lib/src/features/dashboard/providers/dashboard_provider.dart

import 'package:flutter/foundation.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/storage/local_storage.dart';
import '../models/dashboard_result.dart';
import '../models/module_result.dart';

class DashboardProvider extends ChangeNotifier {
  ModuleResult? _moduleResult;
  DashboardResult? _dashboardData;
  List<ModuleItem>? _allModules;
  List<ModuleItem>? _myModules;
  bool _isLoading = false;
  String? _error;
  String? _currentGroupId;
  String? _currentProfileId;

  ModuleResult? get moduleResult => _moduleResult;
  DashboardResult? get dashboardData => _dashboardData;
  List<ModuleItem>? get allModules => _allModules;
  List<ModuleItem>? get myModules => _myModules;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Maps to: MainDashboardViewController.viewDidLoad + WebserviceClass.GetallmodulesofGroupsOFUSer
  Future<void> fetchModules({
    required String? groupId,
    required String? memberProfileId,
  }) async {
    _isLoading = true;
    _error = null;
    _currentGroupId = groupId;
    _currentProfileId = memberProfileId;
    notifyListeners();

    try {
      final response = await DioClient.instance.post(
        ApiConstants.groupGetGroupModulesList,
        data: {
          'groupId': groupId ?? '',
          'memberProfileId': memberProfileId ?? '',
        },
      );

      final data = response.data as Map<String, dynamic>?;
      if (data != null) {
        _moduleResult = ModuleResult.fromJson(data);
        _allModules = _moduleResult?.list;
        _myModules = _moduleResult?.list
            ?.where((m) => m.isActive == '1' || m.isActive == 'true')
            .toList();
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Maps to: BannerListViewController API call (dashboard birthday/anniversary/events)
  Future<void> fetchDashboardData({
    required String? profileId,
    required String? groupId,
  }) async {
    try {
      final response = await DioClient.instance.post(
        ApiConstants.groupGetNewDashboard,
        data: {
          'profileId': profileId ?? '',
          'groupId': groupId ?? '',
        },
        timeout: const Duration(seconds: 200),
      );

      final data = response.data as Map<String, dynamic>?;
      if (data != null) {
        _dashboardData = DashboardResult.fromJson(data);
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Maps to: CustumiseMyModuleViewController.updateMyModules
  Future<void> updateMyModules({
    required String? memberProfileId,
    required String? moduleList,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await DioClient.instance.post(
        ApiConstants.groupUpdateModuleDashboard,
        data: {
          'memberProfileId': memberProfileId ?? '',
          'modulelist': moduleList ?? '',
        },
      );

      // Refresh modules after update
      await fetchModules(
        groupId: _currentGroupId,
        memberProfileId: memberProfileId,
      );
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Maps to: AdminModuleListingViewController API call
  Future<List<ModuleItem>?> fetchAdminSubModules({
    required String? groupId,
    required String? profileId,
  }) async {
    try {
      final response = await DioClient.instance.post(
        ApiConstants.groupGetAdminSubModules,
        data: {
          'fk_groupID': groupId ?? '',
          'fk_ProfileID': profileId ?? '',
        },
      );

      final data = response.data as Map<String, dynamic>?;
      if (data != null) {
        final result = ModuleResult.fromJson(data);
        return result.list;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    return null;
  }
}
```

### 7.2 Screen with Consumer Widget

```dart
// lib/src/features/dashboard/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';
import '../../../core/widgets/common_loader.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../widgets/module_grid_item.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch data on screen load (mirrors iOS viewDidLoad)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<DashboardProvider>();
      provider.fetchModules(
        groupId: '...', // from local storage
        memberProfileId: '...', // from local storage
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: RefreshIndicator(
        onRefresh: () async {
          final provider = context.read<DashboardProvider>();
          await provider.fetchModules(
            groupId: '...',
            memberProfileId: '...',
          );
        },
        child: Consumer<DashboardProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const CommonLoader();
            }

            if (provider.error != null) {
              return EmptyStateWidget(message: provider.error);
            }

            final modules = provider.myModules;
            if (modules == null || modules.isEmpty) {
              return const EmptyStateWidget(message: 'No modules available');
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: modules.length,
              itemBuilder: (context, index) {
                final module = modules[index];
                return ModuleGridItem(
                  moduleName: module.moduleName,
                  moduleImage: module.moduleImage,
                  onTap: () => _navigateToModule(module),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _navigateToModule(ModuleItem module) {
    // Mirrors iOS MainDashboardViewController module routing
    switch (module.moduleName?.toUpperCase()) {
      case 'DIRECTORY':
        Navigator.pushNamed(context, '/directory');
        break;
      case 'EVENTS':
        Navigator.pushNamed(context, '/events');
        break;
      case 'ANNOUNCEMENT':
        Navigator.pushNamed(context, '/announcements');
        break;
      case 'GALLERY':
        Navigator.pushNamed(context, '/gallery');
        break;
      case 'ATTENDANCE':
        Navigator.pushNamed(context, '/attendance');
        break;
      case 'E-BULLETINE':
        Navigator.pushNamed(context, '/ebulletin');
        break;
      case 'DOCUMENTS':
        Navigator.pushNamed(context, '/documents');
        break;
      case 'CELEBRATIONS':
        Navigator.pushNamed(context, '/celebrations');
        break;
      case 'SERVICE DIRECTORY':
        Navigator.pushNamed(context, '/service-directory');
        break;
      // ... add remaining module routes
      default:
        break;
    }
  }
}
```

---

## 8. Error Handling Strategy

### iOS Original Pattern

```swift
// WebserviceClass pattern
switch response.result {
case .success:
    if let value = response.result.value {
        // Parse response
    }
case .failure(_): break  // Silent failure!
}

// ServiceManager pattern
case .failure(let error):
    var dictResponseData = ["serverError": "Error", "ErrorName": "Request time out."]
    completionBlock(dictResponseData)
```

### Flutter Replacement

```dart
// lib/src/core/network/api_response.dart

class ApiResult<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  ApiResult.success(this.data)
      : error = null,
        isSuccess = true;

  ApiResult.failure(this.error)
      : data = null,
        isSuccess = false;
}

// Usage in Provider (null-safe, no force unwrapping):
Future<void> fetchData() async {
  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    final response = await DioClient.instance.post(endpoint, data: params);
    final json = response.data as Map<String, dynamic>?;

    // Check for server error (mirrors iOS "serverError" key check)
    if (json?['serverError'] != null) {
      _error = json?['ErrorName']?.toString() ?? 'Server error';
    } else {
      final status = json?['status']?.toString();
      final message = json?['message']?.toString();

      if (status == '0' || message == 'success') {
        // Parse data safely
        _data = (json?['list'] as List?)
            ?.map((e) => Model.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        _error = message ?? 'Unknown error';
      }
    }
  } on DioException catch (e) {
    _error = switch (e.type) {
      DioExceptionType.connectionTimeout => 'Connection timeout',
      DioExceptionType.receiveTimeout => 'Request timeout',
      DioExceptionType.connectionError => 'No internet connection',
      _ => e.message ?? 'Network error',
    };
  } catch (e) {
    _error = e.toString();
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
```

---

## 9. File Upload Pattern

### iOS Original (WebserviceClass - Image Upload)

```swift
// Uses Alamofire multipart upload
Alamofire.upload(
    multipartFormData: { multipartFormData in
        multipartFormData.append(imageData, withName: "file",
                                fileName: "image.jpg",
                                mimeType: "image/jpeg")
    },
    to: baseUrl + "upload/UploadImage?module=announcement"
)
```

### Flutter Replacement

```dart
// lib/src/core/utils/file_uploader.dart

import 'dart:io';
import 'package:dio/dio.dart';
import '../network/dio_client.dart';
import '../constants/api_constants.dart';

class FileUploader {
  FileUploader._();

  /// Upload single image
  /// Maps to: iOS upload/UploadImage endpoint
  static Future<String?> uploadImage({
    required File? imageFile,
    required String? module,
    void Function(int, int)? onProgress,
  }) async {
    if (imageFile == null) return null;

    final fileName = imageFile.path.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
      ),
    });

    final response = await DioClient.instance.uploadFile(
      '${ApiConstants.uploadImage}?module=${module ?? 'announcement'}',
      formData: formData,
      onSendProgress: onProgress,
    );

    final data = response.data as Map<String, dynamic>?;
    return data?['imageId']?.toString();
  }

  /// Upload multiple images (batch - up to 5, mirrors AddPhotoViewController)
  static Future<List<String?>> uploadMultipleImages({
    required List<File?> imageFiles,
    required String? module,
    void Function(int completed, int total)? onBatchProgress,
  }) async {
    final results = <String?>[];
    final validFiles = imageFiles.where((f) => f != null).toList();

    for (int i = 0; i < validFiles.length; i++) {
      final imageId = await uploadImage(
        imageFile: validFiles[i],
        module: module,
      );
      results.add(imageId);
      onBatchProgress?.call(i + 1, validFiles.length);
    }

    return results;
  }
}
```

---

## 10. Offline & Caching Strategy

### iOS Original Pattern

```swift
// Offline sync endpoints used:
// Member/GetMemberListSync
// District/GetDistrictMemberListSync
// OfflineData/GetServiceDirectoryListSync
// Group/GetAllGroupListSync

// Local SQLite storage via FMDB for:
// - Notifications (Notification_Table)
// - Groups (GROUPMASTER table)
// - Modules (MODULE_DATA_MASTER table)

// ZIP file download for directory offline:
// SSZipArchive for extraction
```

### Flutter Replacement

```dart
// lib/src/core/storage/database_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static DatabaseHelper? _instance;
  static DatabaseHelper get instance => _instance ??= DatabaseHelper._();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'touchbase.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Notification table (mirrors iOS Notification_Table)
        await db.execute('''
          CREATE TABLE notifications (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            msgID TEXT,
            title TEXT,
            details TEXT,
            notifyDate TEXT,
            expiryDate TEXT,
            sortDate TEXT,
            readStatus TEXT DEFAULT 'UnRead',
            notifyType TEXT,
            clubDistrictType TEXT,
            jsonData TEXT
          )
        ''');

        // Group master (mirrors iOS GROUPMASTER)
        await db.execute('''
          CREATE TABLE group_master (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            grpID INTEGER,
            grpName TEXT,
            notificationCount INTEGER DEFAULT 0,
            updatedOn TEXT
          )
        ''');

        // Module data master (mirrors iOS MODULE_DATA_MASTER)
        await db.execute('''
          CREATE TABLE module_data_master (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            moduleID INTEGER,
            moduleName TEXT,
            grpID INTEGER,
            isActive TEXT,
            sortOrder INTEGER
          )
        ''');
      },
    );
  }

  // ─── Notification Operations (mirrors NotificaioModel methods) ──

  Future<void> saveNotification(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('notifications', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getAllNotifications() async {
    final db = await database;
    return db.query(
      'notifications',
      orderBy: 'readStatus ASC, sortDate DESC',
    );
  }

  Future<int> getUnreadCount() async {
    final db = await database;
    final result = await db.rawQuery(
      "SELECT COUNT(*) as count FROM notifications WHERE readStatus = 'UnRead'",
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> markAsRead(String? msgID) async {
    if (msgID == null) return;
    final db = await database;
    await db.update(
      'notifications',
      {'readStatus': 'Read'},
      where: 'msgID = ?',
      whereArgs: [msgID],
    );
  }

  Future<void> deleteNotification(String? msgID) async {
    if (msgID == null) return;
    final db = await database;
    await db.delete('notifications', where: 'msgID = ?', whereArgs: [msgID]);
  }

  Future<void> deleteOldNotifications() async {
    final db = await database;
    final twoDaysAgo =
        DateTime.now().subtract(const Duration(days: 2)).toIso8601String();
    await db.delete(
      'notifications',
      where: 'sortDate < ?',
      whereArgs: [twoDaysAgo],
    );
  }
}
```

### Local Storage Wrapper

```dart
// lib/src/core/storage/local_storage.dart

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  LocalStorage._();

  static LocalStorage? _instance;
  static LocalStorage get instance => _instance ??= LocalStorage._();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> setString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  Future<String?> getString(String key) async {
    return _prefs?.getString(key);
  }

  Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  Future<bool?> getBool(String key) async {
    return _prefs?.getBool(key);
  }

  Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  Future<void> clearAll() async {
    await _prefs?.clear();
  }
}
```

---

## pubspec.yaml Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  provider: ^6.1.2

  # Networking
  dio: ^5.4.0
  connectivity_plus: ^6.0.3

  # JSON Serialization
  json_annotation: ^4.9.0

  # Local Storage
  shared_preferences: ^2.2.3
  sqflite: ^2.3.2
  flutter_secure_storage: ^9.0.0

  # Firebase
  firebase_core: ^2.27.0
  firebase_analytics: ^10.8.9
  firebase_messaging: ^14.7.15

  # UI Components
  cached_network_image: ^3.3.1
  flutter_easyloading: ^3.0.5
  fluttertoast: ^8.2.4
  percent_indicator: ^4.2.3
  photo_view: ^0.15.0
  carousel_slider: ^4.2.1
  table_calendar: ^3.1.1

  # Maps
  google_maps_flutter: ^2.5.3

  # File Management
  path_provider: ^2.1.2
  image_picker: ^1.0.7
  share_plus: ^7.2.2
  url_launcher: ^6.2.5
  permission_handler: ^11.3.0

  # PDF
  pdf: ^3.10.8
  flutter_pdfview: ^1.3.2

  # Charts
  fl_chart: ^0.68.0

  # Navigation
  go_router: ^14.0.2

  # Device Info
  device_info_plus: ^10.1.0
  package_info_plus: ^8.0.0

  # Date Formatting
  intl: ^0.19.0

  # Archive
  archive: ^3.6.1

  # Calendar
  device_calendar: ^4.3.2

dev_dependencies:
  flutter_test:
    sdk: flutter

  # Code Generation
  build_runner: ^2.4.8
  json_serializable: ^6.7.1

  flutter_lints: ^3.0.1
```

---

**End of api_details.md**
