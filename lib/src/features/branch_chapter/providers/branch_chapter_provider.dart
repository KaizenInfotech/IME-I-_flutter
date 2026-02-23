import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/branch_chapter_result.dart';
import '../models/past_event_result.dart';

/// Provider for Branch & Chapter Committees screen.
/// iOS: Branch_ChaptViewController + BranchMembersViewController.
class BranchChapterProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<BranchItem> _branches = [];
  List<BranchMemberItem> _allMembers = [];

  // Branch members (from Member/GetMemberListSync)
  bool _isLoadingMembers = false;
  String? _membersError;
  List<BranchMemberDetail> _branchMemberDetails = [];
  List<BranchMemberDetail> _filteredMemberDetails = [];
  String _searchQuery = '';

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<BranchItem> get branches => _branches;

  bool get isLoadingMembers => _isLoadingMembers;
  String? get membersError => _membersError;
  List<BranchMemberDetail> get branchMemberDetails =>
      _searchQuery.isEmpty ? _branchMemberDetails : _filteredMemberDetails;

  /// Get office bearers for a specific branch by filtering Table1 data.
  List<BranchMemberItem> getBranchMembers(int groupId) {
    return _allMembers.where((m) => m.groupId == groupId).toList();
  }

  /// iOS: Branch_ChaptViewController.getApi()
  /// POST FindClub/GetClubList with empty params.
  Future<void> fetchBranches() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.findClubGetClubList,
        body: {
          'keyword': '',
          'country': '',
          'meetingDay': '',
          'district': '',
          'stateProvinceCity': '',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = BranchChapterResult.fromJson(jsonData);
        _branches = result.branches;
        _allMembers = result.members;

        if (_branches.isEmpty) {
          _error = 'No branches found';
        }
      } else {
        _error = 'Server error (${response.statusCode})';
      }
    } catch (e, stack) {
      _error = 'Failed to load branches';
      debugPrint('fetchBranches error: $e');
      debugPrint('fetchBranches stack: $stack');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// iOS: BranchMembersViewController — POST Member/GetMemberListSync.
  /// Fetches all members for a specific branch/group.
  Future<void> fetchBranchMemberDetails(String grpId) async {
    _isLoadingMembers = true;
    _membersError = null;
    _branchMemberDetails = [];
    _filteredMemberDetails = [];
    _searchQuery = '';
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.memberGetMemberListSync,
        body: {
          'grpID': grpId,
          'updatedOn': '1970-01-01 00:00:00',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final status = jsonData['status']?.toString();
        final message = jsonData['message']?.toString();

        if (status == '0' && message == 'success') {
          final memberDetail =
              jsonData['MemberDetail'] as Map<String, dynamic>?;
          final newMemberList =
              memberDetail?['NewMemberList'] as List<dynamic>? ?? [];

          _branchMemberDetails = newMemberList
              .map((e) =>
                  BranchMemberDetail.fromJson(e as Map<String, dynamic>))
              .toList();
          _filteredMemberDetails = _branchMemberDetails;
        } else {
          _branchMemberDetails = [];
        }

        if (_branchMemberDetails.isEmpty) {
          _membersError = 'No members found';
        }
      } else {
        _membersError = 'Server error (${response.statusCode})';
      }
    } catch (e, stack) {
      _membersError = 'Failed to load members';
      debugPrint('fetchBranchMemberDetails error: $e');
      debugPrint('fetchBranchMemberDetails stack: $stack');
    }

    _isLoadingMembers = false;
    notifyListeners();
  }

  /// iOS: searchBar filtering by memberName or lastName.
  void searchMembers(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredMemberDetails = _branchMemberDetails;
    } else {
      final lower = query.toLowerCase();
      _filteredMemberDetails = _branchMemberDetails.where((m) {
        final name = m.memberName?.toLowerCase() ?? '';
        final last = m.lastName?.toLowerCase() ?? '';
        final full = m.fullName.toLowerCase();
        return name.contains(lower) ||
            last.contains(lower) ||
            full.contains(lower);
      }).toList();
    }
    notifyListeners();
  }

  // ─── Past Events (iOS: PastEventsViewController) ──────────────

  bool _isLoadingYears = false;
  bool _isLoadingPastEvents = false;
  String? _pastEventsError;
  List<String> _years = [];
  List<PastEventAlbum> _pastEvents = [];
  List<PastEventAlbum> _filteredPastEvents = [];
  String _pastEventsSearch = '';

  bool get isLoadingYears => _isLoadingYears;
  bool get isLoadingPastEvents => _isLoadingPastEvents;
  String? get pastEventsError => _pastEventsError;
  List<String> get years => _years;
  List<PastEventAlbum> get pastEvents =>
      _pastEventsSearch.isEmpty ? _pastEvents : _filteredPastEvents;

  /// iOS: PastEventsViewController.getData() — POST Gallery/Fillyearlist
  Future<void> fetchYearList({required String grpId}) async {
    _isLoadingYears = true;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.galleryFillYearList,
        body: {'grpID': grpId},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = PastEventYearResult.fromJson(jsonData);
        _years = result.years ?? [];
      }
    } catch (e) {
      debugPrint('fetchYearList error: $e');
    }

    _isLoadingYears = false;
    notifyListeners();
  }

  /// iOS: PastEventsViewController.getAPI() — POST Gallery/GetAlbumsList_New
  Future<void> fetchPastEvents({
    required String groupId,
    required String year,
  }) async {
    _isLoadingPastEvents = true;
    _pastEventsError = null;
    _pastEvents = [];
    _filteredPastEvents = [];
    _pastEventsSearch = '';
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.galleryGetAlbumsListNew,
        body: {
          'groupId': groupId,
          'district_id': '2',
          'category_id': '1',
          'year': year,
          'clubid': '',
          'SharType': '0',
          'moduleId': '8',
          'searchText': '',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = PastEventAlbumResult.fromJson(jsonData);
        _pastEvents = result.albums ?? [];
        _filteredPastEvents = _pastEvents;

        if (_pastEvents.isEmpty) {
          _pastEventsError = 'No events found';
        }
      } else {
        _pastEventsError = 'Server error (${response.statusCode})';
      }
    } catch (e) {
      _pastEventsError = 'Failed to load events';
      debugPrint('fetchPastEvents error: $e');
    }

    _isLoadingPastEvents = false;
    notifyListeners();
  }

  /// iOS: PastEventsViewController searchBar filtering by title.
  void searchPastEvents(String query) {
    _pastEventsSearch = query;
    if (query.isEmpty) {
      _filteredPastEvents = _pastEvents;
    } else {
      final lower = query.toLowerCase();
      _filteredPastEvents = _pastEvents
          .where((e) => (e.title?.toLowerCase() ?? '').contains(lower))
          .toList();
    }
    notifyListeners();
  }

  // ─── Past Event Detail Photos ────────────────────────────────

  bool _isLoadingPhotos = false;
  List<PastEventPhoto> _eventPhotos = [];

  bool get isLoadingPhotos => _isLoadingPhotos;
  List<PastEventPhoto> get eventPhotos => _eventPhotos;

  /// iOS: PastEventDetailViewController.getAPI() — POST Gallery/GetAlbumPhotoList_New
  Future<void> fetchPastEventPhotos({
    required String albumId,
    required String year,
    required String groupId,
  }) async {
    _isLoadingPhotos = true;
    _eventPhotos = [];
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.galleryGetAlbumPhotoList,
        body: {
          'albumId': albumId,
          'Financeyear': year,
          'groupId': groupId,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = PastEventPhotoResult.fromJson(jsonData);
        _eventPhotos = result.photos ?? [];
      }
    } catch (e) {
      debugPrint('fetchPastEventPhotos error: $e');
    }

    _isLoadingPhotos = false;
    notifyListeners();
  }
}
