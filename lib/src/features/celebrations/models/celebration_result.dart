import '../../../core/models/base_model.dart';

/// Port of iOS TBEventListResult — month event list response.
/// API: Celebrations/GetMonthEventList
/// Response key: "TBEventListResult"
class TBEventListResult extends BaseModel {
  TBEventListResult({
    this.status,
    this.message,
    this.result,
  });

  final String? status;
  final String? message;
  final MonthEventResultData? result;

  factory TBEventListResult.fromJson(Map<String, dynamic> json) {
    return TBEventListResult(
      status: BaseModel.safeString(json['status']),
      message: BaseModel.safeString(json['message']),
      result: BaseModel.safeModel(json['Result'], MonthEventResultData.fromJson),
    );
  }

  bool get isSuccess => status == '0';

  @override
  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'Result': result?.toJson(),
      };
}

/// iOS: Result containing newEvents, updatedEvents, deletedEvents arrays
class MonthEventResultData extends BaseModel {
  MonthEventResultData({
    this.newEvents,
    this.updatedEvents,
    this.deletedEvents,
  });

  final List<CelebrationEvent>? newEvents;
  final List<CelebrationEvent>? updatedEvents;
  final List<CelebrationEvent>? deletedEvents;

  factory MonthEventResultData.fromJson(Map<String, dynamic> json) {
    return MonthEventResultData(
      newEvents:
          BaseModel.safeList(json['newEvents'], CelebrationEvent.fromJson),
      updatedEvents:
          BaseModel.safeList(json['updatedEvents'], CelebrationEvent.fromJson),
      deletedEvents:
          BaseModel.safeList(json['deletedEvents'], CelebrationEvent.fromJson),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'newEvents': newEvents?.map((e) => e.toJson()).toList(),
        'updatedEvents': updatedEvents?.map((e) => e.toJson()).toList(),
        'deletedEvents': deletedEvents?.map((e) => e.toJson()).toList(),
      };
}

/// Android: EmailIds array item — { MemberName, EmailId }
class CelebrationEmailItem extends BaseModel {
  CelebrationEmailItem({this.memberName, this.emailId});

  final String? memberName;
  final String? emailId;

  factory CelebrationEmailItem.fromJson(Map<String, dynamic> json) {
    return CelebrationEmailItem(
      memberName: BaseModel.safeString(json['MemberName']),
      emailId: BaseModel.safeString(json['EmailId']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'MemberName': memberName,
        'EmailId': emailId,
      };
}

/// Android: MobileNo array item — { MemberName, MobileNo }
class CelebrationMobileItem extends BaseModel {
  CelebrationMobileItem({this.memberName, this.mobileNo});

  final String? memberName;
  final String? mobileNo;

  factory CelebrationMobileItem.fromJson(Map<String, dynamic> json) {
    return CelebrationMobileItem(
      memberName: BaseModel.safeString(json['MemberName']),
      mobileNo: BaseModel.safeString(json['MobileNo']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'MemberName': memberName,
        'MobileNo': mobileNo,
      };
}

/// Individual celebration event item.
/// Used in month view, day view, and type-wise listings.
/// Android: BirthdayFragment/AnniverseryFragment parse EmailIds (JSONArray)
/// and MobileNo (JSONArray) — button visibility depends on array contents.
class CelebrationEvent extends BaseModel {
  CelebrationEvent({
    this.eventID,
    this.eventDate,
    this.title,
    this.contactNumber,
    this.emailId,
    this.emailIds,
    this.mobileNos,
    this.hideWhatsnum,
    this.hideNum,
    this.hideMail,
    this.description,
    this.eventTitle,
    this.eventImg,
    this.eventDateTime,
    this.venue,
    this.goingCount,
    this.maybeCount,
    this.notgoingCount,
    this.myResponse,
    this.filterType,
    this.grpID,
    this.grpAdminId,
    this.isRead,
    this.venueLat,
    this.venueLon,
    this.type,
    this.memberID,
    this.groupIdNew,
  });

  final String? eventID;
  final String? eventDate;
  final String? title;
  final String? contactNumber;
  final String? emailId;
  /// Android: EmailIds JSONArray — determines email button visibility.
  final List<CelebrationEmailItem>? emailIds;
  /// Android: MobileNo JSONArray — determines call/sms/WhatsApp button visibility.
  final List<CelebrationMobileItem>? mobileNos;
  /// hide_whatsnum: "1" = visible, "0" = hidden
  final String? hideWhatsnum;
  /// hide_num: "1" = visible, "0" = hidden
  final String? hideNum;
  /// hide_mail: "1" = visible, "0" = hidden
  final String? hideMail;
  final String? description;
  final String? eventTitle;
  final String? eventImg;
  final String? eventDateTime;
  final String? venue;
  final String? goingCount;
  final String? maybeCount;
  final String? notgoingCount;
  final String? myResponse;
  final String? filterType;
  final String? grpID;
  final String? grpAdminId;
  final String? isRead;
  final String? venueLat;
  final String? venueLon;
  final String? type;
  final String? memberID;
  final String? groupIdNew;

  factory CelebrationEvent.fromJson(Map<String, dynamic> json) {
    return CelebrationEvent(
      eventID: BaseModel.safeString(json['eventID']),
      eventDate: BaseModel.safeString(json['eventDate']),
      title: BaseModel.safeString(json['title']),
      contactNumber: BaseModel.safeString(json['ContactNumber']),
      emailId: BaseModel.safeString(json['EmailId']),
      emailIds: BaseModel.safeList(
          json['EmailIds'], CelebrationEmailItem.fromJson),
      mobileNos: BaseModel.safeList(
          json['MobileNo'], CelebrationMobileItem.fromJson),
      // Try multiple key variations: snake_case, camelCase, PascalCase
      hideWhatsnum: BaseModel.safeString(json['hide_whatsnum'] ??
          json['hideWhatsnum'] ??
          json['HideWhatsnum'] ??
          json['Hide_whatsnum']),
      hideNum: BaseModel.safeString(json['hide_num'] ??
          json['hideNum'] ??
          json['HideNum'] ??
          json['Hide_num']),
      hideMail: BaseModel.safeString(json['hide_mail'] ??
          json['hideMail'] ??
          json['HideMail'] ??
          json['Hide_mail']),
      description: BaseModel.safeString(json['Description']),
      eventTitle: BaseModel.safeString(json['eventTitle']),
      eventImg: BaseModel.safeString(json['eventImg']),
      eventDateTime: BaseModel.safeString(json['eventDateTime']),
      venue: BaseModel.safeString(json['venue']),
      goingCount: BaseModel.safeString(json['goingCount']),
      maybeCount: BaseModel.safeString(json['maybeCount']),
      notgoingCount: BaseModel.safeString(json['notgoingCount']),
      myResponse: BaseModel.safeString(json['myResponse']),
      filterType: BaseModel.safeString(json['filterType']),
      grpID: BaseModel.safeString(json['grpID']),
      grpAdminId: BaseModel.safeString(json['grpAdminId']),
      isRead: BaseModel.safeString(json['isRead']),
      venueLat: BaseModel.safeString(json['venueLat']),
      venueLon: BaseModel.safeString(json['venueLon']),
      type: BaseModel.safeString(json['type']),
      memberID: BaseModel.safeString(json['MemberID']),
      groupIdNew: BaseModel.safeString(json['GroupIdNew']),
    );
  }

  /// Create a copy with hide flags applied (for current user's events).
  CelebrationEvent withHideFlags({
    required String hideWhatsnum,
    required String hideNum,
    required String hideMail,
  }) {
    return CelebrationEvent(
      eventID: eventID,
      eventDate: eventDate,
      title: title,
      contactNumber: contactNumber,
      emailId: emailId,
      emailIds: emailIds,
      mobileNos: mobileNos,
      hideWhatsnum: hideWhatsnum,
      hideNum: hideNum,
      hideMail: hideMail,
      description: description,
      eventTitle: eventTitle,
      eventImg: eventImg,
      eventDateTime: eventDateTime,
      venue: venue,
      goingCount: goingCount,
      maybeCount: maybeCount,
      notgoingCount: notgoingCount,
      myResponse: myResponse,
      filterType: filterType,
      grpID: grpID,
      grpAdminId: grpAdminId,
      isRead: isRead,
      venueLat: venueLat,
      venueLon: venueLon,
      type: type,
      memberID: memberID,
      groupIdNew: groupIdNew,
    );
  }

  bool get isBirthday => type == 'Birthday';
  bool get isAnniversary => type == 'Anniversary';
  bool get isEvent => type == 'Event' || type == 'Activity';

  String get displayTitle => title ?? eventTitle ?? '';

  /// Phone buttons enabled when either WhatsApp mobile OR secondary mobile
  /// toggle is ON (== "1"). Checks hide flags first, then MobileNo array,
  /// then ContactNumber fallback.
  bool get hasPhone {
    // If hide flags present, either must be "1" (visible) for phone to show
    if (hideWhatsnum != null || hideNum != null) {
      return hideWhatsnum == '1' || hideNum == '1';
    }
    if (mobileNos != null && mobileNos!.isNotEmpty) return true;
    return contactNumber != null && contactNumber!.isNotEmpty;
  }

  /// Email button enabled when hide_mail toggle is ON (== "1").
  /// Checks hide flag first, then EmailIds array, then EmailId fallback.
  bool get hasEmail {
    if (hideMail != null) return hideMail == '1';
    if (emailIds != null && emailIds!.isNotEmpty) return true;
    return emailId != null && emailId!.isNotEmpty;
  }

  /// First email from EmailIds array, or fallback to single EmailId field.
  String? get firstEmail {
    if (emailIds != null && emailIds!.isNotEmpty) {
      return emailIds!.first.emailId;
    }
    return emailId;
  }

  /// First phone from MobileNo array, or fallback to ContactNumber field.
  String? get firstPhone {
    if (mobileNos != null && mobileNos!.isNotEmpty) {
      return mobileNos!.first.mobileNo;
    }
    return contactNumber;
  }

  @override
  Map<String, dynamic> toJson() => {
        'eventID': eventID,
        'eventDate': eventDate,
        'title': title,
        'ContactNumber': contactNumber,
        'EmailId': emailId,
        'EmailIds': emailIds?.map((e) => e.toJson()).toList(),
        'MobileNo': mobileNos?.map((e) => e.toJson()).toList(),
        'hide_whatsnum': hideWhatsnum,
        'hide_num': hideNum,
        'hide_mail': hideMail,
        'Description': description,
        'eventTitle': eventTitle,
        'eventImg': eventImg,
        'eventDateTime': eventDateTime,
        'venue': venue,
        'goingCount': goingCount,
        'maybeCount': maybeCount,
        'notgoingCount': notgoingCount,
        'myResponse': myResponse,
        'filterType': filterType,
        'grpID': grpID,
        'grpAdminId': grpAdminId,
        'isRead': isRead,
        'venueLat': venueLat,
        'venueLon': venueLon,
        'type': type,
        'MemberID': memberID,
        'GroupIdNew': groupIdNew,
      };
}

/// Port of iOS TBEventListTypeResult — type-wise (Birthday/Anniversary) list.
/// API: Celebrations/GetMonthEventListTypeWise
/// Response key: "TBEventListTypeResult"
class TBEventListTypeResult extends BaseModel {
  TBEventListTypeResult({
    this.status,
    this.message,
    this.events,
  });

  final String? status;
  final String? message;
  final List<CelebrationEvent>? events;

  factory TBEventListTypeResult.fromJson(Map<String, dynamic> json) {
    // Events nested under Result.Events
    final result = json['Result'] as Map<String, dynamic>?;
    return TBEventListTypeResult(
      status: BaseModel.safeString(json['status']),
      message: BaseModel.safeString(json['message']),
      events: result != null
          ? BaseModel.safeList(result['Events'], CelebrationEvent.fromJson)
          : null,
    );
  }

  bool get isSuccess => status == '0';

  @override
  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'Result': {
          'Events': events?.map((e) => e.toJson()).toList(),
        },
      };
}

/// Port of iOS TBEventListDtlsResult — day-wise event details.
/// API: Celebrations/GetMonthEventListDetails
/// Response key: "TBEventListDtlsResult"
class TBEventListDtlsResult extends BaseModel {
  TBEventListDtlsResult({
    this.status,
    this.message,
    this.events,
  });

  final String? status;
  final String? message;
  final List<CelebrationEvent>? events;

  factory TBEventListDtlsResult.fromJson(Map<String, dynamic> json) {
    final result = json['Result'] as Map<String, dynamic>?;
    return TBEventListDtlsResult(
      status: BaseModel.safeString(json['status']),
      message: BaseModel.safeString(json['message']),
      events: result != null
          ? BaseModel.safeList(result['Events'], CelebrationEvent.fromJson)
          : null,
    );
  }

  bool get isSuccess => status == '0';

  @override
  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'Result': {
          'Events': events?.map((e) => e.toJson()).toList(),
        },
      };
}

/// Port of iOS TBPublicEventList — event min details response.
/// API: Celebrations/GetEventMinDetails
/// Response key: "TBPublicEventList"
class TBPublicEventResult extends BaseModel {
  TBPublicEventResult({
    this.status,
    this.result,
  });

  final String? status;
  final CelebrationEvent? result;

  factory TBPublicEventResult.fromJson(Map<String, dynamic> json) {
    return TBPublicEventResult(
      status: BaseModel.safeString(json['status']),
      result: BaseModel.safeModel(json['Result'], CelebrationEvent.fromJson),
    );
  }

  bool get isSuccess => status == '0';

  @override
  Map<String, dynamic> toJson() => {
        'status': status,
        'Result': result?.toJson(),
      };
}
