import '../../../core/models/base_model.dart';

/// Port of iOS LoginResult.h (Obj-C) + LoginResultResponse.swift (Swift Decodable).
/// Top-level response from Login/UserLogin and Login/PostOTP.
///
/// JSON: { "LoginResult": { "message": "...", "status": "...", ... } }
class LoginResult extends BaseModel {
  final String? status;
  final String? message;
  final String? otp;
  final String? isExists;
  final String? masterUID;
  final String? isMemberNotRegistered;
  final LoginResultData? loginResultData;

  LoginResult({
    this.status,
    this.message,
    this.otp,
    this.isExists,
    this.masterUID,
    this.isMemberNotRegistered,
    this.loginResultData,
  });

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    // The response may have "LoginResult" wrapper or be flat
    final data = json['LoginResult'] as Map<String, dynamic>? ?? json;
    return LoginResult(
      status: BaseModel.safeString(data['status']),
      message: BaseModel.safeString(data['message']),
      otp: BaseModel.safeString(data['otp']),
      isExists: BaseModel.safeString(data['isexists']),
      masterUID: BaseModel.safeString(data['masterUID']),
      isMemberNotRegistered:
          BaseModel.safeString(data['isMemeberNotRegistered']),
      loginResultData: data['ds'] != null || data['status'] != null
          ? LoginResultData.fromJson(data)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'otp': otp,
        'isexists': isExists,
        'masterUID': masterUID,
        'isMemeberNotRegistered': isMemberNotRegistered,
      };

  bool get isSuccess => status == '0' || message == 'success';
}

/// iOS: LoginResultData (Swift Decodable).
/// Contains message, status, isexists, and nested Ds.
class LoginResultData {
  final String? message;
  final String? status;
  final String? isExists;
  final LoginDs? ds;

  LoginResultData({this.message, this.status, this.isExists, this.ds});

  factory LoginResultData.fromJson(Map<String, dynamic> json) {
    return LoginResultData(
      message: BaseModel.safeString(json['message']),
      status: BaseModel.safeString(json['status']),
      isExists: BaseModel.safeString(json['isexists']),
      ds: json['ds'] != null
          ? LoginDs.fromJson(json['ds'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// iOS: Ds (Swift Decodable).
/// Contains Table array with user session data.
class LoginDs {
  final List<LoginTable>? table;

  LoginDs({this.table});

  factory LoginDs.fromJson(Map<String, dynamic> json) {
    return LoginDs(
      table: BaseModel.safeList<LoginTable>(
        json['Table'],
        (e) => LoginTable.fromJson(e),
      ),
    );
  }
}

/// iOS: Table (Swift Decodable).
/// User session identity data stored in UserDefaults post-login.
///
/// JSON keys exactly match iOS:
/// masterUID, grpid0, grpid1, GrpName, FirstName, MiddleName, LastName,
/// IMEI_Mem_Id, memberProfileId, profileImage, group_master_id
class LoginTable extends BaseModel {
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

  LoginTable({
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

  factory LoginTable.fromJson(Map<String, dynamic> json) {
    return LoginTable(
      masterUID: BaseModel.safeInt(json['masterUID']),
      grpid0: BaseModel.safeInt(json['grpid0']),
      grpid1: BaseModel.safeString(json['grpid1']),
      grpName: BaseModel.safeString(json['GrpName']),
      firstName: BaseModel.safeString(json['FirstName']),
      middleName: BaseModel.safeString(json['MiddleName']),
      lastName: BaseModel.safeString(json['LastName']),
      imeiMemId: BaseModel.safeString(json['IMEI_Mem_Id']),
      memberProfileId: BaseModel.safeInt(json['memberProfileId'] ??
          json['memberProfileID']),
      profileImage: BaseModel.safeString(
          json['profileImage'] ?? json['Profile_Image']),
      groupMasterId: BaseModel.safeInt(
          json['groupMasterID'] ?? json['group_master_id']),
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
