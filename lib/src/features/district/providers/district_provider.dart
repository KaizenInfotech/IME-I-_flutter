import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/local_storage.dart';
import '../models/district_result.dart';

/// Port of iOS DistrictDirectoryOnlineViewController + DistrictClubMemberListViewController
/// data logic — district members, classifications, clubs, member detail.
class DistrictProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  // District members
  List<DistrictMember> _members = [];
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoadingMore = false;

  // Classifications
  List<ClassificationItem> _classifications = [];

  // District clubs
  List<DistrictClub> _clubs = [];
  List<DistrictClub> _filteredClubs = [];
  String _clubSearchQuery = '';

  // Member detail
  MemberDetailData? _memberDetail;
  bool _isLoadingDetail = false;

  // Filter mode
  String _filterMode = 'Rotarian'; // "Rotarian" or "Classification"

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<DistrictMember> get members => _members;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMorePages => _currentPage < _totalPages;
  List<ClassificationItem> get classifications => _classifications;
  List<DistrictClub> get clubs =>
      _clubSearchQuery.isEmpty ? _clubs : _filteredClubs;
  MemberDetailData? get memberDetail => _memberDetail;
  bool get isLoadingDetail => _isLoadingDetail;
  String get filterMode => _filterMode;

  void setFilterMode(String mode) {
    _filterMode = mode;
    notifyListeners();
  }

  /// iOS: GetDistrictMemberList — fetch district members with pagination.
  /// API: District/GetDistrictMemberList (POST)
  Future<void> fetchDistrictMembers({
    required String groupId,
    String searchText = '',
    int page = 1,
  }) async {
    if (page == 1) {
      _isLoading = true;
      _members = [];
    } else {
      _isLoadingMore = true;
    }
    _error = null;
    notifyListeners();

    try {
      final localStorage = LocalStorage.instance;
      final masterId = localStorage.masterUid ?? '';

      final response = await ApiClient.instance.post(
        ApiConstants.districtGetMemberListSync,
        body: {
          'masterUID': masterId,
          'grpID': groupId,
          'searchText': searchText,
          'pageNo': page.toString(),
          'recordCount': '20',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = TBDistrictMemberListResult.fromJson(jsonData);
        if (result.isSuccess) {
          if (page == 1) {
            _members = result.members ?? [];
          } else {
            _members.addAll(result.members ?? []);
          }
          _currentPage = result.currentPageInt;
          _totalPages = result.totalPagesInt;
        } else {
          if (page == 1) _error = result.message ?? 'No members found';
        }
      } else {
        if (page == 1) _error = 'Server error';
      }
    } catch (e) {
      if (page == 1) _error = 'Failed to load district members';
      debugPrint('fetchDistrictMembers error: $e');
    }

    _isLoading = false;
    _isLoadingMore = false;
    notifyListeners();
  }

  /// Load next page of district members.
  Future<void> loadMoreMembers({required String groupId}) async {
    if (_isLoadingMore || !hasMorePages) return;
    await fetchDistrictMembers(groupId: groupId, page: _currentPage + 1);
  }

  /// iOS: GetClassificationList_New — fetch classifications.
  /// API: District/GetClassificationList_New (POST)
  Future<void> fetchClassifications({
    required String groupId,
    String searchText = '',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.districtGetClassificationListNew,
        body: {
          'grpID': groupId,
          'pageNo': '1',
          'recordCount': '100',
          'searchText': searchText,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final resultData =
            jsonData['ClassificationListResult'] as Map<String, dynamic>?;
        if (resultData != null) {
          final list = resultData['classifications'] as List<dynamic>? ?? [];
          _classifications = list
              .map((e) =>
                  ClassificationItem.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      _error = 'Failed to load classifications';
      debugPrint('fetchClassifications error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// iOS: GetMemberByClassification — fetch members by classification.
  /// API: District/GetMemberByClassification (POST)
  Future<void> fetchMembersByClassification({
    required String groupId,
    required String classification,
  }) async {
    _isLoading = true;
    _error = null;
    _members = [];
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.districtGetMemberByClassification,
        body: {
          'classification': classification,
          'grpID': groupId,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final resultData =
            jsonData['MemberListResult'] as Map<String, dynamic>?;
        if (resultData != null) {
          final result = TBDistrictMemberListResult.fromJson(resultData);
          _members = result.members ?? [];
        }
      }
    } catch (e) {
      _error = 'Failed to load members';
      debugPrint('fetchMembersByClassification error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// iOS: GetClubs — fetch district clubs.
  /// API: District/GetClubs (POST)
  Future<void> fetchDistrictClubs({required String groupId}) async {
    _isLoading = true;
    _error = null;
    _clubSearchQuery = '';
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.districtGetClubs,
        body: {
          'groupId': groupId,
          'search': '',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = TBDistrictClubListResult.fromJson(
            jsonData['ClubListResult'] as Map<String, dynamic>? ?? jsonData);
        if (result.isSuccess) {
          _clubs = result.clubs ?? [];
          _filteredClubs = _clubs;
        } else {
          _error = result.message ?? 'No clubs found';
        }
      } else {
        _error = 'Server error';
      }
    } catch (e) {
      _error = 'Failed to load district clubs';
      debugPrint('fetchDistrictClubs error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Client-side club search.
  void searchClubs(String query) {
    _clubSearchQuery = query;
    if (query.isEmpty) {
      _filteredClubs = _clubs;
    } else {
      final lower = query.toLowerCase();
      _filteredClubs = _clubs.where((c) {
        final name = c.clubName?.toLowerCase() ?? '';
        return name.contains(lower);
      }).toList();
    }
    notifyListeners();
  }

  /// iOS: GetMemberWithDynamicFields — fetch member detail.
  /// API: District/GetMemberWithDynamicFields (POST)
  Future<void> fetchMemberDetail({
    required String memberProfileId,
    required String groupId,
  }) async {
    _isLoadingDetail = true;
    _memberDetail = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.districtGetMemberWithDynamicFields,
        body: {
          'memberProfileId': memberProfileId,
          'groupId': groupId,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = TBMemberDetailResult.fromJson(
            jsonData['MemberListDetailResult'] as Map<String, dynamic>? ??
                jsonData);
        if (result.isSuccess) {
          _memberDetail = result.detail;
        }
      }
    } catch (e) {
      debugPrint('fetchMemberDetail error: $e');
    }

    _isLoadingDetail = false;
    notifyListeners();
  }

  /// iOS: GetDistrictCommittee — fetch district committee list.
  /// API: District/GetDistrictCommittee (POST)
  Future<List<Map<String, dynamic>>> fetchDistrictCommittee({
    required String groupId,
  }) async {
    try {
      final response = await ApiClient.instance.post(
        ApiConstants.districtGetCommittee,
        body: {'groupId': groupId},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final list = jsonData['CommitteeResult'] as List<dynamic>? ??
            jsonData['committee'] as List<dynamic>? ??
            [];
        return list.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint('fetchDistrictCommittee error: $e');
    }
    return [];
  }
}
