import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/local_storage.dart';
import '../models/group_result.dart';

/// Group state management.
/// Matches iOS getAllGroupsOFUSer / group switching logic in
/// MainDashboardViewController and CustomisedDashViewController.
class GroupProvider extends ChangeNotifier {
  // ─── STATE ─────────────────────────────────────────────

  TBGroupResult? _groupResult;
  TBGroupResult? get groupResult => _groupResult;

  List<GroupResult> _allGroups = [];
  List<GroupResult> get allGroups => _allGroups;

  List<GroupResult> _personalGroups = [];
  List<GroupResult> get personalGroups => _personalGroups;

  List<GroupResult> _socialGroups = [];
  List<GroupResult> get socialGroups => _socialGroups;

  List<GroupResult> _businessGroups = [];
  List<GroupResult> get businessGroups => _businessGroups;

  /// Uncategorized groups (iOS: myCategory == "0")
  List<GroupResult> _uncategorizedGroups = [];
  List<GroupResult> get uncategorizedGroups => _uncategorizedGroups;

  GroupResult? _selectedGroup;
  GroupResult? get selectedGroup => _selectedGroup;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // ─── FETCH ALL GROUPS ──────────────────────────────────
  // iOS: getAllGroupsOFUSer(memberID) → POST Group/GetAllGroupsList
  // Params: masterUID, imeiNo
  Future<bool> fetchGroups() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final masterUid = LocalStorage.instance.masterUid;
    if (masterUid == null || masterUid.isEmpty) {
      _error = 'User not logged in';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.groupGetAllGroupsList,
        body: {
          'masterUID': masterUid,
          'imeiNo': '', // iOS: UIDevice.current.identifierForVendor
        },
      );

      if (response.statusCode == 200) {
        final data = _parseResponseBody(response.body);
        if (data != null) {
          _groupResult = TBGroupResult.fromJson(data);

          if (_groupResult!.isSuccess) {
            _allGroups = _groupResult!.allGroupListResults ?? [];
            _personalGroups = _groupResult!.personalGroupListResults ?? [];
            _socialGroups = _groupResult!.socialGroupListResults ?? [];
            _businessGroups = _groupResult!.businessGroupListResults ?? [];

            // iOS: filter uncategorized (myCategory == "0")
            _uncategorizedGroups = _allGroups
                .where((g) => g.myCategory == '0')
                .toList();

            // Auto-select first group if none selected
            if (_selectedGroup == null && _allGroups.isNotEmpty) {
              _selectedGroup = _allGroups.first;
              _saveGroupToStorage(_selectedGroup!);
            }

            _isLoading = false;
            notifyListeners();
            return true;
          } else {
            _error = _groupResult!.message ?? 'Failed to fetch groups';
          }
        } else {
          _error = 'Invalid response';
        }
      } else {
        _error = _parseErrorMessage(response.body) ?? 'Server error';
      }
    } catch (e) {
      _error = 'Network error: $e';
      debugPrint('GroupProvider.fetchGroups error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ─── SWITCH GROUP ──────────────────────────────────────
  // iOS: tableView didSelectRow in group list → saves group details to UserDefaults
  Future<void> switchGroup(GroupResult group) async {
    _selectedGroup = group;
    _saveGroupToStorage(group);
    notifyListeners();
  }

  /// Save group details to local storage.
  /// iOS: UserDefaults.standard.setValue for grpId, isAdmin, grpProfileid, etc.
  void _saveGroupToStorage(GroupResult group) {
    if (group.grpId != null) {
      LocalStorage.instance.setGroupId(group.grpId!);
      LocalStorage.instance
          .setString(AppConstants.keySessionGetGroupId, group.grpId!);
      // Keep authGroupId in sync so all feature screens get the current group
      LocalStorage.instance.setAuthGroupId(group.grpId!);
    }
    if (group.isGrpAdmin != null) {
      LocalStorage.instance.setString(AppConstants.keyIsAdmin, group.isGrpAdmin!);
      LocalStorage.instance
          .setString(AppConstants.keyIsGrpAdmin, group.isGrpAdmin!);
    }
    if (group.grpProfileId != null) {
      LocalStorage.instance
          .setString(AppConstants.keyGrpProfileId, group.grpProfileId!);
      // Keep authProfileId in sync so all feature screens get the current profile
      LocalStorage.instance.setAuthProfileId(group.grpProfileId!);
    }
    if (group.myCategory != null) {
      LocalStorage.instance
          .setString(AppConstants.keyIsCategorySession, group.myCategory!);
    }
  }

  // ─── UPDATE GROUP CATEGORY ─────────────────────────────
  // iOS: Group/UpdateMemberGroupCategory
  // Used by CustomisedDashViewController to move groups between categories.
  Future<bool> updateGroupCategory({
    required String memberProfileId,
    required String myCategory,
    required String memberMainId,
  }) async {
    try {
      final response = await ApiClient.instance.post(
        ApiConstants.groupUpdateMemberGroupCategory,
        body: {
          'memberProfileId': memberProfileId,
          'mycategory': myCategory,
          'memberMainId': memberMainId,
        },
      );

      if (response.statusCode == 200) {
        final data = _parseResponseBody(response.body);
        if (data != null) {
          final status = data['status']?.toString();
          if (status == '0') {
            // Refresh groups after update
            await fetchGroups();
            return true;
          }
        }
      }
    } catch (e) {
      debugPrint('GroupProvider.updateGroupCategory error: $e');
    }
    return false;
  }

  // ─── SESSION EXPIRY CHECK ─────────────────────────────
  // Android: DashboardActivity.checkForUpdate() → GetGetAllGroupListSync
  // Returns response status: "0" = success, "2" = session expired
  Future<String?> checkSessionExpired() async {
    final masterUid = LocalStorage.instance.masterUid;
    if (masterUid == null || masterUid.isEmpty) return null;

    try {
      final deviceId = await _getDeviceId();
      final response = await ApiClient.instance.post(
        ApiConstants.groupGetAllGroupListSync,
        body: {
          'masterUID': masterUid,
          'imeiNo': deviceId,
          'loginType': LocalStorage.instance.sessionLoginType ?? '0',
          'mobileNo': LocalStorage.instance.sessionMobileNumber ?? '',
          'countryCode': '1',
          'updatedOn': LocalStorage.instance.sessionLastUpdateDate ?? '',
        },
      );

      if (response.statusCode == 200) {
        final data = _parseResponseBody(response.body);
        return data?['status']?.toString();
      }
    } catch (e) {
      debugPrint('GroupProvider.checkSessionExpired error: $e');
    }
    return null;
  }

  /// Android: Settings.Secure.ANDROID_ID / iOS: identifierForVendor
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

  // ─── CLEAR STATE ───────────────────────────────────────
  void clear() {
    _groupResult = null;
    _allGroups = [];
    _personalGroups = [];
    _socialGroups = [];
    _businessGroups = [];
    _uncategorizedGroups = [];
    _selectedGroup = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  // ─── HELPERS ───────────────────────────────────────────

  Map<String, dynamic>? _parseResponseBody(String body) {
    try {
      final decoded = json.decode(body);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    return null;
  }

  String? _parseErrorMessage(String body) {
    try {
      final decoded = json.decode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded['ErrorName']?.toString() ??
            decoded['message']?.toString() ??
            decoded['serverError']?.toString();
      }
    } catch (_) {}
    return null;
  }
}
