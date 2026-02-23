import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/bod_member_result.dart';
import '../models/update_address_result.dart';
import '../models/update_family_result.dart';

/// Replaces iOS CommonAccessibleHoldVariable shared mutable state with
/// Provider state. Handles all profile, family, address, BOD, past-president
/// and change-request APIs.
class ProfileProvider extends ChangeNotifier {
  // ─── Loading / Error State ───────────────────────────────
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // ─── Member Profile (DashProfileViewController) ────────
  Map<String, dynamic>? _memberProfile;
  Map<String, dynamic>? get memberProfile => _memberProfile;

  bool _isLoadingProfile = false;
  bool get isLoadingProfile => _isLoadingProfile;

  /// iOS: DashProfileViewController.getRequest() / GetUserdetails()
  /// API: Member/GetMemberDetails (GET)
  /// Params: MemProfileId, GrpID
  Future<void> fetchMemberProfile({
    required String profileId,
    required String groupId,
  }) async {
    _isLoadingProfile = true;
    _error = null;
    // Don't clear _memberProfile — keep old data visible while refreshing.
    // Matches Android: ProgressDialog overlay, content stays visible.
    notifyListeners();

    try {
      final response = await ApiClient.instance.get(
        ApiConstants.memberGetMemberDetails,
        queryParams: {
          'MemProfileId': profileId,
          'GrpID': groupId,
        },
        additionalHeaders: {
          'MemProfileId': profileId,
          'GrpID': groupId,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        // iOS: TBGetSponsorReferredResult.Result.Table[0]
        final result = data['TBGetSponsorReferredResult'] ??
            data['tbGetSponsorReferredResult'];
        if (result is Map<String, dynamic>) {
          final resultData = result['Result'] ?? result['result'];
          if (resultData is Map<String, dynamic>) {
            final table = resultData['Table'] ?? resultData['table'];
            if (table is List && table.isNotEmpty) {
              _memberProfile = table[0] as Map<String, dynamic>;
            }
          }
        }
      }
    } catch (e) {
      _error = 'Failed to load profile';
      debugPrint('fetchMemberProfile error: $e');
    }

    _isLoadingProfile = false;
    notifyListeners();
  }

  // ─── BOD Members ─────────────────────────────────────────
  List<BodMember> _bodMembers = [];
  List<BodMember> get bodMembers => _bodMembers;

  bool _isLoadingBod = false;
  bool get isLoadingBod => _isLoadingBod;

  // ─── Past Presidents ─────────────────────────────────────
  List<PastPresident> _pastPresidents = [];
  List<PastPresident> get pastPresidents => _pastPresidents;

  bool _isLoadingPastPresidents = false;
  bool get isLoadingPastPresidents => _isLoadingPastPresidents;

  // ─── Change Request ──────────────────────────────────────
  List<CategoryItem> _categories = [];
  List<CategoryItem> get categories => _categories;

  bool _isLoadingCategories = false;
  bool get isLoadingCategories => _isLoadingCategories;

  // ─── Fetch BOD List ──────────────────────────────────────
  /// Android: ExecutiveCommitteeActivity — POST Member/GetBODList
  /// Params: grpId, searchText, YearFilter (empty string)
  Future<void> fetchBodList({
    required String groupId,
    String searchText = '',
    String yearFilter = '',
  }) async {
    _isLoadingBod = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.memberGetBodList,
        body: {
          'grpId': groupId,
          'searchText': searchText,
          'YearFilter': yearFilter,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = TBBodListResult.fromJson(jsonData);

        if (result.status == '0') {
          _bodMembers = result.members ?? [];
        } else {
          _bodMembers = [];
        }
      } else {
        _error = 'Something went wrong, Please try again later';
      }
    } catch (e) {
      _error = 'Something went wrong, Please try again later';
      debugPrint('fetchBodList error: $e');
    }

    _isLoadingBod = false;
    notifyListeners();
  }

  // ─── Fetch Past Presidents ───────────────────────────────
  /// iOS: PastPresidentListViewController.functionForGetPastPresidentList()
  /// API: PastPresidents/getPastPresidentsList
  /// Params: GroupId (dynamic), SearchText (empty), updateOn (static "1970/01/01 00:00:00")
  Future<void> fetchPastPresidents({
    required String groupId,
  }) async {
    _isLoadingPastPresidents = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.pastPresidentsGetList,
        body: {
          'GroupId': groupId,
          'SearchText': '',
          'updateOn': '1970/01/01 00:00:00',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = TBPastPresidentsResult.fromJson(jsonData);

        if (result.status == '0') {
          _pastPresidents = result.presidents ?? [];
        } else {
          _pastPresidents = [];
        }
      } else {
        _error = 'Something went wrong, Please try again later';
      }
    } catch (e) {
      _error = 'Something went wrong, Please try again later';
      debugPrint('fetchPastPresidents error: $e');
    }

    _isLoadingPastPresidents = false;
    notifyListeners();
  }

  // ─── Update Family Details ───────────────────────────────
  /// iOS: wsm.updateFamilyDetails(...)
  /// API: Member/UpdateFamilyDetails
  Future<bool> updateFamilyDetails({
    required String familyMemberId,
    required String memberName,
    required String relationship,
    required String dob,
    required String anniversary,
    required String contactNo,
    required String particulars,
    required String profileId,
    required String emailId,
    required String bloodGroup,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.memberUpdateFamilyDetails,
        body: {
          'familyMemberId': familyMemberId,
          'memberName': memberName,
          'relationship': relationship,
          'dOB': dob,
          'anniversary': anniversary,
          'contactNo': contactNo,
          'particulars': particulars,
          'profileId': profileId,
          'emailID': emailId,
          'bloodGroup': bloodGroup,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = UpdateFamilyResult.fromJson(jsonData);
        _isLoading = false;
        notifyListeners();
        return result.isSuccess;
      }
    } catch (e) {
      debugPrint('updateFamilyDetails error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ─── Update Address Details ──────────────────────────────
  /// iOS: wsm.updateAddressDetails(...)
  /// API: Member/UpdateAddressDetails
  Future<bool> updateAddressDetails({
    required String addressId,
    required String addressType,
    required String address,
    required String city,
    required String state,
    required String country,
    required String pincode,
    required String phoneNo,
    required String fax,
    required String profileId,
    required String groupId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.memberUpdateAddressDetails,
        body: {
          'addressID': addressId,
          'addressType': addressType,
          'address': address,
          'city': city,
          'state': state,
          'country': country,
          'pincode': pincode,
          'phoneNo': phoneNo,
          'fax': fax,
          'profileID': profileId,
          'groupID': groupId,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = UpdateAddressResult.fromJson(jsonData);
        _isLoading = false;
        notifyListeners();
        return result.isSuccess;
      }
    } catch (e) {
      debugPrint('updateAddressDetails error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ─── Update Profile Personal Details ─────────────────────
  /// iOS: wsm.updateProfileDetails(key, profileID)
  /// API: member/UpdateProfilePersonalDetails
  Future<bool> updateProfilePersonalDetails({
    required String profileId,
    required List<Map<String, String>> keyValuePairs,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final keyJson = json.encode(keyValuePairs);
      final response = await ApiClient.instance.post(
        ApiConstants.memberUpdateProfileDetails,
        body: {
          'key': keyJson,
          'profileID': profileId,
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
      debugPrint('updateProfilePersonalDetails error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ─── Fetch Category List (Change Request) ────────────────
  /// iOS: wsm.getCategoryList()
  /// API: FindRotarian/GetCategoryList
  Future<void> fetchCategories() async {
    _isLoadingCategories = true;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.findRotarianGetCategoryList,
        body: {},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = TBCategoryListResult.fromJson(jsonData);
        _categories = result.categories ?? [];
      }
    } catch (e) {
      debugPrint('fetchCategories error: $e');
    }

    _isLoadingCategories = false;
    notifyListeners();
  }

  // ─── Submit Change Request ───────────────────────────────
  /// iOS: wsm.SaveProfile(MemberId, remark, Category)
  /// API: Member/Saveprofile
  Future<bool> submitChangeRequest({
    required String memberId,
    required String remark,
    required String categoryId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.memberSaveProfile,
        body: {
          'MemberId': memberId,
          'remark': remark,
          'Category': categoryId,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = SaveProfileResult.fromJson(jsonData);
        _isLoading = false;
        notifyListeners();
        return result.isSuccess;
      }
    } catch (e) {
      debugPrint('submitChangeRequest error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ─── Update Member Toggles (Hide/Show + Company Name) ─────
  /// iOS: DashProfileViewController.updateMember()
  /// API: Member/UpdateMemebr (POST, URLEncoding)
  /// Params: mobile_num_hide, secondary_num_hide, email_hide, DOB, DOA,
  ///         company_name, MemProfileId
  Future<bool> updateMemberToggles({
    required String profileId,
    required int mobileNumHide,
    required int secondaryNumHide,
    required int emailHide,
    required String dob,
    required String doa,
    required String companyName,
  }) async {
    try {
      final response = await ApiClient.instance.post(
        ApiConstants.memberUpdateMember,
        body: {
          'mobile_num_hide': mobileNumHide.toString(),
          'secondary_num_hide': secondaryNumHide.toString(),
          'email_hide': emailHide.toString(),
          'DOB': dob,
          'DOA': doa,
          'company_name': companyName,
          'MemProfileId': profileId,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final status = jsonData['status']?.toString();
        return status == '0';
      }
    } catch (e) {
      debugPrint('updateMemberToggles error: $e');
    }
    return false;
  }

  // ─── Upload Profile Photo ─────────────────────────────
  /// iOS: DashProfileViewController — multipart upload
  /// API: Member/UploadProfilePhoto?ProfileID=&GrpID=&Type=profile
  /// Multipart field: profile_image (image.jpg, image/jpg, quality 0.7)
  /// Response: { UploadImageResult: { Imagepath: "..." } }
  Future<String?> uploadProfilePhoto({
    required String profileId,
    required String groupId,
    required List<int> imageBytes,
    String filename = 'image.jpg',
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final uri = Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.memberUploadProfilePhoto}'
          '?ProfileID=$profileId&GrpID=$groupId&Type=profile');

      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ=='
        ..fields['ProfileID'] = profileId
        ..fields['GrpID'] = groupId
        ..fields['Type'] = 'profile'
        ..files.add(http.MultipartFile.fromBytes(
          'profile_image',
          imageBytes,
          filename: filename,
        ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        // iOS: UploadImageResult.Imagepath
        final uploadResult =
            jsonData['UploadImageResult'] as Map<String, dynamic>?;
        final imagePath = uploadResult?['Imagepath']?.toString();
        _isLoading = false;
        notifyListeners();
        return imagePath;
      }
    } catch (e) {
      debugPrint('uploadProfilePhoto error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return null;
  }

  // ─── Get Updated Profile Details ──────────────────────
  /// iOS: wsm.getUpdatedMemberProfileDetails(...)
  /// API: Member/GetUpdatedmemberProfileDetails
  Future<Map<String, dynamic>?> getUpdatedProfileDetails({
    required String profileId,
    required String groupId,
  }) async {
    try {
      final response = await ApiClient.instance.post(
        ApiConstants.memberGetUpdatedProfileDetails,
        body: {
          'profileId': profileId,
          'groupId': groupId,
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('getUpdatedProfileDetails error: $e');
    }
    return null;
  }
}
