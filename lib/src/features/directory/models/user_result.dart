import '../../../core/models/base_model.dart';

/// Port of iOS UserResult.h — response from Member/UpdateProfile.
/// Also used for Member/UpdateProfilePersonalDetails.
class UserResult extends BaseModel {
  final String? status;
  final String? message;
  final String? result;

  UserResult({
    this.status,
    this.message,
    this.result,
  });

  factory UserResult.fromJson(Map<String, dynamic> json) {
    return UserResult(
      status: BaseModel.safeString(json['status']),
      message: BaseModel.safeString(json['message']),
      result: BaseModel.safeString(json['result']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'result': result,
      };

  bool get isSuccess => status == '0';
}

/// Port of iOS UpdateAddressResult.h — response from Member/UpdateAddressDetails.
class UpdateAddressResult extends BaseModel {
  final String? status;
  final String? message;

  UpdateAddressResult({
    this.status,
    this.message,
  });

  factory UpdateAddressResult.fromJson(Map<String, dynamic> json) {
    return UpdateAddressResult(
      status: BaseModel.safeString(json['status']),
      message: BaseModel.safeString(json['message']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
      };

  bool get isSuccess => status == '0';
}

/// Port of iOS UpdateFamilyResult.h — response from Member/UpdateFamilyDetails.
class UpdateFamilyResult extends BaseModel {
  final String? status;
  final String? message;

  UpdateFamilyResult({
    this.status,
    this.message,
  });

  factory UpdateFamilyResult.fromJson(Map<String, dynamic> json) {
    return UpdateFamilyResult(
      status: BaseModel.safeString(json['status']),
      message: BaseModel.safeString(json['message']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
      };

  bool get isSuccess => status == '0';
}
