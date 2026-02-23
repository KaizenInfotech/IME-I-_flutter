import '../../../core/models/base_model.dart';

/// Port of iOS AddEventResult.h — add/update event response.
/// API: Event/AddEvent_New
/// Response key: "AddEventResult"
class AddEventResult extends BaseModel {
  AddEventResult({
    this.status,
    this.message,
  });

  final String? status;
  final String? message;

  factory AddEventResult.fromJson(Map<String, dynamic> json) {
    return AddEventResult(
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
