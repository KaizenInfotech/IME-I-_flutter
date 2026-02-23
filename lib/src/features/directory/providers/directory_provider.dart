import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/member_detail_result.dart';
import '../models/member_result.dart';
import '../models/user_result.dart';

/// Directory state management — port of iOS DirectoryViewController logic.
/// Handles member listing with search, pagination, and profile CRUD.
class DirectoryProvider extends ChangeNotifier {
  // ─── STATE ─────────────────────────────────────────────

  List<MemberListItem> _members = [];
  List<MemberListItem> get members => _members;

  MemberDetail? _selectedMember;
  MemberDetail? get selectedMember => _selectedMember;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  String? _error;
  String? get error => _error;

  String _searchText = '';
  String get searchText => _searchText;

  int _currentPage = 1;
  int get currentPage => _currentPage;

  int _totalPages = 1;
  int get totalPages => _totalPages;

  String _resultCount = '0';
  String get resultCount => _resultCount;

  bool get hasMorePages => _currentPage < _totalPages;

  // ─── FETCH DIRECTORY LIST ──────────────────────────────
  // iOS: getDirectoryListGroupsOFUSer(masterUID, grpID, searchText, page)
  // → POST Member/GetDirectoryList
  Future<bool> fetchDirectory({
    required String masterUID,
    required String grpID,
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
    _searchText = searchText;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.memberGetDirectoryList,
        body: {
          'masterUID': masterUID,
          'grpID': grpID,
          'searchText': searchText,
          'page': page.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = _parseResponseBody(response.body);
        if (data != null) {
          final result = TBMemberResult.fromJson(data);
          if (result.isSuccess) {
            _currentPage = result.currentPageInt;
            _totalPages = result.totalPagesInt;
            _resultCount = result.resultCount ?? '0';

            if (page == 1) {
              _members = result.memberListResults ?? [];
            } else {
              // iOS: append to mainArray on scroll pagination
              _members.addAll(result.memberListResults ?? []);
            }

            _isLoading = false;
            _isLoadingMore = false;
            notifyListeners();
            return true;
          } else {
            _error = result.message ?? 'Failed to fetch directory';
          }
        } else {
          _error = 'Invalid response';
        }
      } else {
        _error = _parseErrorMessage(response.body) ?? 'Server error';
      }
    } catch (e) {
      _error = 'Network error: $e';
      debugPrint('DirectoryProvider.fetchDirectory error: $e');
    }

    _isLoading = false;
    _isLoadingMore = false;
    notifyListeners();
    return false;
  }

  // ─── LOAD MORE (PAGINATION) ────────────────────────────
  // iOS: scrollViewDidEndDragging triggers next page fetch
  Future<bool> loadMoreMembers({
    required String masterUID,
    required String grpID,
  }) async {
    if (!hasMorePages || _isLoadingMore) return false;
    return fetchDirectory(
      masterUID: masterUID,
      grpID: grpID,
      searchText: _searchText,
      page: _currentPage + 1,
    );
  }

  // ─── SEARCH MEMBERS ────────────────────────────────────
  // iOS: searchBarSearchButtonClicked → fetchDataFORClubName(searchText)
  Future<bool> searchMembers({
    required String masterUID,
    required String grpID,
    required String query,
  }) async {
    _searchText = query;
    _currentPage = 1;
    return fetchDirectory(
      masterUID: masterUID,
      grpID: grpID,
      searchText: query,
      page: 1,
    );
  }

  // ─── GET MEMBER DETAIL ─────────────────────────────────
  // iOS: getMemberDetail(memberProfID, grpID)
  // → POST Member/GetMember
  Future<bool> getMemberDetail({
    required String memberProfileId,
    required String groupId,
  }) async {
    _isLoading = true;
    _error = null;
    _selectedMember = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.memberGetMember,
        body: {
          'memberProfileId': memberProfileId,
          'groupId': groupId,
        },
      );

      if (response.statusCode == 200) {
        final data = _parseResponseBody(response.body);
        if (data != null) {
          final result = MemberListDetailResult.fromJson(data);
          if (result.isSuccess) {
            _selectedMember = result.firstMember;
            _isLoading = false;
            notifyListeners();
            return true;
          } else {
            _error = result.message ?? 'Failed to fetch member details';
          }
        } else {
          _error = 'Invalid response';
        }
      } else {
        _error = _parseErrorMessage(response.body) ?? 'Server error';
      }
    } catch (e) {
      _error = 'Network error: $e';
      debugPrint('DirectoryProvider.getMemberDetail error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ─── UPDATE PROFILE ────────────────────────────────────
  // iOS: UpdateMemberDetail(memberUUID, memberMobile, memberName, memberEmailID, ProfilePicPath, ImageId)
  // → POST Member/UpdateProfile
  Future<bool> updateProfile({
    required String profileId,
    required String memberMobile,
    required String memberName,
    required String memberEmailId,
    String profilePicPath = '',
    String imageId = '',
  }) async {
    try {
      final response = await ApiClient.instance.post(
        ApiConstants.memberUpdateProfile,
        body: {
          'ProfileId': profileId,
          'memberMobile': memberMobile,
          'memberName': memberName,
          'memberEmailid': memberEmailId,
          'ProfilePicPath': profilePicPath,
          'ImageId': imageId,
        },
      );

      if (response.statusCode == 200) {
        final data = _parseResponseBody(response.body);
        if (data != null) {
          final result = UserResult.fromJson(data);
          return result.isSuccess;
        }
      }
    } catch (e) {
      debugPrint('DirectoryProvider.updateProfile error: $e');
    }
    return false;
  }

  // ─── UPDATE PERSONAL DETAILS ───────────────────────────
  // iOS: updatepersonalProfile(profileID, key)
  // → POST Member/UpdateProfilePersonalDetails
  Future<bool> updatePersonalDetails({
    required String profileId,
    required List<Map<String, String>> keyValuePairs,
  }) async {
    try {
      final keyJson = json.encode(keyValuePairs);
      final response = await ApiClient.instance.post(
        ApiConstants.memberUpdateProfilePersonalDetails,
        body: {
          'profileID': profileId,
          'key': keyJson,
        },
      );

      if (response.statusCode == 200) {
        final data = _parseResponseBody(response.body);
        if (data != null) {
          final result = UserResult.fromJson(data);
          return result.isSuccess;
        }
      }
    } catch (e) {
      debugPrint('DirectoryProvider.updatePersonalDetails error: $e');
    }
    return false;
  }

  // ─── UPDATE ADDRESS ────────────────────────────────────
  // iOS: getAddAddressToProfile(addressID, addressType, address, city, state, country, pincode, phoneNo, fax, profileID, groupID)
  // → POST Member/UpdateAddressDetails
  Future<bool> updateAddress({
    required String addressID,
    required String addressType,
    required String address,
    required String city,
    required String state,
    required String country,
    required String pincode,
    required String phoneNo,
    required String fax,
    required String profileID,
    required String groupID,
  }) async {
    try {
      final response = await ApiClient.instance.post(
        ApiConstants.memberUpdateAddressDetails,
        body: {
          'addressID': addressID,
          'addressType': addressType,
          'address': address,
          'city': city,
          'state': state,
          'country': country,
          'pincode': pincode,
          'phoneNo': phoneNo,
          'fax': fax,
          'profileID': profileID,
          'groupID': groupID,
        },
      );

      if (response.statusCode == 200) {
        final data = _parseResponseBody(response.body);
        if (data != null) {
          final result = UpdateAddressResult.fromJson(data);
          return result.isSuccess;
        }
      }
    } catch (e) {
      debugPrint('DirectoryProvider.updateAddress error: $e');
    }
    return false;
  }

  // ─── UPDATE FAMILY DETAILS ─────────────────────────────
  // iOS: getAddFamilyMembersToProfile(familyMemberId, memberName, relationship, dOB, anniversary, contactNo, particulars, bloodGroup, profileId, emailID)
  // → POST Member/UpdateFamilyDetails
  Future<bool> updateFamilyDetails({
    required String familyMemberId,
    required String memberName,
    required String relationship,
    required String dOB,
    required String anniversary,
    required String contactNo,
    required String particulars,
    required String bloodGroup,
    required String profileId,
    required String emailID,
  }) async {
    try {
      final response = await ApiClient.instance.post(
        ApiConstants.memberUpdateFamilyDetails,
        body: {
          'familyMemberId': familyMemberId,
          'memberName': memberName,
          'relationship': relationship,
          'dOB': dOB,
          'anniversary': anniversary,
          'contactNo': contactNo,
          'particulars': particulars,
          'profileId': profileId,
          'emailID': emailID,
          'bloodGroup': bloodGroup,
        },
      );

      if (response.statusCode == 200) {
        final data = _parseResponseBody(response.body);
        if (data != null) {
          final result = UpdateFamilyResult.fromJson(data);
          return result.isSuccess;
        }
      }
    } catch (e) {
      debugPrint('DirectoryProvider.updateFamilyDetails error: $e');
    }
    return false;
  }

  // ─── CLEAR STATE ───────────────────────────────────────
  void clear() {
    _members = [];
    _selectedMember = null;
    _isLoading = false;
    _isLoadingMore = false;
    _error = null;
    _searchText = '';
    _currentPage = 1;
    _totalPages = 1;
    _resultCount = '0';
    notifyListeners();
  }

  void clearSelectedMember() {
    _selectedMember = null;
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
