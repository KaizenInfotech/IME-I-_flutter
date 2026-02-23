import '../../../core/models/base_model.dart';

/// Port of iOS TBGroupResult.h — response from Group/GetAllGroupsList.
/// Contains categorized group lists: All, Personal, Social, Business.
class TBGroupResult extends BaseModel {
  final String? status;
  final String? message;
  final String? version;
  final List<GroupResult>? allGroupListResults;
  final List<GroupResult>? personalGroupListResults;
  final List<GroupResult>? socialGroupListResults;
  final List<GroupResult>? businessGroupListResults;

  TBGroupResult({
    this.status,
    this.message,
    this.version,
    this.allGroupListResults,
    this.personalGroupListResults,
    this.socialGroupListResults,
    this.businessGroupListResults,
  });

  factory TBGroupResult.fromJson(Map<String, dynamic> json) {
    return TBGroupResult(
      status: BaseModel.safeString(json['status']),
      message: BaseModel.safeString(json['message']),
      version: BaseModel.safeString(json['version']),
      allGroupListResults: BaseModel.safeList(
        json['AllGroupListResults'],
        GroupResult.fromJson,
      ),
      personalGroupListResults: BaseModel.safeList(
        json['PersonalGroupListResults'],
        GroupResult.fromJson,
      ),
      socialGroupListResults: BaseModel.safeList(
        json['SocialGroupListResults'],
        GroupResult.fromJson,
      ),
      businessGroupListResults: BaseModel.safeList(
        json['BusinessGroupListResults'],
        GroupResult.fromJson,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'version': version,
        'AllGroupListResults':
            allGroupListResults?.map((e) => e.toJson()).toList(),
        'PersonalGroupListResults':
            personalGroupListResults?.map((e) => e.toJson()).toList(),
        'SocialGroupListResults':
            socialGroupListResults?.map((e) => e.toJson()).toList(),
        'BusinessGroupListResults':
            businessGroupListResults?.map((e) => e.toJson()).toList(),
      };

  /// Check if response is successful (iOS: status == "0").
  bool get isSuccess => status == '0';
}

/// Port of iOS GroupResult.h — individual group item.
class GroupResult extends BaseModel {
  final String? grpId;
  final String? grpName;
  final String? grpImg;
  final String? grpProfileId;
  final String? myCategory;
  final String? isGrpAdmin;
  final String? moduleId;

  GroupResult({
    this.grpId,
    this.grpName,
    this.grpImg,
    this.grpProfileId,
    this.myCategory,
    this.isGrpAdmin,
    this.moduleId,
  });

  factory GroupResult.fromJson(Map<String, dynamic> json) {
    return GroupResult(
      grpId: BaseModel.safeString(json['grpId']),
      grpName: BaseModel.safeString(json['grpName']),
      grpImg: BaseModel.safeString(json['grpImg']),
      grpProfileId: BaseModel.safeString(json['grpProfileId'] ?? json['grpProfileid']),
      myCategory: BaseModel.safeString(json['myCategory']),
      isGrpAdmin: BaseModel.safeString(json['isGrpAdmin']),
      moduleId: BaseModel.safeString(json['moduleId']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'grpId': grpId,
        'grpName': grpName,
        'grpImg': grpImg,
        'grpProfileId': grpProfileId,
        'myCategory': myCategory,
        'isGrpAdmin': isGrpAdmin,
        'moduleId': moduleId,
      };

  /// iOS: isGrpAdmin == "Yes"
  bool get isAdmin => isGrpAdmin?.toLowerCase() == 'yes';
}
