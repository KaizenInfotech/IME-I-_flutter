import '../../../core/models/base_model.dart';

/// Port of iOS TBGetSubGroupListResult — sub-group list response.
/// API: Group/GetSubGroupList
/// Response key: "TBGetSubGroupListResult" → "SubGroupResult"
class TBGetSubGroupListResult extends BaseModel {
  TBGetSubGroupListResult({
    this.status,
    this.message,
    this.subgroups,
  });

  final String? status;
  final String? message;
  final List<SubgroupItem>? subgroups;

  factory TBGetSubGroupListResult.fromJson(Map<String, dynamic> json) {
    final result = json['SubGroupResult'] as List<dynamic>?;

    return TBGetSubGroupListResult(
      status: BaseModel.safeString(json['status']),
      message: BaseModel.safeString(json['message']),
      subgroups: result
          ?.map((e) => SubgroupItem.fromJson(e as Map<String, dynamic>))
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

/// Single sub-group from the list.
/// iOS: Subgroup.h — subgrpId, subgrpTitle, noOfmem
class SubgroupItem extends BaseModel {
  SubgroupItem({
    this.subgrpId,
    this.subgrpTitle,
    this.noOfmem,
  });

  final String? subgrpId;
  final String? subgrpTitle;
  final String? noOfmem;

  factory SubgroupItem.fromJson(Map<String, dynamic> json) {
    return SubgroupItem(
      subgrpId: BaseModel.safeString(json['subgrpId']),
      subgrpTitle: BaseModel.safeString(json['subgrpTitle']),
      noOfmem: BaseModel.safeString(json['noOfmem']),
    );
  }

  /// Display member count
  String get displayMemberCount {
    final count = int.tryParse(noOfmem ?? '0') ?? 0;
    return count == 1 ? '1 member' : '$count members';
  }

  @override
  Map<String, dynamic> toJson() => {
        'subgrpId': subgrpId,
        'subgrpTitle': subgrpTitle,
        'noOfmem': noOfmem,
      };
}
