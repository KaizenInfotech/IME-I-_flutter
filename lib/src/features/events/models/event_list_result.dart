import '../../../core/models/base_model.dart';

/// Port of iOS EventListDetailResult.h — paginated event list response.
/// API: Event/GetEventList
/// Response key: "EventListDetailResult"
class EventListDetailResult extends BaseModel {
  EventListDetailResult({
    this.status,
    this.message,
    this.smsCount,
    this.resultCount,
    this.totalPages,
    this.currentPage,
    this.eventsListResult,
    this.link,
  });

  final String? status;
  final String? message;
  final String? smsCount;
  final String? resultCount;
  final String? totalPages;
  final String? currentPage;
  final List<EventListItem>? eventsListResult;
  final String? link;

  factory EventListDetailResult.fromJson(Map<String, dynamic> json) {
    return EventListDetailResult(
      status: BaseModel.safeString(json['status']),
      message: BaseModel.safeString(json['message']),
      smsCount: BaseModel.safeString(json['SMSCount']),
      resultCount: BaseModel.safeString(json['resultCount']),
      totalPages: BaseModel.safeString(json['TotalPages']),
      currentPage: BaseModel.safeString(json['currentPage']),
      eventsListResult: BaseModel.safeList(
          json['EventsListResult'], EventListItem.fromJson),
      link: BaseModel.safeString(json['link']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'SMSCount': smsCount,
        'resultCount': resultCount,
        'TotalPages': totalPages,
        'currentPage': currentPage,
        'EventsListResult':
            eventsListResult?.map((e) => e.toJson()).toList(),
        'link': link,
      };
}

/// Port of iOS EventList.h — single event in list view.
/// Fields: eventID, eventImg, eventTitle, eventDateTime, goingCount, maybeCount,
/// notgoingCount, venue, myResponse, filterType, grpID, isRead, venueLat, venueLon, grpAdminId
class EventListItem extends BaseModel {
  EventListItem({
    this.eventID,
    this.eventImg,
    this.eventTitle,
    this.eventDateTime,
    this.goingCount,
    this.maybeCount,
    this.notgoingCount,
    this.venue,
    this.myResponse,
    this.filterType,
    this.grpID,
    this.isRead,
    this.venueLat,
    this.venueLon,
    this.grpAdminId,
  });

  final String? eventID;
  final String? eventImg;
  final String? eventTitle;
  final String? eventDateTime;
  final String? goingCount;
  final String? maybeCount;
  final String? notgoingCount;
  final String? venue;
  final String? myResponse;
  final String? filterType;
  final String? grpID;
  final String? isRead;
  final String? venueLat;
  final String? venueLon;
  final String? grpAdminId;

  factory EventListItem.fromJson(Map<String, dynamic> json) {
    return EventListItem(
      eventID: BaseModel.safeString(json['eventID']),
      eventImg: BaseModel.safeString(json['eventImg']),
      eventTitle: BaseModel.safeString(json['eventTitle']),
      eventDateTime: BaseModel.safeString(json['eventDateTime']),
      goingCount: BaseModel.safeString(json['goingCount']),
      maybeCount: BaseModel.safeString(json['maybeCount']),
      notgoingCount: BaseModel.safeString(json['notgoingCount']),
      venue: BaseModel.safeString(json['venue']),
      myResponse: BaseModel.safeString(json['myResponse']),
      filterType: BaseModel.safeString(json['filterType']),
      grpID: BaseModel.safeString(json['grpID']),
      isRead: BaseModel.safeString(json['isRead']),
      venueLat: BaseModel.safeString(json['venueLat']),
      venueLon: BaseModel.safeString(json['venueLon']),
      grpAdminId: BaseModel.safeString(json['grpAdminId']),
    );
  }

  /// iOS: filterType "3" = expired event
  bool get isExpired => filterType == '3';

  /// iOS: checks if event has valid image URL
  bool get hasValidImage =>
      eventImg != null && eventImg!.isNotEmpty && eventImg != 'null';

  /// iOS: format date from "yyyy-MM-dd HH:mm:ss" for display
  String get displayDateTime => eventDateTime ?? '';

  /// iOS: total RSVP count
  int get totalCount =>
      (int.tryParse(goingCount ?? '0') ?? 0) +
      (int.tryParse(maybeCount ?? '0') ?? 0) +
      (int.tryParse(notgoingCount ?? '0') ?? 0);

  @override
  Map<String, dynamic> toJson() => {
        'eventID': eventID,
        'eventImg': eventImg,
        'eventTitle': eventTitle,
        'eventDateTime': eventDateTime,
        'goingCount': goingCount,
        'maybeCount': maybeCount,
        'notgoingCount': notgoingCount,
        'venue': venue,
        'myResponse': myResponse,
        'filterType': filterType,
        'grpID': grpID,
        'isRead': isRead,
        'venueLat': venueLat,
        'venueLon': venueLon,
        'grpAdminId': grpAdminId,
      };
}
