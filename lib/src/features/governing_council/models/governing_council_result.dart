/// Model for Member/GetGoverningCouncl API response.
/// Matches iOS GovernCouncilMember / MemberList structs.
class GoverningCouncilResult {
  GoverningCouncilResult({this.status, this.message, this.members = const []});

  final String? status;
  final String? message;
  final List<CouncilMember> members;

  factory GoverningCouncilResult.fromJson(Map<String, dynamic> json) {
    final result = json['Result'] as Map<String, dynamic>?;
    final table = result?['Table'] as List<dynamic>? ?? [];
    return GoverningCouncilResult(
      status: json['status'] as String?,
      message: json['message'] as String?,
      members: table
          .map((e) => CouncilMember.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// iOS: MemberList struct in GoverningCouncilViewController.
class CouncilMember {
  CouncilMember({
    this.bodPkId,
    this.profileId,
    this.tempMemberMasterId,
    this.fkMasterDesignationId,
    this.phoneNo,
    this.email,
    this.yearFilter,
    this.memberName,
    this.masterUid,
    this.srNo,
    this.grpId,
    this.pic,
    this.memberDesignation,
    this.membermobile,
  });

  final String? bodPkId;
  final String? profileId;
  final String? tempMemberMasterId;
  final String? fkMasterDesignationId;
  final String? phoneNo;
  final String? email;
  final String? yearFilter;
  final String? memberName;
  final String? masterUid;
  final String? srNo;
  final String? grpId;
  final String? pic;
  final String? memberDesignation;
  final String? membermobile;

  factory CouncilMember.fromJson(Map<String, dynamic> json) {
    return CouncilMember(
      bodPkId: json['BOD_pkID']?.toString(),
      profileId: json['ProfileID']?.toString(),
      tempMemberMasterId: json['TempMemberMasterID']?.toString(),
      fkMasterDesignationId: json['FK_Master_Designation_ID']?.toString(),
      phoneNo: json['PhoneNo']?.toString(),
      email: json['Email']?.toString(),
      yearFilter: json['YearFilter']?.toString(),
      memberName: json['MemberName']?.toString(),
      masterUid: json['masterUID']?.toString(),
      srNo: json['sr_NO']?.toString(),
      grpId: json['grpID']?.toString(),
      pic: json['pic']?.toString(),
      memberDesignation: json['MemberDesignation']?.toString(),
      membermobile: json['membermobile']?.toString(),
    );
  }
}
