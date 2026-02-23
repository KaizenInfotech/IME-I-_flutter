import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/group_setting_result.dart';
import '../models/setting_result.dart';

class SettingsProvider extends ChangeNotifier {
  // ─── Touchbase Settings State ───────────────────────────
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<SettingItem> _settings = [];
  List<SettingItem> get settings => _settings;

  // ─── Group Settings State ──────────────────────────────
  bool _isLoadingGroup = false;
  bool get isLoadingGroup => _isLoadingGroup;

  List<GroupSettingItem> _groupSettings = [];
  List<GroupSettingItem> get groupSettings => _groupSettings;

  String _isMob = '';
  String _isEmail = '';
  String _isPersonal = '';
  String _isFamily = '';
  String _isBusiness = '';

  // ─── Fetch Touchbase Settings ──────────────────────────
  /// iOS: wsm.getTouchBaseSetting(mainMemberID)
  /// API: setting/GetTouchbaseSetting
  Future<void> fetchSettings({required String mainMasterId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.settingGetTouchbaseSetting,
        body: {'mainMasterId': mainMasterId},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = TBSettingResult.fromJson(jsonData);

        if (result.status == '0') {
          _settings = result.settings ?? [];
        } else {
          _settings = [];
        }
      } else {
        _error = 'Something went wrong, Please try again later';
      }
    } catch (e) {
      _error = 'Something went wrong, Please try again later';
      debugPrint('fetchSettings error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ─── Update Touchbase Setting ──────────────────────────
  /// iOS: wsm.updateTouchBaseSetting(grpId, UpdatedValue, mainMasterId)
  /// API: setting/TouchbaseSetting
  Future<void> updateSetting({
    required int index,
    required String mainMasterId,
  }) async {
    if (index < 0 || index >= _settings.length) return;

    final item = _settings[index];
    final newVal = item.isEnabled ? '0' : '1';
    item.grpVal = newVal;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.settingTouchbaseSetting,
        body: {
          'GroupId': item.grpId ?? '',
          'UpdatedValue': newVal,
          'mainMasterId': mainMasterId,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = TBSettingResult.fromJson(jsonData);
        if (result.status != '0') {
          // Revert on failure
          item.grpVal = item.isEnabled ? '0' : '1';
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('updateSetting error: $e');
    }
  }

  // ─── Fetch Group Settings ──────────────────────────────
  /// iOS: wsm.getTouchBasegroupsSetting(grpProfileID, GroupId)
  /// API: setting/GetGroupSetting
  Future<void> fetchGroupSettings({
    required String groupId,
    required String groupProfileId,
  }) async {
    _isLoadingGroup = true;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.settingGetGroupSetting,
        body: {
          'GroupProfileId': groupProfileId,
          'GroupId': groupId,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = TBGroupSettingResult.fromJson(jsonData);

        if (result.status == '0') {
          _groupSettings = result.settings ?? [];
          _isMob = result.isMob ?? '';
          _isEmail = result.isEmail ?? '';
          _isPersonal = result.isPersonal ?? '';
          _isFamily = result.isFamily ?? '';
          _isBusiness = result.isBusiness ?? '';
        } else {
          _groupSettings = [];
        }
      }
    } catch (e) {
      debugPrint('fetchGroupSettings error: $e');
    }

    _isLoadingGroup = false;
    notifyListeners();
  }

  // ─── Update Group Setting ──────────────────────────────
  /// iOS: wsm.updategrpTouchBaseSetting(...)
  /// API: setting/GroupSetting
  Future<void> updateGroupSetting({
    required int index,
    required String groupId,
    required String groupProfileId,
  }) async {
    if (index < 0 || index >= _groupSettings.length) return;

    final item = _groupSettings[index];
    final newVal = item.isEnabled ? '0' : '1';
    item.modVal = newVal;
    notifyListeners();

    try {
      await ApiClient.instance.post(
        ApiConstants.settingGroupSetting,
        body: {
          'GroupId': groupId,
          'UpdatedValue': newVal,
          'GroupProfileId': groupProfileId,
          'ModuleId': item.moduleId ?? '',
          'isMob': _isMob,
          'isEmail': _isEmail,
          'isPersonal': _isPersonal,
          'isFamily': _isFamily,
          'isBusiness': _isBusiness,
        },
      );
    } catch (e) {
      debugPrint('updateGroupSetting error: $e');
    }
  }
}
