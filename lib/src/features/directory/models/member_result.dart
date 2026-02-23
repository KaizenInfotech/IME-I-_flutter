import '../../../core/models/base_model.dart';

/// Port of iOS TBMemberResult.h — response from Member/GetDirectoryList.
/// Contains paginated member list with total pages and current page.
class TBMemberResult extends BaseModel {
  final String? status;
  final String? message;
  final String? resultCount;
  final String? totalPages;
  final String? currentPage;
  final List<MemberListItem>? memberListResults;

  TBMemberResult({
    this.status,
    this.message,
    this.resultCount,
    this.totalPages,
    this.currentPage,
    this.memberListResults,
  });

  factory TBMemberResult.fromJson(Map<String, dynamic> json) {
    return TBMemberResult(
      status: BaseModel.safeString(json['status']),
      message: BaseModel.safeString(json['message']),
      resultCount: BaseModel.safeString(json['resultCount']),
      totalPages: BaseModel.safeString(json['TotalPages'] ?? json['totalPages']),
      currentPage:
          BaseModel.safeString(json['currentPage'] ?? json['CurrentPage']),
      memberListResults: BaseModel.safeList(
        json['MemberListResults'] ?? json['memberListResults'],
        MemberListItem.fromJson,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'resultCount': resultCount,
        'TotalPages': totalPages,
        'currentPage': currentPage,
        'MemberListResults':
            memberListResults?.map((e) => e.toJson()).toList(),
      };

  bool get isSuccess => status == '0';

  int get totalPagesInt => int.tryParse(totalPages ?? '') ?? 0;
  int get currentPageInt => int.tryParse(currentPage ?? '') ?? 0;
}

/// Port of iOS MemberListDetail.h (ProfileView) — individual member in directory list.
/// iOS cell displays: memberName, memberMobile, profilePic, familyPic.
class MemberListItem extends BaseModel {
  final String? masterID;
  final String? masterId;
  final String? grpID;
  final String? profileID;
  final String? profileId;
  final String? isAdmin;
  final String? memberName;
  final String? memberEmail;
  final String? memberMobile;
  final String? memberCountry;
  final String? profilePic;
  final String? familyPic;
  final String? designation;
  final String? companyName;
  final String? bloodGroup;
  final String? countryCode;

  MemberListItem({
    this.masterID,
    this.masterId,
    this.grpID,
    this.profileID,
    this.profileId,
    this.isAdmin,
    this.memberName,
    this.memberEmail,
    this.memberMobile,
    this.memberCountry,
    this.profilePic,
    this.familyPic,
    this.designation,
    this.companyName,
    this.bloodGroup,
    this.countryCode,
  });

  factory MemberListItem.fromJson(Map<String, dynamic> json) {
    return MemberListItem(
      masterID: BaseModel.safeString(json['masterID'] ?? json['MasterID']),
      masterId: BaseModel.safeString(json['masterId'] ?? json['MasterId']),
      grpID: BaseModel.safeString(json['grpID'] ?? json['GrpID']),
      profileID: BaseModel.safeString(json['profileID'] ?? json['ProfileID']),
      profileId: BaseModel.safeString(json['profileId'] ?? json['ProfileId']),
      isAdmin: BaseModel.safeString(json['isAdmin']),
      memberName: BaseModel.safeString(json['memberName']),
      memberEmail:
          BaseModel.safeString(json['memberEmail'] ?? json['memberEmailId']),
      memberMobile: BaseModel.safeString(json['memberMobile'] ?? json['mobileNo']),
      memberCountry: BaseModel.safeString(json['memberCountry']),
      profilePic: BaseModel.safeString(
          json['profilePic'] ?? json['profilePicPath'] ?? json['ProfilePicPath']),
      familyPic: BaseModel.safeString(json['familyPic']),
      designation: BaseModel.safeString(json['designation']),
      companyName: BaseModel.safeString(json['companyName']),
      bloodGroup: BaseModel.safeString(json['bloodGroup']),
      countryCode: BaseModel.safeString(json['countryCode']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'masterID': masterID,
        'masterId': masterId,
        'grpID': grpID,
        'profileID': profileID,
        'profileId': profileId,
        'isAdmin': isAdmin,
        'memberName': memberName,
        'memberEmail': memberEmail,
        'memberMobile': memberMobile,
        'memberCountry': memberCountry,
        'profilePic': profilePic,
        'familyPic': familyPic,
        'designation': designation,
        'companyName': companyName,
        'bloodGroup': bloodGroup,
        'countryCode': countryCode,
      };

  /// Effective profile ID — tries both key variations.
  String? get effectiveProfileId => profileId ?? profileID;

  /// Effective master ID — tries both key variations.
  String? get effectiveMasterId => masterId ?? masterID;

  /// Check if member is admin.
  bool get isMemberAdmin =>
      isAdmin?.toLowerCase() == 'yes' || isAdmin?.toLowerCase() == 'true';

  /// Check if profile picture is valid (not empty/placeholder).
  bool get hasValidProfilePic =>
      profilePic != null &&
      profilePic!.isNotEmpty &&
      profilePic != 'profile_photo.png';
}
