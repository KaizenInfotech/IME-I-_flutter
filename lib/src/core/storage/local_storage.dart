import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

/// Singleton wrapper around SharedPreferences.
/// Matches iOS CommonUserDefault.swift and all UserDefaults usage.
/// All getters return nullable types. No force unwraps.
class LocalStorage {
  LocalStorage._();

  static LocalStorage? _instance;
  static LocalStorage get instance => _instance ??= LocalStorage._();

  SharedPreferences? _prefs;

  /// Initialize SharedPreferences. Call once at app startup.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ─── GENERIC GETTERS / SETTERS ────────────────────────

  String? getString(String key) => _prefs?.getString(key);
  int? getInt(String key) => _prefs?.getInt(key);
  bool? getBool(String key) => _prefs?.getBool(key);
  double? getDouble(String key) => _prefs?.getDouble(key);

  Future<bool> setString(String key, String value) async =>
      await _prefs?.setString(key, value) ?? false;

  Future<bool> setInt(String key, int value) async =>
      await _prefs?.setInt(key, value) ?? false;

  Future<bool> setBool(String key, bool value) async =>
      await _prefs?.setBool(key, value) ?? false;

  Future<bool> setDouble(String key, double value) async =>
      await _prefs?.setDouble(key, value) ?? false;

  Future<bool> remove(String key) async =>
      await _prefs?.remove(key) ?? false;

  /// Clear all stored data (used on logout).
  Future<bool> clear() async => await _prefs?.clear() ?? false;

  // ─── PRIMARY USER IDENTITY ────────────────────────────
  // Mapped from iOS UserDefaults keys

  /// iOS: masterUID
  String? get masterUid => getString(AppConstants.keyMasterUid);
  Future<bool> setMasterUid(String value) =>
      setString(AppConstants.keyMasterUid, value);

  /// iOS: grpId0
  String? get groupIdPrimary => getString(AppConstants.keyGroupIdPrimary);
  Future<bool> setGroupIdPrimary(String value) =>
      setString(AppConstants.keyGroupIdPrimary, value);

  /// iOS: grpId
  String? get groupId => getString(AppConstants.keyGroupId);
  Future<bool> setGroupId(String value) =>
      setString(AppConstants.keyGroupId, value);

  /// iOS: firstName
  String? get firstName => getString(AppConstants.keyFirstName);
  Future<bool> setFirstName(String value) =>
      setString(AppConstants.keyFirstName, value);

  /// iOS: middleName
  String? get middleName => getString(AppConstants.keyMiddleName);
  Future<bool> setMiddleName(String value) =>
      setString(AppConstants.keyMiddleName, value);

  /// iOS: lastName
  String? get lastName => getString(AppConstants.keyLastName);
  Future<bool> setLastName(String value) =>
      setString(AppConstants.keyLastName, value);

  /// iOS: IMEI_Mem_Id
  String? get imeiMemberId => getString(AppConstants.keyImeiMemberId);
  Future<bool> setImeiMemberId(String value) =>
      setString(AppConstants.keyImeiMemberId, value);

  /// iOS: ClubName
  String? get clubName => getString(AppConstants.keyClubName);
  Future<bool> setClubName(String value) =>
      setString(AppConstants.keyClubName, value);

  /// iOS: profileImg
  String? get profileImage => getString(AppConstants.keyProfileImage);
  Future<bool> setProfileImage(String value) =>
      setString(AppConstants.keyProfileImage, value);

  /// iOS: memberIdss
  String? get memberProfileId => getString(AppConstants.keyMemberProfileId);
  Future<bool> setMemberProfileId(String value) =>
      setString(AppConstants.keyMemberProfileId, value);

  /// iOS: DeviceToken
  String? get deviceToken => getString(AppConstants.keyDeviceToken);
  Future<bool> setDeviceToken(String value) =>
      setString(AppConstants.keyDeviceToken, value);

  /// iOS: isAdmin
  String? get isAdmin => getString(AppConstants.keyIsAdmin);
  Future<bool> setIsAdmin(String value) =>
      setString(AppConstants.keyIsAdmin, value);

  /// iOS: user_auth_token_profileId
  String? get authProfileId => getString(AppConstants.keyAuthProfileId);
  Future<bool> setAuthProfileId(String value) =>
      setString(AppConstants.keyAuthProfileId, value);

  /// iOS: user_auth_token_groupId
  String? get authGroupId => getString(AppConstants.keyAuthGroupId);
  Future<bool> setAuthGroupId(String value) =>
      setString(AppConstants.keyAuthGroupId, value);

  // ─── SESSION KEYS ─────────────────────────────────────

  /// iOS: grpProfileId / grpProfileid
  String? get grpProfileId => getString(AppConstants.keyGrpProfileId);
  Future<bool> setGrpProfileId(String value) =>
      setString(AppConstants.keyGrpProfileId, value);

  /// iOS: isGrpAdmin
  String? get isGrpAdmin => getString(AppConstants.keyIsGrpAdmin);
  Future<bool> setIsGrpAdmin(String value) =>
      setString(AppConstants.keyIsGrpAdmin, value);

  /// iOS: Session_Club_ID
  String? get sessionClubId => getString(AppConstants.keySessionClubId);
  Future<bool> setSessionClubId(String value) =>
      setString(AppConstants.keySessionClubId, value);

  /// iOS: Session_Club_TYPE
  String? get sessionClubType => getString(AppConstants.keySessionClubType);
  Future<bool> setSessionClubType(String value) =>
      setString(AppConstants.keySessionClubType, value);

  /// iOS: Session_District_ID
  String? get sessionDistrictId =>
      getString(AppConstants.keySessionDistrictId);
  Future<bool> setSessionDistrictId(String value) =>
      setString(AppConstants.keySessionDistrictId, value);

  /// iOS: Session_Website
  String? get sessionWebsite => getString(AppConstants.keySessionWebsite);
  Future<bool> setSessionWebsite(String value) =>
      setString(AppConstants.keySessionWebsite, value);

  /// iOS: session_Login_Type
  String? get sessionLoginType => getString(AppConstants.keySessionLoginType);
  Future<bool> setSessionLoginType(String value) =>
      setString(AppConstants.keySessionLoginType, value);

  /// iOS: session_Mobile_Number
  String? get sessionMobileNumber =>
      getString(AppConstants.keySessionMobileNumber);
  Future<bool> setSessionMobileNumber(String value) =>
      setString(AppConstants.keySessionMobileNumber, value);

  /// iOS: session_grpProfileid
  String? get sessionGrpProfileId =>
      getString(AppConstants.keySessionGrpProfileId);
  Future<bool> setSessionGrpProfileId(String value) =>
      setString(AppConstants.keySessionGrpProfileId, value);

  /// iOS: session_GetGroupId
  String? get sessionGetGroupId =>
      getString(AppConstants.keySessionGetGroupId);
  Future<bool> setSessionGetGroupId(String value) =>
      setString(AppConstants.keySessionGetGroupId, value);

  /// iOS: session_GetModuleId
  String? get sessionGetModuleId =>
      getString(AppConstants.keySessionGetModuleId);
  Future<bool> setSessionGetModuleId(String value) =>
      setString(AppConstants.keySessionGetModuleId, value);

  /// iOS: session_notificationCount
  String? get sessionNotificationCount =>
      getString(AppConstants.keySessionNotificationCount);
  Future<bool> setSessionNotificationCount(String value) =>
      setString(AppConstants.keySessionNotificationCount, value);

  /// iOS: session_EntityId
  String? get sessionEntityId => getString(AppConstants.keySessionEntityId);
  Future<bool> setSessionEntityId(String value) =>
      setString(AppConstants.keySessionEntityId, value);

  /// iOS: session_lastUpdateDate
  String? get sessionLastUpdateDate =>
      getString(AppConstants.keySessionLastUpdateDate);
  Future<bool> setSessionLastUpdateDate(String value) =>
      setString(AppConstants.keySessionLastUpdateDate, value);

  // ─── MEMBER DETAIL KEYS ───────────────────────────────

  /// iOS: MobileNo
  String? get mobileNo => getString(AppConstants.keyMobileNo);
  Future<bool> setMobileNo(String value) =>
      setString(AppConstants.keyMobileNo, value);

  /// iOS: Email
  String? get email => getString(AppConstants.keyEmail);
  Future<bool> setEmail(String value) =>
      setString(AppConstants.keyEmail, value);

  /// iOS: DOB
  String? get dob => getString(AppConstants.keyDob);
  Future<bool> setDob(String value) =>
      setString(AppConstants.keyDob, value);

  /// iOS: DOA
  String? get doa => getString(AppConstants.keyDoa);
  Future<bool> setDoa(String value) =>
      setString(AppConstants.keyDoa, value);

  /// iOS: Designation
  String? get designation => getString(AppConstants.keyDesignation);
  Future<bool> setDesignation(String value) =>
      setString(AppConstants.keyDesignation, value);

  /// iOS: DistrictDesignation
  String? get districtDesignation =>
      getString(AppConstants.keyDistrictDesignation);
  Future<bool> setDistrictDesignation(String value) =>
      setString(AppConstants.keyDistrictDesignation, value);

  /// iOS: DistrictID
  String? get districtId => getString(AppConstants.keyDistrictId);
  Future<bool> setDistrictId(String value) =>
      setString(AppConstants.keyDistrictId, value);

  /// iOS: bloodGroup
  String? get bloodGroup => getString(AppConstants.keyBloodGroup);
  Future<bool> setBloodGroup(String value) =>
      setString(AppConstants.keyBloodGroup, value);

  /// iOS: Secondry_num
  String? get secondaryNum => getString(AppConstants.keySecondaryNum);
  Future<bool> setSecondaryNum(String value) =>
      setString(AppConstants.keySecondaryNum, value);

  /// iOS: Whatsapp_num
  String? get whatsappNum => getString(AppConstants.keyWhatsappNum);
  Future<bool> setWhatsappNum(String value) =>
      setString(AppConstants.keyWhatsappNum, value);

  /// iOS: Company_name
  String? get companyName => getString(AppConstants.keyCompanyName);
  Future<bool> setCompanyName(String value) =>
      setString(AppConstants.keyCompanyName, value);

  /// iOS: MembershipGrade
  String? get membershipGrade => getString(AppConstants.keyMembershipGrade);
  Future<bool> setMembershipGrade(String value) =>
      setString(AppConstants.keyMembershipGrade, value);

  // ─── UI STATE KEYS ────────────────────────────────────

  /// iOS: isRootVisitedFirst
  String? get isRootVisitedFirst =>
      getString(AppConstants.keyIsRootVisitedFirst);
  Future<bool> setIsRootVisitedFirst(String value) =>
      setString(AppConstants.keyIsRootVisitedFirst, value);

  /// iOS: splashOver
  String? get splashOver => getString(AppConstants.keySplashOver);
  Future<bool> setSplashOver(String value) =>
      setString(AppConstants.keySplashOver, value);

  /// iOS: ShowHideMonthlyReportModule
  String? get showHideMonthlyReport =>
      getString(AppConstants.keyShowHideMonthlyReport);
  Future<bool> setShowHideMonthlyReport(String value) =>
      setString(AppConstants.keyShowHideMonthlyReport, value);

  /// iOS: versionNumber
  String? get versionNumber => getString(AppConstants.keyVersionNumber);
  Future<bool> setVersionNumber(String value) =>
      setString(AppConstants.keyVersionNumber, value);

  // ─── CONVENIENCE METHODS ──────────────────────────────

  /// Save all login-related data at once.
  Future<void> saveLoginData({
    required String masterUid,
    required String groupId,
    required String groupIdPrimary,
    required String firstName,
    String? middleName,
    required String lastName,
    String? profileImage,
    String? memberProfileId,
    String? imeiMemberId,
    String? clubName,
    String? isAdmin,
    String? authProfileId,
    String? authGroupId,
    String? grpProfileId,
    String? isGrpAdmin,
    String? mobileNo,
    String? email,
  }) async {
    await setMasterUid(masterUid);
    await setGroupId(groupId);
    await setGroupIdPrimary(groupIdPrimary);
    await setFirstName(firstName);
    if (middleName != null) await setMiddleName(middleName);
    await setLastName(lastName);
    if (profileImage != null) await setProfileImage(profileImage);
    if (memberProfileId != null) await setMemberProfileId(memberProfileId);
    if (imeiMemberId != null) await setImeiMemberId(imeiMemberId);
    if (clubName != null) await setClubName(clubName);
    if (isAdmin != null) await setIsAdmin(isAdmin);
    if (authProfileId != null) await setAuthProfileId(authProfileId);
    if (authGroupId != null) await setAuthGroupId(authGroupId);
    if (grpProfileId != null) await setGrpProfileId(grpProfileId);
    if (isGrpAdmin != null) await setIsGrpAdmin(isGrpAdmin);
    if (mobileNo != null) await setMobileNo(mobileNo);
    if (email != null) await setEmail(email);
  }

  /// Get all login-related data as a map.
  Map<String, String?> getLoginData() {
    return {
      'masterUid': masterUid,
      'groupId': groupId,
      'groupIdPrimary': groupIdPrimary,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'profileImage': profileImage,
      'memberProfileId': memberProfileId,
      'imeiMemberId': imeiMemberId,
      'clubName': clubName,
      'isAdmin': isAdmin,
      'authProfileId': authProfileId,
      'authGroupId': authGroupId,
      'grpProfileId': grpProfileId,
      'isGrpAdmin': isGrpAdmin,
      'mobileNo': mobileNo,
      'email': email,
    };
  }

  /// Check if user is logged in.
  bool get isLoggedIn =>
      masterUid != null && masterUid?.isNotEmpty == true;

  /// Get full name from stored parts.
  String get fullName {
    final parts = [firstName, middleName, lastName]
        .where((p) => p != null && p.isNotEmpty)
        .toList();
    return parts.join(' ');
  }
}
