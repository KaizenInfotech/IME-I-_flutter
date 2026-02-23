import '../../../core/models/base_model.dart';

/// OTP verification response model.
/// iOS: Same LoginResult structure is reused for OTP verify (Login/PostOTP).
/// The response after OTP verify includes the full user session data.
class OtpResult extends BaseModel {
  final String? status;
  final String? message;
  final String? isExists;
  final OtpDs? ds;

  OtpResult({this.status, this.message, this.isExists, this.ds});

  factory OtpResult.fromJson(Map<String, dynamic> json) {
    // Response wrapped in "LoginResult" key
    final data = json['LoginResult'] as Map<String, dynamic>? ?? json;
    return OtpResult(
      status: BaseModel.safeString(data['status']),
      message: BaseModel.safeString(data['message']),
      isExists: BaseModel.safeString(data['isexists']),
      ds: data['ds'] != null
          ? OtpDs.fromJson(data['ds'] as Map<String, dynamic>)
          : null,
    );
  }

  bool get isSuccess => status == '0' || message == 'success';

  @override
  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'isexists': isExists,
      };
}

class OtpDs {
  final List<OtpTable>? table;

  OtpDs({this.table});

  factory OtpDs.fromJson(Map<String, dynamic> json) {
    return OtpDs(
      table: BaseModel.safeList<OtpTable>(
        json['Table'],
        (e) => OtpTable.fromJson(e),
      ),
    );
  }
}

/// iOS: Table struct from OTP verify response.
/// Same structure as LoginTable but kept separate for clarity.
class OtpTable extends BaseModel {
  final int? masterUID;
  final int? grpid0;
  final String? grpid1;
  final String? grpName;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? imeiMemId;
  final int? memberProfileId;
  final String? profileImage;
  final int? groupMasterId;

  OtpTable({
    this.masterUID,
    this.grpid0,
    this.grpid1,
    this.grpName,
    this.firstName,
    this.middleName,
    this.lastName,
    this.imeiMemId,
    this.memberProfileId,
    this.profileImage,
    this.groupMasterId,
  });

  factory OtpTable.fromJson(Map<String, dynamic> json) {
    return OtpTable(
      masterUID: BaseModel.safeInt(json['masterUID']),
      grpid0: BaseModel.safeInt(json['grpid0']),
      grpid1: BaseModel.safeString(json['grpid1']),
      grpName: BaseModel.safeString(json['GrpName']),
      firstName: BaseModel.safeString(json['FirstName']),
      middleName: BaseModel.safeString(json['MiddleName']),
      lastName: BaseModel.safeString(json['LastName']),
      imeiMemId: BaseModel.safeString(json['IMEI_Mem_Id']),
      memberProfileId:
          BaseModel.safeInt(json['memberProfileId'] ?? json['memberProfileID']),
      profileImage: BaseModel.safeString(
          json['profileImage'] ?? json['Profile_Image']),
      groupMasterId:
          BaseModel.safeInt(json['groupMasterID'] ?? json['group_master_id']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'masterUID': masterUID,
        'grpid0': grpid0,
        'grpid1': grpid1,
        'GrpName': grpName,
        'FirstName': firstName,
        'MiddleName': middleName,
        'LastName': lastName,
        'IMEI_Mem_Id': imeiMemId,
        'memberProfileId': memberProfileId,
        'profileImage': profileImage,
        'group_master_id': groupMasterId,
      };
}
