import '../../../core/models/base_model.dart';

/// Port of iOS TBAddServiceResult — add/edit service response.
/// API: ServiceDirectory/AddServiceDirectory
/// Response key: "TBAddServiceResult"
class TBAddServiceResult extends BaseModel {
  TBAddServiceResult({
    this.status,
    this.message,
  });

  final String? status;
  final String? message;

  factory TBAddServiceResult.fromJson(Map<String, dynamic> json) {
    return TBAddServiceResult(
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
