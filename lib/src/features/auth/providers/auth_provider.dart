import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/storage/secure_storage.dart';
import '../models/login_result.dart';

/// Port of iOS WebserviceClass auth methods:
/// signinTapped, OTPverify, getAllGroupsWelcome, MemberDetail.
///
/// Uses ChangeNotifier + Consumer + FutureBuilder pattern.
class AuthProvider extends ChangeNotifier {
  // ═══════════════════════════════════════════════════════
  // STATE
  // ═══════════════════════════════════════════════════════

  LoginResult? _loginResult;
  LoginTable? _userSession;
  List<dynamic>? _welcomeGroups;
  bool _isLoading = false;
  String? _error;
  bool _isOtpSent = false;
  String? _mobileNumber;
  String? _countryCode;
  String? _loginType;

  LoginResult? get loginResult => _loginResult;
  LoginTable? get userSession => _userSession;
  List<dynamic>? get welcomeGroups => _welcomeGroups;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isOtpSent => _isOtpSent;
  String? get mobileNumber => _mobileNumber;

  // ═══════════════════════════════════════════════════════
  // LOGIN — iOS: signinTapped()
  // Endpoint: Login/UserLogin
  // Encoding: URLEncoding.default (form-encoded)
  // ═══════════════════════════════════════════════════════

  Future<bool> login({
    String? mobileNumber,
    String? countryCode,
    String? loginType,
  }) async {
    _isLoading = true;
    _error = null;
    _isOtpSent = false;
    notifyListeners();

    try {
      // Store for later use in OTP verify
      _mobileNumber = mobileNumber;
      _countryCode = countryCode;
      _loginType = loginType;

      // iOS: params = ["mobileNo": mobileNumber, "deviceToken": ...,
      //                "countryCode": countryCode, "loginType": loginType]
      // iOS sends countryCode "1" for India, others without "+" prefix.
      final deviceToken =
          await SecureStorage.instance.getDeviceToken() ?? '';
      final cleanCountryCode = _normalizeCountryCode(countryCode ?? '');

      final params = {
        'mobileNo': mobileNumber ?? '',
        'deviceToken': deviceToken,
        'countryCode': cleanCountryCode,
        'loginType': loginType ?? '',
      };

      // iOS: Alamofire.request(url, method: .post, encoding: URLEncoding.default)
      final response = await ApiClient.instance.postUrlEncoded(
        ApiConstants.loginUserLogin,
        body: params,
      );

      if (response.statusCode == 200) {
        final body = _parseResponseBody(response.body);
        if (body != null) {
          _loginResult = LoginResult.fromJson(body);

          if (_loginResult?.isSuccess == true) {
            _isOtpSent = true;
            _error = null;
          } else {
            _error = _loginResult?.message ?? 'Login failed';
          }
        } else {
          _error = 'Invalid response';
        }
      } else {
        _error = _parseErrorMessage(response.body) ?? 'Login failed';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return _isOtpSent;
  }

  // ═══════════════════════════════════════════════════════
  // OTP VERIFY — iOS: OTPverify()
  // Endpoint: Login/PostOTP
  // Encoding: URLEncoding.default (form-encoded)
  // ═══════════════════════════════════════════════════════

  Future<bool> verifyOtp({
    String? otp,
    String? mobileNumber,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final deviceToken =
          await SecureStorage.instance.getDeviceToken() ?? '';
      final deviceId = await _getDeviceId();
      final versionNo = await _getVersionNumber();

      // iOS: params = ["mobileNo": mobileNumber, "deviceToken": ...,
      //   "countryCode": ..., "deviceName": "iOS", "imeiNo": UUID,
      //   "versionNo": verSion, "loginType": ...]
      // iOS sends countryCode "1" for India, others without "+" prefix.
      final cleanCountryCode = _normalizeCountryCode(_countryCode ?? '');
      final params = {
        'mobileNo': mobileNumber ?? _mobileNumber ?? '',
        'deviceToken': deviceToken,
        'countryCode': cleanCountryCode,
        'deviceName': Platform.isIOS ? 'iOS' : 'Android',
        'imeiNo': deviceId,
        'versionNo': versionNo,
        'loginType': _loginType ?? '',
      };

      final response = await ApiClient.instance.postUrlEncoded(
        ApiConstants.loginPostOtp,
        body: params,
      );

      if (response.statusCode == 200) {
        final body = _parseResponseBody(response.body);
        if (body != null) {
          _loginResult = LoginResult.fromJson(body);

          if (_loginResult?.isSuccess == true) {
            // iOS: Extract Table[0] data and store in UserDefaults
            final table = _loginResult?.loginResultData?.ds?.table;
            if (table != null && table.isNotEmpty) {
              _userSession = table.first;
              await _saveLoginDataToLocal();
            }
            _error = null;
            return true;
          } else {
            _error = _loginResult?.message ?? 'OTP verification failed';
          }
        } else {
          _error = 'Invalid response';
        }
      } else {
        _error =
            _parseErrorMessage(response.body) ?? 'OTP verification failed';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return false;
  }

  // ═══════════════════════════════════════════════════════
  // WELCOME GROUPS — iOS: getAllGroupsWelcome()
  // Endpoint: Login/GetWelcomeScreen
  // Encoding: URLEncoding.default
  // ═══════════════════════════════════════════════════════

  Future<bool> getWelcomeGroups({
    String? masterUID,
    String? mobileNo,
    String? loginType,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final uid = masterUID ??
          _userSession?.masterUID?.toString() ??
          LocalStorage.instance.masterUid ??
          '';

      // iOS: params = ["masterUID": memberUID, "mobileno": mobileno,
      //                "loginType": loginType]
      final params = {
        'masterUID': uid,
        'mobileno': mobileNo ?? _mobileNumber ?? '',
        'loginType': loginType ?? _loginType ?? '',
      };

      final response = await ApiClient.instance.postUrlEncoded(
        ApiConstants.loginGetWelcomeScreen,
        body: params,
      );

      if (response.statusCode == 200) {
        final body = _parseResponseBody(response.body);
        if (body != null) {
          // iOS: WelcomeResult.fromJSONData parses:
          // {"WelcomeResult": {"status":"0", "Name":"...", "grpPartResults":[...]}}
          final welcomeResult =
              body['WelcomeResult'] as Map<String, dynamic>? ?? body;
          final status = welcomeResult['status']?.toString();

          if (status == '0') {
            // Extract grpPartResults array + inject Name into each item
            final groups =
                welcomeResult['grpPartResults'] as List<dynamic>? ?? [];
            final name = welcomeResult['Name']?.toString() ??
                welcomeResult['name']?.toString() ??
                '';

            // Inject member name into each group item for WelcomeScreen
            _welcomeGroups = groups.map((g) {
              if (g is Map<String, dynamic>) {
                return {...g, 'name': name};
              }
              return g;
            }).toList();

            _error = null;
            return true;
          } else {
            _error = welcomeResult['message']?.toString() ??
                'Failed to load groups';
          }
        } else {
          _error = 'Invalid response';
        }
      } else {
        _error =
            _parseErrorMessage(response.body) ?? 'Failed to load groups';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return false;
  }

  // ═══════════════════════════════════════════════════════
  // MEMBER DETAILS — iOS: MemberDetail()
  // Endpoint: Login/GetMemberDetails
  // Encoding: URLEncoding.default
  // ═══════════════════════════════════════════════════════

  Future<bool> getMemberDetails({String? masterUID}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final uid = masterUID ??
          LocalStorage.instance.masterUid ??
          '';

      // iOS: params = ["masterUID": memberUUID]
      final params = {'masterUID': uid};

      final response = await ApiClient.instance.postUrlEncoded(
        ApiConstants.loginGetMemberDetails,
        body: params,
      );

      if (response.statusCode == 200) {
        _error = null;
        return true;
      } else {
        _error = _parseErrorMessage(response.body) ??
            'Failed to load member details';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return false;
  }

  // ═══════════════════════════════════════════════════════
  // SAVE LOGIN DATA — iOS: UserDefaults.standard.set(...)
  // ═══════════════════════════════════════════════════════

  Future<void> _saveLoginDataToLocal() async {
    if (_userSession == null) return;

    final s = _userSession!;
    await LocalStorage.instance.saveLoginData(
      masterUid: s.masterUID?.toString() ?? '',
      groupId: s.grpid1 ?? '',
      groupIdPrimary: s.grpid0?.toString() ?? '',
      firstName: s.firstName ?? '',
      middleName: s.middleName,
      lastName: s.lastName ?? '',
      profileImage: s.profileImage,
      memberProfileId: s.memberProfileId?.toString(),
      imeiMemberId: s.imeiMemId,
      clubName: s.grpName,
      authProfileId: s.memberProfileId?.toString(),
      authGroupId: s.grpid1,
    );
  }

  /// Public method to save selected group from welcome screen.
  Future<void> selectGroup({
    required String groupId,
    String? groupName,
    String? grpProfileId,
    String? isGrpAdmin,
  }) async {
    await LocalStorage.instance.setGroupId(groupId);
    await LocalStorage.instance.setAuthGroupId(groupId);
    if (groupName != null) await LocalStorage.instance.setClubName(groupName);
    if (grpProfileId != null) {
      await LocalStorage.instance.setGrpProfileId(grpProfileId);
      await LocalStorage.instance.setAuthProfileId(grpProfileId);
    }
    if (isGrpAdmin != null) {
      await LocalStorage.instance.setIsGrpAdmin(isGrpAdmin);
    }
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════
  // REGISTRATION — iOS: Registration()
  // Endpoint: Login/Registration
  // Encoding: URLEncoding.default (form-encoded)
  // ═══════════════════════════════════════════════════════

  Future<bool> register({
    required String mobileNo,
    required String countryCode,
    required String firstName,
    required String lastName,
    String email = '',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final params = {
        'mobileNo': mobileNo,
        'countryCode': countryCode,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
      };

      final response = await ApiClient.instance.postUrlEncoded(
        ApiConstants.loginRegistration,
        body: params,
      );

      if (response.statusCode == 200) {
        final body = _parseResponseBody(response.body);
        if (body != null) {
          final status = body['status']?.toString();
          if (status == '0') {
            _error = null;
            return true;
          } else {
            _error = body['message']?.toString() ?? 'Registration failed';
          }
        } else {
          _error = 'Invalid response';
        }
      } else {
        _error = _parseErrorMessage(response.body) ?? 'Registration failed';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return false;
  }

  // ═══════════════════════════════════════════════════════
  // LOGOUT
  // ═══════════════════════════════════════════════════════

  Future<void> logout() async {
    await LocalStorage.instance.clear();
    await SecureStorage.instance.clearAll();
    _loginResult = null;
    _userSession = null;
    _welcomeGroups = null;
    _isOtpSent = false;
    _error = null;
    _mobileNumber = null;
    _countryCode = null;
    _loginType = null;
    notifyListeners();
  }

  /// Check if user is currently logged in.
  bool get isLoggedIn => LocalStorage.instance.isLoggedIn;

  // ═══════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════

  /// Parse JSON response body string into Map.
  Map<String, dynamic>? _parseResponseBody(String body) {
    try {
      final decoded = json.decode(body);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    return null;
  }

  /// Extract error message from JSON response body.
  String? _parseErrorMessage(String body) {
    try {
      final decoded = json.decode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded['message']?.toString() ??
            decoded['ErrorName']?.toString() ??
            decoded['serverError']?.toString();
      }
    } catch (_) {}
    return null;
  }

  /// iOS: UIDevice.current.identifierForVendor!.uuidString
  Future<String> _getDeviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? '';
      } else if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id;
      }
    } catch (_) {}
    return '';
  }

  /// iOS: global verSion variable (app version).
  Future<String> _getVersionNumber() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return info.version;
    } catch (_) {
      return '';
    }
  }

  /// iOS backend expects countryCode "1" for India, others without "+" prefix.
  String _normalizeCountryCode(String code) {
    final stripped = code.replaceAll('+', '').trim();
    if (stripped == '91') return '1';
    return stripped;
  }

  /// Clear error state.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
