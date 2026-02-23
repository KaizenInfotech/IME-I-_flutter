import '../../../core/models/base_model.dart';

/// Port of iOS TBGetGroupModuleResult.h — response from Group/GetGroupModulesList.
class TBGetGroupModuleResult extends BaseModel {
  final String? status;
  final String? message;
  final List<GroupModule>? groupListResult;

  TBGetGroupModuleResult({
    this.status,
    this.message,
    this.groupListResult,
  });

  factory TBGetGroupModuleResult.fromJson(Map<String, dynamic> json) {
    return TBGetGroupModuleResult(
      status: BaseModel.safeString(json['status']),
      message: BaseModel.safeString(json['message']),
      groupListResult: BaseModel.safeList(
        json['GroupListResult'],
        GroupModule.fromJson,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'GroupListResult':
            groupListResult?.map((e) => e.toJson()).toList(),
      };

  bool get isSuccess => status == '0';
}

/// Port of iOS GroupList.h — individual module item within a group.
/// Displayed in the dashboard grid (CollectionView cell).
class GroupModule extends BaseModel {
  final String? groupModuleId;
  final String? groupId;
  final String? moduleId;
  final String? moduleName;
  final String? moduleStaticRef;
  final String? image;
  final String? masterProfileId;
  final String? isCustomized;
  final String? moduleOrderNo;
  final String? notificationCount;

  // Additional fields from iOS GroupList.h
  final String? modulePriceRs;
  final String? modulePriceUS;
  final String? moduleInfo;

  GroupModule({
    this.groupModuleId,
    this.groupId,
    this.moduleId,
    this.moduleName,
    this.moduleStaticRef,
    this.image,
    this.masterProfileId,
    this.isCustomized,
    this.moduleOrderNo,
    this.notificationCount,
    this.modulePriceRs,
    this.modulePriceUS,
    this.moduleInfo,
  });

  factory GroupModule.fromJson(Map<String, dynamic> json) {
    return GroupModule(
      groupModuleId: BaseModel.safeString(json['groupModuleId']),
      groupId: BaseModel.safeString(json['groupId']),
      moduleId: BaseModel.safeString(json['moduleId']),
      moduleName: BaseModel.safeString(json['moduleName']),
      moduleStaticRef: BaseModel.safeString(json['moduleStaticRef']),
      image: BaseModel.safeString(json['image']),
      masterProfileId: BaseModel.safeString(json['masterProfileID']),
      isCustomized: BaseModel.safeString(json['isCustomized']),
      moduleOrderNo: BaseModel.safeString(json['moduleOrderNo']),
      notificationCount: BaseModel.safeString(json['notificationCount']),
      modulePriceRs: BaseModel.safeString(json['modulePriceRs']),
      modulePriceUS: BaseModel.safeString(json['modulePriceUS']),
      moduleInfo: BaseModel.safeString(json['moduleInfo']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'groupModuleId': groupModuleId,
        'groupId': groupId,
        'moduleId': moduleId,
        'moduleName': moduleName,
        'moduleStaticRef': moduleStaticRef,
        'image': image,
        'masterProfileID': masterProfileId,
        'isCustomized': isCustomized,
        'moduleOrderNo': moduleOrderNo,
        'notificationCount': notificationCount,
        'modulePriceRs': modulePriceRs,
        'modulePriceUS': modulePriceUS,
        'moduleInfo': moduleInfo,
      };

  /// Parse notification count as integer.
  int get notificationCountInt => int.tryParse(notificationCount ?? '') ?? 0;
}
