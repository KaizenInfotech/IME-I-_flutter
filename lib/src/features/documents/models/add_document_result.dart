import '../../../core/models/base_model.dart';

/// Port of iOS TBAddDocumentResult — add document response.
/// API: DocumentSafe/AddDocument
/// Response key: "TBAddDocumentResult"
class TBAddDocumentResult extends BaseModel {
  TBAddDocumentResult({
    this.status,
    this.message,
  });

  final String? status;
  final String? message;

  factory TBAddDocumentResult.fromJson(Map<String, dynamic> json) {
    return TBAddDocumentResult(
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
