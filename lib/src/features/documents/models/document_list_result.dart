import '../../../core/models/base_model.dart';

/// Port of iOS TBDocumentistResult — document list response.
/// API: DocumentSafe/GetDocumentList
/// Response key: "DocumentLsitResult" (note: iOS has typo "Lsit")
class TBDocumentListResult extends BaseModel {
  TBDocumentListResult({
    this.status,
    this.message,
    this.smscount,
    this.documents,
  });

  final String? status;
  final String? message;
  final String? smscount;
  final List<DocumentItem>? documents;

  factory TBDocumentListResult.fromJson(Map<String, dynamic> json) {
    return TBDocumentListResult(
      status: BaseModel.safeString(json['status']),
      message: BaseModel.safeString(json['message']),
      smscount: BaseModel.safeString(json['smscount']),
      documents:
          BaseModel.safeList(json['DocumentLsitResult'], DocumentItem.fromJson),
    );
  }

  bool get isSuccess => status == '0';

  @override
  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'smscount': smscount,
      };
}

/// Single document item from the documents list.
/// iOS: DocumentList Obj-C model.
class DocumentItem extends BaseModel {
  DocumentItem({
    this.docID,
    this.docTitle,
    this.docType,
    this.docURL,
    this.createDateTime,
    this.docAccessType,
    this.isRead,
  });

  final String? docID;
  final String? docTitle;
  final String? docType;
  final String? docURL;
  final String? createDateTime;
  final String? docAccessType;
  final String? isRead;

  factory DocumentItem.fromJson(Map<String, dynamic> json) {
    return DocumentItem(
      docID: BaseModel.safeString(json['docID']),
      docTitle: BaseModel.safeString(json['docTitle']),
      docType: BaseModel.safeString(json['docType']),
      docURL: BaseModel.safeString(json['docURL']),
      createDateTime: BaseModel.safeString(json['createDateTime']),
      docAccessType: BaseModel.safeString(json['docAccessType']),
      isRead: BaseModel.safeString(json['isRead']),
    );
  }

  /// iOS: docAccessType 0 = restricted (webview only), 1 = downloadable
  bool get isDownloadable => docAccessType == '1';

  /// iOS: isRead 0 = unread, 1 = read
  bool get hasBeenRead => isRead == '1';

  bool get hasValidUrl => docURL != null && docURL!.isNotEmpty;

  /// iOS: checks docType for PDF
  bool get isPdf =>
      docType?.toLowerCase() == 'pdf' || docType?.toLowerCase() == '.pdf';

  /// iOS: checks for image types
  bool get isImage {
    final type = docType?.toLowerCase() ?? '';
    return type == 'jpg' ||
        type == 'jpeg' ||
        type == 'png' ||
        type == 'gif' ||
        type == '.jpg' ||
        type == '.jpeg' ||
        type == '.png' ||
        type == '.gif';
  }

  @override
  Map<String, dynamic> toJson() => {
        'docID': docID,
        'docTitle': docTitle,
        'docType': docType,
        'docURL': docURL,
        'createDateTime': createDateTime,
        'docAccessType': docAccessType,
        'isRead': isRead,
      };
}
