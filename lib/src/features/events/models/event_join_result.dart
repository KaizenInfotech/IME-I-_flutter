import '../../../core/models/base_model.dart';

/// Port of iOS EventJoinResult.h — RSVP/answer event response.
/// API: Event/AnsweringEvent
/// Response key: "EventJoinResult"
class EventJoinResult extends BaseModel {
  EventJoinResult({
    this.status,
    this.message,
    this.goingCount,
    this.maybeCount,
    this.notgoingCount,
  });

  final String? status;
  final String? message;
  final String? goingCount;
  final String? maybeCount;
  final String? notgoingCount;

  factory EventJoinResult.fromJson(Map<String, dynamic> json) {
    return EventJoinResult(
      status: BaseModel.safeString(json['status']),
      message: BaseModel.safeString(json['message']),
      goingCount: BaseModel.safeString(json['goingCount']),
      maybeCount: BaseModel.safeString(json['maybeCount']),
      notgoingCount: BaseModel.safeString(json['notgoingCount']),
    );
  }

  bool get isSuccess => status == '0';

  @override
  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'goingCount': goingCount,
        'maybeCount': maybeCount,
        'notgoingCount': notgoingCount,
      };
}
