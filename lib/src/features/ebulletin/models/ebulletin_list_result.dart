import '../../../core/models/base_model.dart';

/// Port of iOS TBEbulletinListResult / TBYearWiseEbulletinList — e-bulletin list response.
/// API: Ebulletin/GetYearWiseEbulletinList
/// Response key: "TBYearWiseEbulletinList"
class TBEbulletinListResult extends BaseModel {
  TBEbulletinListResult({
    this.status,
    this.message,
    this.smscount,
    this.ebulletins,
  });

  final String? status;
  final String? message;
  final String? smscount;
  final List<EbulletinItem>? ebulletins;

  factory TBEbulletinListResult.fromJson(Map<String, dynamic> json) {
    // iOS: Response → Result → EbulletinListResult (array)
    final result = json['Result'] as Map<String, dynamic>? ?? json;
    return TBEbulletinListResult(
      status: BaseModel.safeString(json['status']),
      message: BaseModel.safeString(json['message']),
      smscount: BaseModel.safeString(json['smscount']),
      ebulletins: BaseModel.safeList(
          result['EbulletinListResult'], EbulletinItem.fromJson),
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

/// Single e-bulletin item from the list.
/// iOS: EbulletinList Obj-C model.
class EbulletinItem extends BaseModel {
  EbulletinItem({
    this.ebulletinID,
    this.ebulletinlink,
    this.ebulletinType,
    this.ebulletinDate,
    this.isAdmin,
    this.ebulletinTitle,
    this.filterType,
    this.createDateTime,
    this.publishDateTime,
    this.isRead,
  });

  final String? ebulletinID;
  final String? ebulletinlink;
  final String? ebulletinType;
  final String? ebulletinDate;
  final String? isAdmin;
  final String? ebulletinTitle;
  final String? filterType;
  final String? createDateTime;
  final String? publishDateTime;
  final String? isRead;

  factory EbulletinItem.fromJson(Map<String, dynamic> json) {
    return EbulletinItem(
      ebulletinID: BaseModel.safeString(json['ebulletinID']),
      ebulletinlink: BaseModel.safeString(json['ebulletinlink']),
      ebulletinType: BaseModel.safeString(json['ebulletinType']),
      ebulletinDate: BaseModel.safeString(json['ebulletinDate']),
      isAdmin: BaseModel.safeString(json['isAdmin']),
      ebulletinTitle: BaseModel.safeString(json['ebulletinTitle']),
      filterType: BaseModel.safeString(json['filterType']),
      createDateTime: BaseModel.safeString(json['createDateTime']),
      publishDateTime: BaseModel.safeString(json['publishDateTime']),
      isRead: BaseModel.safeString(json['isRead']),
    );
  }

  /// iOS: isRead "No" = unread (purple text), "Yes" = read (black text)
  bool get hasBeenRead => isRead == 'Yes';

  bool get hasValidLink =>
      ebulletinlink != null && ebulletinlink!.isNotEmpty;

  /// iOS: checks file extension for PDF/DOC/HTML/IMG types
  bool get isDocumentType {
    final link = ebulletinlink?.toLowerCase() ?? '';
    return link.endsWith('.pdf') ||
        link.endsWith('.docx') ||
        link.endsWith('.doc') ||
        link.endsWith('.html') ||
        link.endsWith('.jpg') ||
        link.endsWith('.jpeg') ||
        link.endsWith('.png');
  }

  /// iOS: if not a document type, treated as external URL
  bool get isExternalUrl => hasValidLink && !isDocumentType;

  @override
  Map<String, dynamic> toJson() => {
        'ebulletinID': ebulletinID,
        'ebulletinlink': ebulletinlink,
        'ebulletinType': ebulletinType,
        'ebulletinDate': ebulletinDate,
        'isAdmin': isAdmin,
        'ebulletinTitle': ebulletinTitle,
        'filterType': filterType,
        'createDateTime': createDateTime,
        'publishDateTime': publishDateTime,
        'isRead': isRead,
      };
}
