import '../../../core/models/base_model.dart';

/// Port of iOS TBAddAnnouncementResult Obj-C model.
/// API: Announcement/AddAnnouncement
/// Response key: "TBAddAnnouncementResult"
class TBAddAnnouncementResult extends BaseModel {
  TBAddAnnouncementResult({
    this.status,
    this.message,
  });

  final String? status;
  final String? message;

  factory TBAddAnnouncementResult.fromJson(Map<String, dynamic> json) {
    return TBAddAnnouncementResult(
      status: BaseModel.safeString(json['status']),
      message: BaseModel.safeString(json['message']),
    );
  }

  bool get isSuccess => status == '0';
  bool get isFailed => message == 'failed';

  @override
  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
      };
}
