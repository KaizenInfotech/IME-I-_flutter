import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/local_storage.dart';
import '../models/subgroup_detail_result.dart';
import '../models/subgroup_list_result.dart';

/// Port of iOS SubGroupListController + SubGroupDetailViewController +
/// CreateSubgrpViewController data logic.
class SubgroupsProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  // Sub-group list
  List<SubgroupItem> _subgroups = [];
  List<SubgroupItem> _filteredSubgroups = [];
  String _searchQuery = '';

  // Sub-group detail (members)
  List<SubgroupMember> _members = [];
  bool _isLoadingDetail = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<SubgroupItem> get subgroups =>
      _searchQuery.isEmpty ? _subgroups : _filteredSubgroups;
  List<SubgroupMember> get members => _members;
  bool get isLoadingDetail => _isLoadingDetail;

  /// iOS: viewWillAppear → getSubGroupsList — fetch sub-groups.
  /// API: Group/GetSubGroupList (POST)
  /// Parameter: groupId
  Future<void> fetchSubGroupList() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final localStorage = LocalStorage.instance;
      final grpId = localStorage.authGroupId ?? '';

      final response = await ApiClient.instance.post(
        ApiConstants.subgroupGetList,
        body: {'groupId': grpId},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = TBGetSubGroupListResult.fromJson(
            jsonData['TBGetSubGroupListResult'] as Map<String, dynamic>? ??
                jsonData);
        if (result.isSuccess) {
          _subgroups = result.subgroups ?? [];
          _filteredSubgroups = _subgroups;
        } else {
          _subgroups = [];
          _error = result.message ?? 'No sub-groups found';
        }
      } else {
        _error = 'Server error';
      }
    } catch (e) {
      _error = 'Failed to load sub-groups';
      debugPrint('fetchSubGroupList error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// iOS: SearchBar — client-side filter on subgrpTitle.
  void searchSubgroups(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredSubgroups = _subgroups;
    } else {
      final lower = query.toLowerCase();
      _filteredSubgroups = _subgroups.where((s) {
        return s.subgrpTitle?.toLowerCase().contains(lower) ?? false;
      }).toList();
    }
    notifyListeners();
  }

  /// iOS: subGrpDEtailofUserGrp — fetch sub-group members.
  /// API: Group/GetSubGroupDetail (POST)
  /// Parameters: groupId, subgrpId
  Future<void> fetchSubGroupDetail({required String subgrpId}) async {
    _isLoadingDetail = true;
    _members = [];
    notifyListeners();

    try {
      final localStorage = LocalStorage.instance;
      final grpId = localStorage.authGroupId ?? '';

      final response = await ApiClient.instance.post(
        ApiConstants.subgroupGetDetail,
        body: {
          'groupId': grpId,
          'subgrpId': subgrpId,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = TBGetSubGroupDetailResult.fromJson(
            jsonData['TBGetSubGroupDetailListResult']
                    as Map<String, dynamic>? ??
                jsonData);
        if (result.isSuccess) {
          _members = result.members ?? [];
        }
      }
    } catch (e) {
      debugPrint('fetchSubGroupDetail error: $e');
    }

    _isLoadingDetail = false;
    notifyListeners();
  }

  /// iOS: creatSubGRpClick → createSubGroup — create a new sub-group.
  /// API: Group/CreateSubGroup (POST)
  /// Parameters: subGroupTitle, memberProfileId (comma-separated), groupId,
  ///             memberMainId, parentID ("0" for top-level)
  Future<bool> createSubGroup({
    required String title,
    required List<String> memberProfileIds,
    String parentId = '0',
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final localStorage = LocalStorage.instance;
      final grpId = localStorage.authGroupId ?? '';
      final masterId = localStorage.masterUid ?? '';

      final response = await ApiClient.instance.post(
        ApiConstants.subgroupCreate,
        body: {
          'subGroupTitle': title,
          'memberProfileId': memberProfileIds.join(','),
          'groupId': grpId,
          'memberMainId': masterId,
          'parentID': parentId,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = TBGetSubGroupListResult.fromJson(
            jsonData['TBGetSubGroupListResult'] as Map<String, dynamic>? ??
                jsonData);
        _isLoading = false;
        notifyListeners();
        return result.isSuccess;
      }
    } catch (e) {
      debugPrint('createSubGroup error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
}
