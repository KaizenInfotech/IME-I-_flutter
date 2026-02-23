import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/module_result.dart';

/// Module customization state management.
/// Matches iOS CustumiseMyModuleViewController — fetches group modules,
/// allows reordering, and persists via Group/UpdateModuleDashboard.
class ModuleProvider extends ChangeNotifier {
  // ─── STATE ─────────────────────────────────────────────

  List<GroupModule> _modules = [];
  List<GroupModule> get modules => _modules;

  List<GroupModule> _customizedModules = [];
  List<GroupModule> get customizedModules => _customizedModules;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // ─── FETCH ALL MODULES (for customization) ─────────────
  // iOS: CustumiseMyModuleViewController calls
  // wsm.GetallmodulesofGroupsOFUSer(grpId, memberProfileId)
  // → POST Group/GetGroupModulesList
  Future<bool> fetchModules({
    required String groupId,
    required String memberProfileId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.groupGetGroupModulesList,
        body: {
          'groupId': groupId,
          'memberProfileId': memberProfileId,
        },
      );

      if (response.statusCode == 200) {
        final data = _parseResponseBody(response.body);
        if (data != null) {
          final result = TBGetGroupModuleResult.fromJson(data);
          if (result.isSuccess && result.groupListResult != null) {
            _modules = result.groupListResult!;
            _customizedModules = List.from(_modules);
            _isLoading = false;
            notifyListeners();
            return true;
          } else {
            _error = result.message ?? 'Failed to fetch modules';
          }
        } else {
          _error = 'Invalid response';
        }
      } else {
        _error = _parseErrorMessage(response.body) ?? 'Server error';
      }
    } catch (e) {
      _error = 'Network error: $e';
      debugPrint('ModuleProvider.fetchModules error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ─── REORDER MODULES ──────────────────────────────────
  // iOS: Drag reorder in CustumiseMyModuleViewController
  void reorderModules(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = _customizedModules.removeAt(oldIndex);
    _customizedModules.insert(newIndex, item);
    notifyListeners();
  }

  // ─── SAVE MODULE ORDER ─────────────────────────────────
  // iOS: Group/UpdateModuleDashboard with memberProfileId and modulelist
  Future<bool> saveModuleOrder({required String memberProfileId}) async {
    // Build comma-separated module ID list
    final moduleIdList =
        _customizedModules.map((m) => m.moduleId ?? '').join(',');

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.groupUpdateModuleDashboard,
        body: {
          'memberProfileId': memberProfileId,
          'modulelist': moduleIdList,
        },
      );

      if (response.statusCode == 200) {
        final data = _parseResponseBody(response.body);
        if (data != null) {
          final status = data['status']?.toString();
          return status == '0';
        }
      }
    } catch (e) {
      debugPrint('ModuleProvider.saveModuleOrder error: $e');
    }
    return false;
  }

  // ─── CLEAR STATE ───────────────────────────────────────
  void clear() {
    _modules = [];
    _customizedModules = [];
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
