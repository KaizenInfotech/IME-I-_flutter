import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/local_storage.dart';
import '../models/admin_submodules_result.dart';
import '../models/dashboard_result.dart';
import '../models/module_result.dart';

/// Dashboard state management.
/// Matches iOS MainDashboardViewController data flow:
/// - Fetches modules for current group from API
/// - Filters modules based on admin status
/// - Fetches dashboard banners and notification count
class DashboardProvider extends ChangeNotifier {
  // ─── STATE ─────────────────────────────────────────────

  List<GroupModule> _modules = [];
  List<GroupModule> get modules => _modules;

  List<DashboardBanner> _banners = [];
  List<DashboardBanner> get banners => _banners;

  int _notificationCount = 0;
  int get notificationCount => _notificationCount;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // ─── FETCH MODULES ─────────────────────────────────────
  // iOS: fetchData() reads from SQLite MODULE_DATA_MASTER table.
  // In Flutter we fetch from API directly (Group/GetGroupModulesList).
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
            _modules = _filterModules(result.groupListResult!);
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
      debugPrint('DashboardProvider.fetchModules error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// iOS: fetchData() filters modules based on admin status and category.
  /// - Skips "Attendance" for non-admins
  /// - Skips "Sub groups"
  /// - Handles "Admin" module visibility
  /// - Handles "Club Monthly Report" / "Category" / "TRF Contribution" based on flags
  List<GroupModule> _filterModules(List<GroupModule> allModules) {
    final isAdmin =
        LocalStorage.instance.getString(AppConstants.keyIsAdmin) ?? 'No';
    final isCategory =
        LocalStorage.instance.getString(AppConstants.keyIsCategorySession) ??
            '0';
    final showHideMonthlyReport =
        LocalStorage.instance.getString(AppConstants.keyShowHideMonthlyReport);

    final filtered = <GroupModule>[];
    final seenNames = <String>{};

    for (final module in allModules) {
      final name = module.moduleName ?? '';

      // Skip duplicates (iOS: modulenamescheck logic)
      if (seenNames.contains(name)) continue;
      seenNames.add(name);

      // iOS: Skip "Sub groups"
      if (name == 'Sub groups') continue;

      // iOS: Skip "Attendance" for non-admins
      if (isAdmin != 'Yes' && name == 'Attendance') continue;

      // iOS: Handle "Admin" module — only show for admins with category "1"
      if (name == 'Admin') {
        if (isAdmin == 'Yes' && isCategory == '1') {
          filtered.add(module);
        }
        continue;
      }

      // iOS: Handle "Club Monthly Report" / "Category" / "TRF Contribution"
      if (name == 'Club Monthly Report' ||
          name == 'Category' ||
          name == 'TRF Contribution') {
        if (isCategory == '1') {
          // Skip for category 1
          continue;
        }
        if (isAdmin == 'Yes') {
          filtered.add(module);
        } else {
          // Check ShowHideMonthlyReportModule flag
          if (showHideMonthlyReport != 'HideMonthlyReportModule') {
            filtered.add(module);
          }
        }
        continue;
      }

      filtered.add(module);
    }

    return filtered;
  }

  // ─── FETCH DASHBOARD BANNERS ───────────────────────────
  // iOS: Group/GetNewDashboard
  Future<bool> fetchBanners({
    required String groupId,
    required String memberProfileId,
  }) async {
    try {
      final response = await ApiClient.instance.post(
        ApiConstants.groupGetNewDashboard,
        body: {
          'groupId': groupId,
          'memberProfileId': memberProfileId,
        },
      );

      if (response.statusCode == 200) {
        final data = _parseResponseBody(response.body);
        if (data != null) {
          final result = TBDashboardResult.fromJson(data);
          if (result.isSuccess) {
            _banners = result.bannerList ?? result.sliderList ?? [];
            notifyListeners();
            return true;
          }
        }
      }
    } catch (e) {
      debugPrint('DashboardProvider.fetchBanners error: $e');
    }
    return false;
  }

  // ─── FETCH NOTIFICATION COUNT ──────────────────────────
  // iOS: Group/GetNotificationCount
  Future<void> fetchNotificationCount({
    required String groupId,
    required String memberProfileId,
  }) async {
    try {
      final response = await ApiClient.instance.post(
        ApiConstants.groupGetNotificationCount,
        body: {
          'groupId': groupId,
          'memberProfileId': memberProfileId,
        },
      );

      if (response.statusCode == 200) {
        final data = _parseResponseBody(response.body);
        if (data != null) {
          final result = NotificationCountResult.fromJson(data);
          _notificationCount = result.count;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('DashboardProvider.fetchNotificationCount error: $e');
    }
  }

  // ─── FETCH ADMIN SUB-MODULES ───────────────────────────
  // iOS: Group/getAdminSubModules with Fk_groupID, fk_ProfileID
  Future<AdminSubmodulesResult?> fetchAdminSubModules({
    required String groupId,
    required String profileId,
  }) async {
    try {
      final response = await ApiClient.instance.post(
        ApiConstants.groupGetAdminSubModules,
        body: {
          'Fk_groupID': groupId,
          'fk_ProfileID': profileId,
        },
      );

      if (response.statusCode == 200) {
        final data = _parseResponseBody(response.body);
        if (data != null) {
          return AdminSubmodulesResult.fromJson(data);
        }
      }
    } catch (e) {
      debugPrint('DashboardProvider.fetchAdminSubModules error: $e');
    }
    return null;
  }

  // ─── UPDATE MODULE DASHBOARD ───────────────────────────
  // iOS: Group/UpdateModuleDashboard
  Future<bool> updateModuleDashboard({
    required String memberProfileId,
    required String moduleList,
  }) async {
    try {
      final response = await ApiClient.instance.post(
        ApiConstants.groupUpdateModuleDashboard,
        body: {
          'memberProfileId': memberProfileId,
          'modulelist': moduleList,
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
      debugPrint('DashboardProvider.updateModuleDashboard error: $e');
    }
    return false;
  }

  // ─── GET ASSISTANCE GOV ────────────────────────────────
  // iOS: Group/GetAssistanceGov — sets ShowHideMonthlyReportModule flag
  Future<void> fetchAssistanceGovDetails({
    required String groupId,
    required String profileId,
  }) async {
    try {
      final response = await ApiClient.instance.post(
        ApiConstants.groupGetAssistanceGov,
        body: {
          'grpID': groupId,
          'profileId': profileId,
        },
      );

      if (response.statusCode == 200) {
        final data = _parseResponseBody(response.body);
        if (data != null) {
          // iOS: sets UserDefaults "ShowHideMonthlyReportModule"
          final flag = data['ShowHideMonthlyReportModule']?.toString() ??
              data['showHideMonthlyReportModule']?.toString();
          if (flag != null) {
            await LocalStorage.instance
                .setString(AppConstants.keyShowHideMonthlyReport, flag);
          }
        }
      }
    } catch (e) {
      debugPrint('DashboardProvider.fetchAssistanceGovDetails error: $e');
    }
  }

  // ─── CLEAR STATE ───────────────────────────────────────
  void clear() {
    _modules = [];
    _banners = [];
    _notificationCount = 0;
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
