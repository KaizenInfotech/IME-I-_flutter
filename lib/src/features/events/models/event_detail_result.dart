import '../../../core/models/base_model.dart';

/// Port of iOS EventsListDetailResult.h — event detail response.
/// API: Event/GetEventDetails
/// Response key: "EventsListDetailResult"
class EventsListDetailResult extends BaseModel {
  EventsListDetailResult({
    this.status,
    this.message,
    this.eventsDetailResult,
  });

  final String? status;
  final String? message;
  final List<EventsDetailWrapper>? eventsDetailResult;

  factory EventsListDetailResult.fromJson(Map<String, dynamic> json) {
    return EventsListDetailResult(
      status: BaseModel.safeString(json['status']),
      message: BaseModel.safeString(json['message']),
      eventsDetailResult: BaseModel.safeList(
          json['EventsDetailResult'], EventsDetailWrapper.fromJson),
    );
  }

  /// Convenience: get first EventsDetail from nested structure
  EventsDetail? get firstDetail => eventsDetailResult?.isNotEmpty == true
      ? eventsDetailResult!.first.eventsDetail
      : null;

  @override
  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'EventsDetailResult':
            eventsDetailResult?.map((e) => e.toJson()).toList(),
      };
}

/// Wrapper for EventsDetail — iOS nests inside EventsDetailResult[0].EventsDetail
class EventsDetailWrapper extends BaseModel {
  EventsDetailWrapper({this.eventsDetail});

  final EventsDetail? eventsDetail;

  factory EventsDetailWrapper.fromJson(Map<String, dynamic> json) {
    return EventsDetailWrapper(
      eventsDetail:
          BaseModel.safeModel(json['EventsDetail'], EventsDetail.fromJson),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'EventsDetail': eventsDetail?.toJson(),
      };
}

/// Port of iOS EventsDetail.h — full event detail model.
/// All fields from the iOS Obj-C header, all nullable.
class EventsDetail extends BaseModel {
  EventsDetail({
    this.eventID,
    this.eventImg,
    this.eventTitle,
    this.eventDesc,
    this.projectname,
    this.eventDateTime,
    this.goingCount,
    this.maybeCount,
    this.notgoingCount,
    this.venue,
    this.myResponse,
    this.filterType,
    this.grpID,
    this.grpAdminId,
    this.totalCount,
    this.venueLat,
    this.venueLon,
    this.isQuesEnable,
    this.repeatEventResult,
    this.questionArray,
    this.eventType,
    this.inputIds,
    this.pubDate,
    this.expiryDate,
    this.eventDate,
    this.repeatDateTime,
    this.questionType,
    this.questionText,
    this.option1,
    this.option2,
    this.questionId,
    this.sendSMSNonSmartPh,
    this.sendSMSAll,
    this.rsvpEnable,
    this.displayonbanner,
    this.isAdmin,
    this.memberprofileid,
    this.link,
  });

  final String? eventID;
  final String? eventImg;
  final String? eventTitle;
  final String? eventDesc;
  final String? projectname;
  final String? eventDateTime;
  final String? goingCount;
  final String? maybeCount;
  final String? notgoingCount;
  final String? venue;
  final String? myResponse;
  final String? filterType;
  final String? grpID;
  final String? grpAdminId;
  final String? totalCount;
  final String? venueLat;
  final String? venueLon;
  final String? isQuesEnable;
  final List<RepeatEvent>? repeatEventResult;
  final List<dynamic>? questionArray;
  final String? eventType;
  final String? inputIds;
  final String? pubDate;
  final String? expiryDate;
  final String? eventDate;
  final String? repeatDateTime;
  final String? questionType;
  final String? questionText;
  final String? option1;
  final String? option2;
  final String? questionId;
  final String? sendSMSNonSmartPh;
  final String? sendSMSAll;
  final String? rsvpEnable;
  final String? displayonbanner;
  final String? isAdmin;
  final String? memberprofileid;
  final String? link;

  factory EventsDetail.fromJson(Map<String, dynamic> json) {
    return EventsDetail(
      eventID: BaseModel.safeString(json['eventID']),
      eventImg: BaseModel.safeString(json['eventImg']),
      eventTitle: BaseModel.safeString(json['eventTitle']),
      eventDesc: BaseModel.safeString(json['eventDesc']),
      projectname: BaseModel.safeString(json['Projectname']),
      eventDateTime: BaseModel.safeString(json['eventDateTime']),
      goingCount: BaseModel.safeString(json['goingCount']),
      maybeCount: BaseModel.safeString(json['maybeCount']),
      notgoingCount: BaseModel.safeString(json['notgoingCount']),
      venue: BaseModel.safeString(json['venue']),
      myResponse: BaseModel.safeString(json['myResponse']),
      filterType: BaseModel.safeString(json['filterType']),
      grpID: BaseModel.safeString(json['grpID']),
      grpAdminId: BaseModel.safeString(json['grpAdminId']),
      totalCount: BaseModel.safeString(json['totalCount']),
      venueLat: BaseModel.safeString(json['venueLat']),
      venueLon: BaseModel.safeString(json['venueLon']),
      isQuesEnable: BaseModel.safeString(json['isQuesEnable']),
      repeatEventResult: BaseModel.safeList(
          json['repeatEventResult'], RepeatEvent.fromJson),
      questionArray: json['questionArray'] as List<dynamic>?,
      eventType: BaseModel.safeString(json['eventType']),
      inputIds: BaseModel.safeString(json['inputIds']),
      pubDate: BaseModel.safeString(json['pubDate']),
      expiryDate: BaseModel.safeString(json['expiryDate']),
      eventDate: BaseModel.safeString(json['eventDate']),
      repeatDateTime: BaseModel.safeString(json['repeatDateTime']),
      questionType: BaseModel.safeString(json['questionType']),
      questionText: BaseModel.safeString(json['questionText']),
      option1: BaseModel.safeString(json['option1']),
      option2: BaseModel.safeString(json['option2']),
      questionId: BaseModel.safeString(json['questionId']),
      sendSMSNonSmartPh: BaseModel.safeString(json['sendSMSNonSmartPh']),
      sendSMSAll: BaseModel.safeString(json['sendSMSAll']),
      rsvpEnable: BaseModel.safeString(json['rsvpEnable']),
      displayonbanner: BaseModel.safeString(json['displayonbanner']),
      isAdmin: BaseModel.safeString(json['isAdmin']),
      memberprofileid: BaseModel.safeString(json['memberprofileid']),
      link: BaseModel.safeString(json['link']),
    );
  }

  /// iOS: rsvpEnable "0"=disabled, "1"=enabled
  bool get isRsvpEnabled => rsvpEnable == '1';

  /// iOS: isQuesEnable "0"=no question, "1"=text answer, "2"=multiple choice
  bool get hasQuestion =>
      isQuesEnable == '1' || isQuesEnable == '2';

  /// iOS: isQuesEnable "1"=text answer
  bool get isTextQuestion => isQuesEnable == '1';

  /// iOS: isQuesEnable "2"=option-based question
  bool get isOptionQuestion => isQuesEnable == '2';

  /// iOS: filterType "3" = expired
  bool get isExpired => filterType == '3';

  /// iOS: isAdmin "1" = admin user
  bool get isUserAdmin => isAdmin == '1';

  /// iOS: checks for valid image
  bool get hasValidImage =>
      eventImg != null && eventImg!.isNotEmpty && eventImg != 'null';

  /// iOS: checks for valid registration link
  bool get hasLink => link != null && link!.isNotEmpty;

  /// iOS: displayonbanner "1" = show on banner
  bool get showOnBanner => displayonbanner == '1';

  @override
  Map<String, dynamic> toJson() => {
        'eventID': eventID,
        'eventImg': eventImg,
        'eventTitle': eventTitle,
        'eventDesc': eventDesc,
        'Projectname': projectname,
        'eventDateTime': eventDateTime,
        'goingCount': goingCount,
        'maybeCount': maybeCount,
        'notgoingCount': notgoingCount,
        'venue': venue,
        'myResponse': myResponse,
        'filterType': filterType,
        'grpID': grpID,
        'grpAdminId': grpAdminId,
        'totalCount': totalCount,
        'venueLat': venueLat,
        'venueLon': venueLon,
        'isQuesEnable': isQuesEnable,
        'repeatEventResult':
            repeatEventResult?.map((e) => e.toJson()).toList(),
        'questionArray': questionArray,
        'eventType': eventType,
        'inputIds': inputIds,
        'pubDate': pubDate,
        'expiryDate': expiryDate,
        'eventDate': eventDate,
        'repeatDateTime': repeatDateTime,
        'questionType': questionType,
        'questionText': questionText,
        'option1': option1,
        'option2': option2,
        'questionId': questionId,
        'sendSMSNonSmartPh': sendSMSNonSmartPh,
        'sendSMSAll': sendSMSAll,
        'rsvpEnable': rsvpEnable,
        'displayonbanner': displayonbanner,
        'isAdmin': isAdmin,
        'memberprofileid': memberprofileid,
        'link': link,
      };
}

/// Port of iOS RepeatEvent.h — repeat event date/time.
class RepeatEvent extends BaseModel {
  RepeatEvent({this.eventDate, this.eventTime});

  final String? eventDate;
  final String? eventTime;

  factory RepeatEvent.fromJson(Map<String, dynamic> json) {
    return RepeatEvent(
      eventDate: BaseModel.safeString(json['eventDate']),
      eventTime: BaseModel.safeString(json['eventTime']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'eventDate': eventDate,
        'eventTime': eventTime,
      };
}
