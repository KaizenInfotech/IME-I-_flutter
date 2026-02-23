import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/add_event_result.dart';
import '../models/event_detail_result.dart';
import '../models/event_join_result.dart';
import '../models/event_list_result.dart';

/// Port of iOS WebserviceClass event methods — events state management.
/// Matches: getEventListofUserGrp, getEventsDetail, addEventsResult,
/// getQuestionsAnswering, getSMSCountDetailWebService.
class EventsProvider extends ChangeNotifier {
  // ─── STATE ──────────────────────────────────────────────
  List<EventListItem> _events = [];
  List<EventListItem> get events => _events;

  EventsDetail? _selectedEvent;
  EventsDetail? get selectedEvent => _selectedEvent;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  String? _error;
  String? get error => _error;

  int _currentPage = 1;
  bool _hasMorePages = true;
  bool get hasMorePages => _hasMorePages;

  String? _smsCount;
  String? get smsCount => _smsCount;

  String? _resultCount;
  String? get resultCount => _resultCount;

  // ─── iOS: getEventListofUserGrp → POST Event/GetEventList ──
  Future<bool> fetchEventList({
    required String groupProfileID,
    required String grpId,
    String type = '0',
    String admin = '0',
    String searchText = '',
    int page = 1,
  }) async {
    if (page == 1) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.eventGetEventList,
        body: {
          'groupProfileID': groupProfileID,
          'grpId': grpId,
          'Type': type,
          'Admin': admin,
          'searchText': searchText,
          'pageIndex': page.toString(),
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = EventListDetailResult.fromJson(
            jsonData['EventListDetailResult'] as Map<String, dynamic>? ??
                jsonData);

        if (result.status == '0') {
          final newEvents = result.eventsListResult ?? [];

          if (page == 1) {
            _events = newEvents;
          } else {
            _events.addAll(newEvents);
          }

          _currentPage = page;
          _smsCount = result.smsCount;
          _resultCount = result.resultCount;

          final totalPages = int.tryParse(result.totalPages ?? '1') ?? 1;
          _hasMorePages = page < totalPages;

          _isLoading = false;
          _isLoadingMore = false;
          notifyListeners();
          return true;
        } else {
          _error = result.message ?? 'Failed to load events';
        }
      } else {
        _error = 'Server error';
      }
    } catch (e) {
      _error = 'Error loading events: $e';
      debugPrint('fetchEventList error: $e');
    }

    _isLoading = false;
    _isLoadingMore = false;
    notifyListeners();
    return false;
  }

  /// iOS: scrollViewDidEndDragging — load next page
  Future<void> loadMoreEvents({
    required String groupProfileID,
    required String grpId,
    String type = '0',
    String admin = '0',
    String searchText = '',
  }) async {
    if (_isLoadingMore || !_hasMorePages) return;
    _isLoadingMore = true;
    notifyListeners();

    await fetchEventList(
      groupProfileID: groupProfileID,
      grpId: grpId,
      type: type,
      admin: admin,
      searchText: searchText,
      page: _currentPage + 1,
    );
  }

  /// iOS: search with text
  Future<void> searchEvents({
    required String groupProfileID,
    required String grpId,
    required String query,
    String type = '0',
    String admin = '0',
  }) async {
    await fetchEventList(
      groupProfileID: groupProfileID,
      grpId: grpId,
      type: type,
      admin: admin,
      searchText: query,
      page: 1,
    );
  }

  // ─── iOS: getEventsDetail → POST Event/GetEventDetails ──
  Future<bool> fetchEventDetail({
    required String groupProfileID,
    required String eventID,
    required String grpId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.eventGetEventDetails,
        body: {
          'groupProfileID': groupProfileID,
          'eventID': eventID,
          'grpId': grpId,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = EventsListDetailResult.fromJson(
            jsonData['EventsListDetailResult'] as Map<String, dynamic>? ??
                jsonData);

        if (result.status == '0') {
          _selectedEvent = result.firstDetail;
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _error = result.message ?? 'Failed to load event details';
        }
      } else {
        _error = 'Server error';
      }
    } catch (e) {
      _error = 'Error loading event details: $e';
      debugPrint('fetchEventDetail error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ─── iOS: addEventsResult → POST Event/AddEvent_New ──
  // ALL 25+ parameters from iOS AddEventsController
  Future<AddEventResult?> addEvent({
    required String eventID,
    required String questionEnable,
    required String eventType,
    required String membersIDs,
    required String eventImageID,
    required String evntTitle,
    required String evntDesc,
    required String eventVenue,
    required String venueLat,
    required String venueLong,
    required String evntDate,
    required String publishDate,
    required String expiryDate,
    required String notifyDate,
    required String userID,
    required String grpID,
    required String repeatDateTime,
    required String questionType,
    required String questionText,
    required String option1,
    required String option2,
    required String sendSMSNonSmartPh,
    required String sendSMSAll,
    required int rsvpEnable,
    required String displayOnBanners,
    required String link,
    required String isSubGrpAdmin,
  }) async {
    try {
      final response = await ApiClient.instance.post(
        ApiConstants.eventAddEventNew,
        body: {
          'eventID': eventID,
          'questionEnable': questionEnable,
          'eventType': eventType,
          'membersIDs': membersIDs,
          'eventImageID': eventImageID,
          'evntTitle': evntTitle,
          'evntDesc': evntDesc,
          'eventVenue': eventVenue,
          'venueLat': venueLat,
          'venueLong': venueLong,
          'evntDate': evntDate,
          'evntTime': '',
          'publishDate': publishDate,
          'publishTime': '',
          'expiryDate': expiryDate,
          'expiryTime': '',
          'notifyDate': notifyDate,
          'notifyTime': '',
          'userID': userID,
          'grpID': grpID,
          'RepeatDateTime': repeatDateTime,
          'questionType': questionType,
          'questionText': questionText,
          'option1': option1,
          'option2': option2,
          'sendSMSNonSmartPh': sendSMSNonSmartPh,
          'sendSMSAll': sendSMSAll,
          'rsvpEnable': rsvpEnable.toString(),
          'displayonbanner': displayOnBanners,
          'reglink': link,
          'isSubGrpAdmin': isSubGrpAdmin,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return AddEventResult.fromJson(
            jsonData['AddEventResult'] as Map<String, dynamic>? ?? jsonData);
      }
    } catch (e) {
      debugPrint('addEvent error: $e');
    }
    return null;
  }

  // ─── iOS: getQuestionsAnswering → POST Event/AnsweringEvent ──
  Future<EventJoinResult?> answerEvent({
    required String grpId,
    required String profileID,
    required String eventId,
    required String joiningStatus,
    String questionId = '',
    String answerByme = '',
  }) async {
    try {
      final response = await ApiClient.instance.post(
        ApiConstants.eventAnsweringEvent,
        body: {
          'grpId': grpId,
          'profileID': profileID,
          'eventId': eventId,
          'joiningStatus': joiningStatus,
          'questionId': questionId,
          'answerByme': answerByme,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = EventJoinResult.fromJson(
            jsonData['EventJoinResult'] as Map<String, dynamic>? ?? jsonData);

        if (result.isSuccess && _selectedEvent != null) {
          // Update local event detail with new counts
          _selectedEvent = EventsDetail.fromJson({
            ..._selectedEvent!.toJson(),
            'goingCount': result.goingCount,
            'maybeCount': result.maybeCount,
            'notgoingCount': result.notgoingCount,
            'myResponse': joiningStatus,
          });
          notifyListeners();
        }

        return result;
      }
    } catch (e) {
      debugPrint('answerEvent error: $e');
    }
    return null;
  }

  // ─── iOS: getSMSCountDetailWebService → POST Event/Getsmscountdetails ──
  Future<String?> getSmsCount({
    required String grpId,
    required String profileID,
  }) async {
    try {
      final response = await ApiClient.instance.post(
        ApiConstants.eventGetSmsCountDetails,
        body: {
          'grpId': grpId,
          'profileID': profileID,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        _smsCount = jsonData['SMSCount']?.toString();
        notifyListeners();
        return _smsCount;
      }
    } catch (e) {
      debugPrint('getSmsCount error: $e');
    }
    return null;
  }

  /// Clear selected event
  void clearSelectedEvent() {
    _selectedEvent = null;
    notifyListeners();
  }

  /// Clear all state
  void clearAll() {
    _events = [];
    _selectedEvent = null;
    _isLoading = false;
    _isLoadingMore = false;
    _error = null;
    _currentPage = 1;
    _hasMorePages = true;
    _smsCount = null;
    _resultCount = null;
    notifyListeners();
  }
}
