import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/country_result.dart';
import '../models/create_group_result.dart';
import '../models/entity_info_result.dart';
import '../models/global_search_result.dart';

/// Groups state management — port of iOS group CRUD, member add,
/// global search, entity info, and feedback logic.
class GroupsProvider extends ChangeNotifier {
  // ─── Loading / Error State ───────────────────────────────
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // ─── Countries & Categories ──────────────────────────────
  List<CountryItem> _countries = [];
  List<CountryItem> get countries => _countries;

  List<CategoryItem> _categories = [];
  List<CategoryItem> get categories => _categories;

  // ─── Group Detail ────────────────────────────────────────
  GroupDetailItem? _groupDetail;
  GroupDetailItem? get groupDetail => _groupDetail;

  bool _isLoadingDetail = false;
  bool get isLoadingDetail => _isLoadingDetail;

  // ─── Entity Info ─────────────────────────────────────────
  TBEntityInfoResult? _entityInfo;
  TBEntityInfoResult? get entityInfo => _entityInfo;

  bool _isLoadingEntity = false;
  bool get isLoadingEntity => _isLoadingEntity;

  // ─── Global Search ───────────────────────────────────────
  TBGlobalSearchGroupResult? _searchResult;
  TBGlobalSearchGroupResult? get searchResult => _searchResult;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  // ─── Fetch Countries & Categories ────────────────────────
  /// iOS: wsm.getCountryAndCategories()
  /// API: Group/GetAllCountriesAndCategories
  Future<void> fetchCountriesAndCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.groupGetAllCountriesAndCategories,
        body: {},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = TBCountryResult.fromJson(jsonData);

        if (result.status == '0') {
          _countries = result.countries ?? [];
          _categories = result.categories ?? [];
        }
      }
    } catch (e) {
      debugPrint('fetchCountriesAndCategories error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ─── Create Group ────────────────────────────────────────
  /// iOS: wsm.createGroup(...)
  /// API: Group/CreateGroup
  Future<CreateGroupResult?> createGroup({
    required String grpName,
    required String grpType,
    required String grpCategory,
    required String userId,
    String grpId = '0',
    String grpImageId = '',
    String address1 = '',
    String address2 = '',
    String city = '',
    String state = '',
    String pincode = '',
    String country = '',
    String email = '',
    String mobile = '',
    String website = '',
    String other = '',
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.groupCreateGroup,
        body: {
          'grpId': grpId,
          'grpName': grpName,
          'grpImageID': grpImageId,
          'grpType': grpType,
          'grpCategory': grpCategory,
          'addrss1': address1,
          'addrss2': address2,
          'city': city,
          'state': state,
          'pincode': pincode,
          'country': country,
          'emailid': email,
          'mobile': mobile,
          'userId': userId,
          'website': website,
          'other': other,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = CreateGroupResult.fromJson(jsonData);
        _isLoading = false;
        notifyListeners();
        return result;
      }
    } catch (e) {
      debugPrint('createGroup error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return null;
  }

  // ─── Fetch Group Detail ──────────────────────────────────
  /// iOS: wsm.getGroupInfoDetail(memberUID, grpID)
  /// API: Group/GetGroupDetail
  Future<void> fetchGroupDetail({
    required String memberMainId,
    required String groupId,
  }) async {
    _isLoadingDetail = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.groupGetGroupDetail,
        body: {
          'memberMainId': memberMainId,
          'groupId': groupId,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = TBGetGroupDetailResult.fromJson(jsonData);

        if (result.status == '0' &&
            result.details != null &&
            result.details!.isNotEmpty) {
          _groupDetail = result.details!.first;
        } else {
          _groupDetail = null;
        }
      } else {
        _error = 'Something went wrong, Please try again later';
      }
    } catch (e) {
      _error = 'Something went wrong, Please try again later';
      debugPrint('fetchGroupDetail error: $e');
    }

    _isLoadingDetail = false;
    notifyListeners();
  }

  // ─── Add Member To Group ─────────────────────────────────
  /// iOS: wsm.getAddMembersToGroup(mobile, userName, groupId, masterID,
  ///       countryId, memberEmail)
  /// API: Group/AddMemberToGroup
  Future<AddMemberGroupResult?> addMemberToGroup({
    required String mobile,
    required String userName,
    required String groupId,
    required String masterId,
    required String countryId,
    String memberEmail = '',
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.groupAddMemberToGroup,
        body: {
          'mobile': mobile,
          'userName': userName,
          'groupId': groupId,
          'masterID': masterId,
          'countryId': countryId,
          'memberEmail': memberEmail,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = AddMemberGroupResult.fromJson(jsonData);
        _isLoading = false;
        notifyListeners();
        return result;
      }
    } catch (e) {
      debugPrint('addMemberToGroup error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return null;
  }

  // ─── Add Multiple Members To Group ───────────────────────
  /// iOS: wsm.getAddMultipleMembersToGroup(...)
  /// API: Group/AddMultipleMemberToGroup
  Future<bool> addMultipleMembers({
    required String groupId,
    required String masterId,
    required String memberData,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.groupAddMultipleMemberToGroup,
        body: {
          'groupId': groupId,
          'masterID': masterId,
          'memberData': memberData,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final status = jsonData['status']?.toString();
        _isLoading = false;
        notifyListeners();
        return status == '0';
      }
    } catch (e) {
      debugPrint('addMultipleMembers error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ─── Global Search Group ─────────────────────────────────
  /// iOS: wsm.getGlobalSearchDetail(memId, otherMemId)
  /// API: Group/GlobalSearchGroup
  Future<void> globalSearchGroup({
    required String memId,
    required String otherMemId,
  }) async {
    _isSearching = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.groupGlobalSearchGroup,
        body: {
          'memId': memId,
          'otherMemId': otherMemId,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        _searchResult = TBGlobalSearchGroupResult.fromJson(jsonData);
      } else {
        _error = 'Something went wrong, Please try again later';
      }
    } catch (e) {
      _error = 'Something went wrong, Please try again later';
      debugPrint('globalSearchGroup error: $e');
    }

    _isSearching = false;
    notifyListeners();
  }

  // ─── Delete By Module Name ───────────────────────────────
  /// iOS: wsm.deleteByModuleName(...)
  /// API: Group/DeleteByModuleName
  Future<bool> deleteByModuleName({
    required String groupId,
    required String moduleName,
    required String moduleId,
  }) async {
    try {
      final response = await ApiClient.instance.post(
        ApiConstants.groupDeleteByModuleName,
        body: {
          'groupId': groupId,
          'moduleName': moduleName,
          'moduleId': moduleId,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return jsonData['status']?.toString() == '0';
      }
    } catch (e) {
      debugPrint('deleteByModuleName error: $e');
    }
    return false;
  }

  // ─── Remove Group Category ───────────────────────────────
  /// iOS: wsm.removeGroupsOFUSer(memberProfileId, memberMainId)
  /// API: Group/RemoveGroupCategory
  Future<bool> removeGroupCategory({
    required String memberProfileId,
    required String memberMainId,
  }) async {
    try {
      final response = await ApiClient.instance.post(
        ApiConstants.groupRemoveGroupCategory,
        body: {
          'memberProfileId': memberProfileId,
          'memberMainId': memberMainId,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return jsonData['status']?.toString() == '0';
      }
    } catch (e) {
      debugPrint('removeGroupCategory error: $e');
    }
    return false;
  }

  // ─── Update Member Group Category ────────────────────────
  /// iOS: wsm.updateGroupsOFUSer(memberProfileId, mycategory, memberMainId)
  /// API: Group/UpdateMemberGroupCategory
  Future<bool> updateMemberGroupCategory({
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
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return jsonData['status']?.toString() == '0';
      }
    } catch (e) {
      debugPrint('updateMemberGroupCategory error: $e');
    }
    return false;
  }

  // ─── Fetch Entity Info ───────────────────────────────────
  /// iOS: wsm.getEntityInfoList(grpID, moduleID)
  /// API: Group/GetEntityInfo
  Future<void> fetchEntityInfo({
    required String groupId,
    required String moduleId,
  }) async {
    _isLoadingEntity = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.groupGetEntityInfo,
        body: {
          'grpID': groupId,
          'moduleID': moduleId,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        _entityInfo = TBEntityInfoResult.fromJson(jsonData);
      } else {
        _error = 'Something went wrong, Please try again later';
      }
    } catch (e) {
      _error = 'Something went wrong, Please try again later';
      debugPrint('fetchEntityInfo error: $e');
    }

    _isLoadingEntity = false;
    notifyListeners();
  }

  // ─── Fetch Club Details ──────────────────────────────────
  /// iOS: wsm.getClubDetails(...)
  /// API: Group/GetClubDetails
  Future<Map<String, dynamic>?> fetchClubDetails({
    required String groupId,
  }) async {
    try {
      final response = await ApiClient.instance.post(
        ApiConstants.groupGetClubDetails,
        body: {'groupId': groupId},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('fetchClubDetails error: $e');
    }
    return null;
  }

  // ─── Fetch Club History ──────────────────────────────────
  /// iOS: wsm.getClubHistory(...)
  /// API: Group/GetClubHistory
  Future<Map<String, dynamic>?> fetchClubHistory({
    required String groupId,
  }) async {
    try {
      final response = await ApiClient.instance.post(
        ApiConstants.groupGetClubHistory,
        body: {'groupId': groupId},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('fetchClubHistory error: $e');
    }
    return null;
  }

  // ─── Delete Image ──────────────────────────────────────
  /// iOS: wsm.deleteImage(...)
  /// API: Group/DeleteImage
  Future<bool> deleteImage({
    required String groupId,
    required String imageId,
  }) async {
    try {
      final response = await ApiClient.instance.post(
        ApiConstants.groupDeleteImage,
        body: {
          'groupId': groupId,
          'imageId': imageId,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return jsonData['status']?.toString() == '0';
      }
    } catch (e) {
      debugPrint('deleteImage error: $e');
    }
    return false;
  }

  // ─── Get Email ────────────────────────────────────────
  /// iOS: wsm.getEmail(...)
  /// API: Group/GetEmail
  Future<String?> getEmail({
    required String groupId,
    required String profileId,
  }) async {
    try {
      final response = await ApiClient.instance.post(
        ApiConstants.groupGetEmail,
        body: {
          'groupId': groupId,
          'profileId': profileId,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return jsonData['email']?.toString();
      }
    } catch (e) {
      debugPrint('getEmail error: $e');
    }
    return null;
  }

  // ─── Get Rotary Library Data ──────────────────────────
  /// iOS: wsm.getRotaryLibraryData(...)
  /// API: Group/GetRotaryLibraryData
  Future<Map<String, dynamic>?> getRotaryLibraryData({
    required String groupId,
  }) async {
    try {
      final response = await ApiClient.instance.post(
        ApiConstants.groupGetRotaryLibraryData,
        body: {'groupId': groupId},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('getRotaryLibraryData error: $e');
    }
    return null;
  }

  // ─── Get Mobile Popup ─────────────────────────────────
  /// iOS: wsm.getMobilePopup(...)
  /// API: Group/getMobilePupup
  Future<Map<String, dynamic>?> getMobilePopup({
    required String groupId,
    required String profileId,
  }) async {
    try {
      final response = await ApiClient.instance.post(
        ApiConstants.groupGetMobilePupup,
        body: {
          'groupId': groupId,
          'profileId': profileId,
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('getMobilePopup error: $e');
    }
    return null;
  }

  // ─── Update Mobile Popup Flag ─────────────────────────
  /// iOS: wsm.updateMobilePopupFlag(...)
  /// API: Group/UpdateMobilePupupflag
  Future<bool> updateMobilePopupFlag({
    required String groupId,
    required String profileId,
    required String popupId,
  }) async {
    try {
      final response = await ApiClient.instance.post(
        ApiConstants.groupUpdateMobilePupupFlag,
        body: {
          'groupId': groupId,
          'profileId': profileId,
          'popupId': popupId,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return jsonData['status']?.toString() == '0';
      }
    } catch (e) {
      debugPrint('updateMobilePopupFlag error: $e');
    }
    return false;
  }

  // ─── Submit Feedback ─────────────────────────────────────
  /// iOS: wsm.feedback(...)
  /// API: Group/Feedback
  Future<bool> submitFeedback({
    required String groupId,
    required String profileId,
    required String feedback,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.groupFeedback,
        body: {
          'groupId': groupId,
          'profileId': profileId,
          'feedback': feedback,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        _isLoading = false;
        notifyListeners();
        return jsonData['status']?.toString() == '0';
      }
    } catch (e) {
      debugPrint('submitFeedback error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
}
