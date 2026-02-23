/// iOS: NewMemberList — member detail from Member/GetMemberListSync.
/// Response: { status, message, MemberDetail: { NewMemberList: [...] } }
class BranchMemberDetail {
  BranchMemberDetail({
    this.masterID,
    this.grpID,
    this.grpName,
    this.profileID,
    this.memberName,
    this.middleName,
    this.lastName,
    this.memberEmail,
    this.hideMail,
    this.memberMobile,
    this.hideWhatsnum,
    this.secondryMobileNo,
    this.hideNum,
    this.memberCountry,
    this.profilePic,
    this.memberDateOfBirth,
    this.memberDateOfWedding,
    this.bloodGroup,
    this.gradeId,
    this.membershipGrade,
    this.category,
    this.categoryId,
    this.memberIMEIID,
    this.companyName,
    this.clubName,
    this.address,
    this.city,
    this.stateId,
    this.stateName,
    this.pincode,
    this.addressResult,
  });

  final String? masterID;
  final String? grpID;
  final String? grpName;
  final String? profileID;
  final String? memberName;
  final String? middleName;
  final String? lastName;
  final String? memberEmail;
  final String? hideMail;
  final String? memberMobile;
  final String? hideWhatsnum;
  final String? secondryMobileNo;
  final String? hideNum;
  final String? memberCountry;
  final String? profilePic;
  final String? memberDateOfBirth;
  final String? memberDateOfWedding;
  final String? bloodGroup;
  final String? gradeId;
  final String? membershipGrade;
  final String? category;
  final String? categoryId;
  final String? memberIMEIID;
  final String? companyName;
  final String? clubName;
  final String? address;
  final String? city;
  final String? stateId;
  final String? stateName;
  final String? pincode;
  final String? addressResult;

  /// iOS: cell.memberName.text = data.memberName + " " + data.middleName + " " + data.lastName
  String get fullName {
    final parts = <String>[];
    if (memberName != null && memberName!.isNotEmpty) parts.add(memberName!);
    if (middleName != null && middleName!.isNotEmpty) parts.add(middleName!);
    if (lastName != null && lastName!.isNotEmpty) parts.add(lastName!);
    return parts.join(' ');
  }

  String get fullAddress {
    final parts = <String>[];
    if (address != null && address!.isNotEmpty) parts.add(address!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (stateName != null && stateName!.isNotEmpty) parts.add(stateName!);
    if (pincode != null && pincode!.isNotEmpty) parts.add(pincode!);
    return parts.join(', ');
  }

  bool get hasValidPic =>
      profilePic != null && profilePic!.isNotEmpty && profilePic!.startsWith('http');

  String? get encodedPicUrl => profilePic?.replaceAll(' ', '%20');

  /// iOS: hideWhatsnum == "0" means hidden
  bool get isPhoneHidden => hideWhatsnum == '0';

  /// iOS: hideMail == "0" means hidden
  bool get isEmailHidden => hideMail == '0';

  factory BranchMemberDetail.fromJson(Map<String, dynamic> json) {
    return BranchMemberDetail(
      masterID: json['masterID']?.toString(),
      grpID: json['grpID']?.toString(),
      grpName: json['GrpName']?.toString(),
      profileID: json['profileID']?.toString(),
      memberName: json['memberName']?.toString(),
      middleName: json['middleName']?.toString(),
      lastName: json['lastName']?.toString(),
      memberEmail: json['memberEmail']?.toString(),
      hideMail: json['hide_mail']?.toString(),
      memberMobile: json['memberMobile']?.toString(),
      hideWhatsnum: json['hide_whatsnum']?.toString(),
      secondryMobileNo: json['secondry_mobile_no']?.toString(),
      hideNum: json['hide_num']?.toString(),
      memberCountry: json['memberCountry']?.toString(),
      profilePic: json['profilePic']?.toString(),
      memberDateOfBirth: json['member_date_of_birth']?.toString(),
      memberDateOfWedding: json['member_date_of_wedding']?.toString(),
      bloodGroup: json['blood_Group']?.toString(),
      gradeId: json['GradeId']?.toString(),
      membershipGrade: json['MembershipGrade']?.toString(),
      category: json['Category']?.toString(),
      categoryId: json['CategoryId']?.toString(),
      memberIMEIID: json['member_IMEI_id']?.toString(),
      companyName: json['CompanyName']?.toString(),
      clubName: json['Club_Name']?.toString(),
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      stateId: json['state_id']?.toString(),
      stateName: json['state_name']?.toString(),
      pincode: json['pincode']?.toString(),
      addressResult: json['addressResult']?.toString(),
    );
  }
}

/// Model for FindClub/GetClubList response used by Branch & Chapter screen.
/// iOS: Branch struct — TBGetClubResult.ClubResult with Table (branches) and Table1 (members).
class BranchChapterResult {
  BranchChapterResult({this.branches = const [], this.members = const []});

  final List<BranchItem> branches;
  final List<BranchMemberItem> members;

  factory BranchChapterResult.fromJson(Map<String, dynamic> json) {
    // Response: { TBGetClubResult: { status, message, ClubResult: { Table: [...], Table1: [...] } } }
    final clubResult =
        json['TBGetClubResult'] as Map<String, dynamic>? ?? json;

    final inner = clubResult['ClubResult'];

    List<dynamic> table = [];
    List<dynamic> table1 = [];

    if (inner is Map<String, dynamic>) {
      // Structure: { ClubResult: { Table: [...], Table1: [...] } }
      table = inner['Table'] as List<dynamic>? ?? [];
      table1 = inner['Table1'] as List<dynamic>? ?? [];
    } else if (inner is List<dynamic>) {
      // Fallback: { ClubResult: [...] } — flat list of branches
      table = inner;
    }

    return BranchChapterResult(
      branches: table
          .map((e) => BranchItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      members: table1
          .map((e) => BranchMemberItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// iOS: Tables struct — branch/chapter list item.
/// CodingKeys map: GroupId, group_name, address, city, State, pincode, country_name,
/// Meeting_Day, meeting_from_time, meeting_to_time, member_name, Designation,
/// mobile_no, hide_num, email_id, hide_mail, plus 0/1 suffixed variants.
class BranchItem {
  BranchItem({this.groupId, this.groupName, this.address});

  final int? groupId;
  final String? groupName;
  final String? address;

  factory BranchItem.fromJson(Map<String, dynamic> json) {
    return BranchItem(
      groupId: json['GroupId'] as int?,
      groupName: json['group_name']?.toString(),
      address: json['address']?.toString(),
    );
  }
}

/// iOS: Tables1 struct — branch member/office bearer item.
/// CodingKeys map: GroupId, member_name, Designation, mobile_no, hide_num,
/// email_id, hide_mail, plus 0/1 suffixed variants.
class BranchMemberItem {
  BranchMemberItem({
    this.groupId,
    this.memberName,
    this.designation,
    this.mobileNo,
    this.emailId,
    this.hideNum,
    this.hideMail,
    this.designation0,
    this.memberName0,
    this.mobileNo0,
    this.emailId0,
  });

  final int? groupId;
  final String? memberName;
  final String? designation;
  final String? mobileNo;
  final String? emailId;
  final int? hideNum;
  final int? hideMail;
  final String? designation0;
  final String? memberName0;
  final String? mobileNo0;
  final String? emailId0;

  factory BranchMemberItem.fromJson(Map<String, dynamic> json) {
    return BranchMemberItem(
      groupId: json['GroupId'] as int?,
      memberName: json['member_name']?.toString(),
      designation: json['Designation']?.toString(),
      mobileNo: json['mobile_no']?.toString(),
      emailId: json['email_id']?.toString(),
      hideNum: json['hide_num'] as int?,
      hideMail: json['hide_mail'] as int?,
      designation0: json['Designation0']?.toString(),
      memberName0: json['member_name0']?.toString(),
      mobileNo0: json['mobile_no0']?.toString(),
      emailId0: json['email_id0']?.toString(),
    );
  }
}
