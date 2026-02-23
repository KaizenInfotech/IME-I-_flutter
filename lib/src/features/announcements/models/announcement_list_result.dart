import '../../../core/models/base_model.dart';

/// Port of iOS TBAnnounceListResult + AnnounceList Obj-C models.
/// API: Announcement/GetAnnouncementList, Announcement/GetAnnouncementDetails
/// Response keys: "TBAnnounceListResult" → AnnounListResult[]
class TBAnnounceListResult extends BaseModel {
  TBAnnounceListResult({
    this.status,
    this.message,
    this.smscount,
    this.announcements,
  });

  final String? status;
  final String? message;
  final String? smscount;
  final List<AnnounceList>? announcements;

  factory TBAnnounceListResult.fromJson(Map<String, dynamic> json) {
    return TBAnnounceListResult(
      status: BaseModel.safeString(json['status']),
      message: BaseModel.safeString(json['message']),
      smscount: BaseModel.safeString(json['smscount']),
      announcements:
          BaseModel.safeList(json['AnnounListResult'], AnnounceList.fromJson),
    );
  }

  bool get isSuccess => status == '0';

  /// iOS: first announcement detail (for GetAnnouncementDetails)
  AnnounceList? get firstAnnouncement =>
      announcements != null && announcements!.isNotEmpty
          ? announcements!.first
          : null;

  @override
  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'smscount': smscount,
        'AnnounListResult': announcements?.map((a) => a.toJson()).toList(),
      };
}

/// Port of iOS AnnounceList Obj-C model — single announcement item.
/// iOS: AnnounceList.h properties.
class AnnounceList extends BaseModel {
  AnnounceList({
    this.announID,
    this.announTitle,
    this.announceDEsc,
    this.createDateTime,
    this.isAdmin,
    this.publishDateTime,
    this.expiryDateTime,
    this.isRead,
    this.filterType,
    this.announImg,
    this.profileIds,
    this.type,
    this.createDate,
    this.publishDate,
    this.expiryDate,
    this.sendSMSNonSmartPh,
    this.sendSMSAll,
    this.link,
    this.repeatDateTime,
    this.smsCount,
  });

  final String? announID;
  final String? announTitle;
  final String? announceDEsc;
  final String? createDateTime;
  final String? isAdmin;
  final String? publishDateTime;
  final String? expiryDateTime;
  final String? isRead;
  final String? filterType;
  final String? announImg;
  final String? profileIds;
  final String? type;
  final String? createDate;
  final String? publishDate;
  final String? expiryDate;
  final String? sendSMSNonSmartPh;
  final String? sendSMSAll;
  final String? link;
  final String? repeatDateTime;
  final String? smsCount;

  factory AnnounceList.fromJson(Map<String, dynamic> json) {
    // iOS: AnnounListResult contains nested AnnounceList dict
    final announceData =
        json['AnnounceList'] as Map<String, dynamic>? ?? json;
    return AnnounceList(
      announID: BaseModel.safeString(announceData['announID']),
      announTitle: BaseModel.safeString(announceData['announTitle']),
      announceDEsc: BaseModel.safeString(announceData['announceDEsc']),
      createDateTime: BaseModel.safeString(announceData['createDateTime']),
      isAdmin: BaseModel.safeString(announceData['isAdmin']),
      publishDateTime: BaseModel.safeString(announceData['publishDateTime']),
      expiryDateTime: BaseModel.safeString(announceData['expiryDateTime']),
      isRead: BaseModel.safeString(announceData['isRead']),
      filterType: BaseModel.safeString(announceData['filterType']),
      announImg: BaseModel.safeString(announceData['announImg']),
      profileIds: BaseModel.safeString(announceData['profileIds']),
      type: BaseModel.safeString(announceData['type']),
      createDate: BaseModel.safeString(announceData['createDate']),
      publishDate: BaseModel.safeString(announceData['publishDate']),
      expiryDate: BaseModel.safeString(announceData['expiryDate']),
      sendSMSNonSmartPh:
          BaseModel.safeString(announceData['sendSMSNonSmartPh']),
      sendSMSAll: BaseModel.safeString(announceData['sendSMSAll']),
      link: BaseModel.safeString(announceData['reglink'] ?? announceData['link']),
      repeatDateTime: BaseModel.safeString(announceData['repeatDateTime']),
      smsCount: BaseModel.safeString(announceData['SMSCount']),
    );
  }

  /// iOS: filterType == "3" means expired
  bool get isExpired => filterType == '3';

  /// Has valid image
  bool get hasValidImage =>
      announImg != null && announImg!.isNotEmpty;

  /// Has valid link (iOS: length > 8)
  bool get hasLink =>
      link != null && link!.length > 8;

  /// iOS: isRead flag
  bool get hasBeenRead => isRead == '1';

  /// iOS: type "0"=All, "1"=SubGroups, "2"=Members
  String get recipientTypeLabel {
    switch (type) {
      case '0':
        return 'All';
      case '1':
        return 'Sub Groups';
      case '2':
        return 'Members';
      default:
        return 'All';
    }
  }

  @override
  Map<String, dynamic> toJson() => {
        'announID': announID,
        'announTitle': announTitle,
        'announceDEsc': announceDEsc,
        'createDateTime': createDateTime,
        'isAdmin': isAdmin,
        'publishDateTime': publishDateTime,
        'expiryDateTime': expiryDateTime,
        'isRead': isRead,
        'filterType': filterType,
        'announImg': announImg,
        'profileIds': profileIds,
        'type': type,
        'createDate': createDate,
        'publishDate': publishDate,
        'expiryDate': expiryDate,
        'sendSMSNonSmartPh': sendSMSNonSmartPh,
        'sendSMSAll': sendSMSAll,
        'reglink': link,
        'repeatDateTime': repeatDateTime,
        'SMSCount': smsCount,
      };
}
