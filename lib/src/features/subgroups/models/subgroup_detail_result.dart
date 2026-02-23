import '../../../core/models/base_model.dart';

/// Port of iOS TBGetSubGroupDetailListResult — sub-group detail response.
/// API: Group/GetSubGroupDetail
/// Response key: "TBGetSubGroupDetailListResult" → "SubGroupResult"
class TBGetSubGroupDetailResult extends BaseModel {
  TBGetSubGroupDetailResult({
    this.status,
    this.message,
    this.members,
  });

  final String? status;
  final String? message;
  final List<SubgroupMember>? members;

  factory TBGetSubGroupDetailResult.fromJson(Map<String, dynamic> json) {
    final result = json['SubGroupResult'] as List<dynamic>?;

    return TBGetSubGroupDetailResult(
      status: BaseModel.safeString(json['status']),
      message: BaseModel.safeString(json['message']),
      members: result
          ?.map((e) => SubgroupMember.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  bool get isSuccess => status == '0';

  @override
  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
      };
}

/// Sub-group member detail.
/// iOS: SubgrpMemberDetail.h — profileId, memname, mobile
class SubgroupMember extends BaseModel {
  SubgroupMember({
    this.profileId,
    this.memname,
    this.mobile,
  });

  final String? profileId;
  final String? memname;
  final String? mobile;

  factory SubgroupMember.fromJson(Map<String, dynamic> json) {
    return SubgroupMember(
      profileId: BaseModel.safeString(json['profileId']),
      memname: BaseModel.safeString(json['memname']),
      mobile: BaseModel.safeString(json['mobile']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'profileId': profileId,
        'memname': memname,
        'mobile': mobile,
      };
}
