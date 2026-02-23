import '../../../core/models/base_model.dart';

/// Port of iOS AdminSubmodulesResult — response from Group/getAdminSubModules.
/// iOS: response["AdminSubmodulesResult"]["list"]
class AdminSubmodulesResult extends BaseModel {
  final String? status;
  final String? message;
  final List<AdminSubmodule>? list;

  AdminSubmodulesResult({
    this.status,
    this.message,
    this.list,
  });

  factory AdminSubmodulesResult.fromJson(Map<String, dynamic> json) {
    // iOS parses: response["AdminSubmodulesResult"]
    final result = json['AdminSubmodulesResult'] as Map<String, dynamic>?;
    if (result != null) {
      return AdminSubmodulesResult(
        status: BaseModel.safeString(result['status']),
        message: BaseModel.safeString(result['message']),
        list: BaseModel.safeList(result['list'], AdminSubmodule.fromJson),
      );
    }
    // Fallback: parse directly
    return AdminSubmodulesResult(
      status: BaseModel.safeString(json['status']),
      message: BaseModel.safeString(json['message']),
      list: BaseModel.safeList(json['list'], AdminSubmodule.fromJson),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'list': list?.map((e) => e.toJson()).toList(),
      };

  bool get isSuccess => status == '0';
}

/// Individual admin sub-module item.
/// Displayed in AdminModuleListingViewController grid.
class AdminSubmodule extends BaseModel {
  final String? moduleId;
  final String? moduleName;
  final String? moduleStaticRef;
  final String? image;
  final String? groupId;
  final String? groupModuleId;
  final String? moduleOrderNo;
  final String? notificationCount;

  AdminSubmodule({
    this.moduleId,
    this.moduleName,
    this.moduleStaticRef,
    this.image,
    this.groupId,
    this.groupModuleId,
    this.moduleOrderNo,
    this.notificationCount,
  });

  factory AdminSubmodule.fromJson(Map<String, dynamic> json) {
    return AdminSubmodule(
      moduleId: BaseModel.safeString(json['moduleId']),
      moduleName: BaseModel.safeString(json['moduleName']),
      moduleStaticRef: BaseModel.safeString(json['moduleStaticRef']),
      image: BaseModel.safeString(json['image']),
      groupId: BaseModel.safeString(json['groupId']),
      groupModuleId: BaseModel.safeString(json['groupModuleId']),
      moduleOrderNo: BaseModel.safeString(json['moduleOrderNo']),
      notificationCount: BaseModel.safeString(json['notificationCount']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'moduleId': moduleId,
        'moduleName': moduleName,
        'moduleStaticRef': moduleStaticRef,
        'image': image,
        'groupId': groupId,
        'groupModuleId': groupModuleId,
        'moduleOrderNo': moduleOrderNo,
        'notificationCount': notificationCount,
      };
}
