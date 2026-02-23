/// Response from Group/CreateGroup.
/// iOS: CreateGRpResult (Obj-C) — status, message, grdId.
class CreateGroupResult {
  CreateGroupResult({this.status, this.message, this.groupId});

  final String? status;
  final String? message;
  final String? groupId;

  bool get isSuccess => status == '0';

  factory CreateGroupResult.fromJson(Map<String, dynamic> json) {
    return CreateGroupResult(
      status: json['status']?.toString(),
      message: json['message']?.toString(),
      groupId: json['grdId']?.toString(),
    );
  }
}

/// Response from Group/AddMemberToGroup.
/// iOS: TBAddMemberGroupResult — status, message, totalMember.
class AddMemberGroupResult {
  AddMemberGroupResult({this.status, this.message, this.totalMember});

  final String? status;
  final String? message;
  final String? totalMember;

  bool get isSuccess => status == '0';

  factory AddMemberGroupResult.fromJson(Map<String, dynamic> json) {
    return AddMemberGroupResult(
      status: json['status']?.toString(),
      message: json['message']?.toString(),
      totalMember: json['totalMember']?.toString(),
    );
  }
}

/// Response from Group/DeleteEntity.
/// iOS: TBDeleteEntityResult — status, message.
class DeleteEntityResult {
  DeleteEntityResult({this.status, this.message});

  final String? status;
  final String? message;

  bool get isSuccess => status == '0';

  factory DeleteEntityResult.fromJson(Map<String, dynamic> json) {
    return DeleteEntityResult(
      status: json['status']?.toString(),
      message: json['message']?.toString(),
    );
  }
}
