import '../../../core/models/base_model.dart';

/// Port of iOS TBAddEbulletinResult — add e-bulletin response.
/// API: Ebulletin/AddEbulletin
/// Response key: "TBAddEbulletinResult"
class TBAddEbulletinResult extends BaseModel {
  TBAddEbulletinResult({
    this.status,
    this.message,
  });

  final String? status;
  final String? message;

  factory TBAddEbulletinResult.fromJson(Map<String, dynamic> json) {
    return TBAddEbulletinResult(
      status: BaseModel.safeString(json['status']),
      message: BaseModel.safeString(json['message']),
    );
  }

  bool get isSuccess => status == '0';

  @override
  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
      };
}
