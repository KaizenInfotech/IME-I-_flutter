import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/local_storage.dart';
import '../models/birthday_result.dart';
import '../models/celebration_result.dart';

/// Port of iOS CelebrationViewController server calls — celebrations state management.
/// Matches: getMonthEventList, getMonthEventListTypeWise,
/// getMonthEventListDetails, getEventMinDetails, getTodaysBirthday.
class CelebrationsProvider extends ChangeNotifier {
  // ─── STATE ──────────────────────────────────────────────
  List<CelebrationEvent> _monthEvents = [];
  List<CelebrationEvent> get monthEvents => _monthEvents;

  List<CelebrationEvent> _birthdays = [];
  List<CelebrationEvent> get birthdays => _birthdays;

  List<CelebrationEvent> _anniversaries = [];
  List<CelebrationEvent> get anniversaries => _anniversaries;

  List<CelebrationEvent> _eventsList = [];
  List<CelebrationEvent> get eventsList => _eventsList;

  List<CelebrationEvent> _dateWiseEvents = [];
  List<CelebrationEvent> get dateWiseEvents => _dateWiseEvents;

  CelebrationEvent? _selectedEventDetail;
  CelebrationEvent? get selectedEventDetail => _selectedEventDetail;

  TodaysBirthdayResult? _todaysBirthday;
  TodaysBirthdayResult? get todaysBirthday => _todaysBirthday;

  DateTime _selectedMonth = DateTime.now();
  DateTime get selectedMonth => _selectedMonth;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isBirthdayLoading = false;
  bool get isBirthdayLoading => _isBirthdayLoading;

  bool _isAnniversaryLoading = false;
  bool get isAnniversaryLoading => _isAnniversaryLoading;

  bool _isEventsLoading = false;
  bool get isEventsLoading => _isEventsLoading;

  bool _isDateWiseLoading = false;
  bool get isDateWiseLoading => _isDateWiseLoading;

  String? _error;
  String? get error => _error;

  void setSelectedMonth(DateTime month) {
    _selectedMonth = month;
    notifyListeners();
  }

  // ─── iOS: getMonthEventList → POST Celebrations/GetMonthEventList ──
  Future<bool> fetchMonthEvents({
    required String profileId,
    required String groupId,
    String? selectedDate,
    String updatedOn = '2019/01/01 00:00:00',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final date = selectedDate ??
        '${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}-01';

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.celebrationGetMonthEventList,
        body: {
          'profileId': profileId,
          'groupIds': groupId,
          'selectedDate': date,
          'updatedOns': updatedOn,
          'groupCategory': '2',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = TBEventListResult.fromJson(
            jsonData['TBEventListResult'] as Map<String, dynamic>? ??
                jsonData);

        if (result.isSuccess) {
          _monthEvents = _applyCurrentUserHideFlags([
            ...result.result?.newEvents ?? [],
            ...result.result?.updatedEvents ?? [],
          ]);
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _error = result.message ?? 'Failed to load celebrations';
        }
      } else {
        _error = 'Server error';
      }
    } catch (e) {
      _error = 'Error loading celebrations: $e';
      debugPrint('fetchMonthEvents error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ─── POST Celebrations/GetMonthEventListTypeWise_National (Type: "B") ──
  Future<bool> fetchBirthdays({
    required String groupId,
    String? selectedDate,
  }) async {
    return _fetchTypeWise(
      type: 'B',
      groupId: groupId,
      selectedDate: selectedDate,
      setLoading: (v) => _isBirthdayLoading = v,
      setResult: (events) => _birthdays = events,
      errorLabel: 'birthdays',
    );
  }

  // ─── POST Celebrations/GetMonthEventListTypeWise_National (Type: "A") ──
  Future<bool> fetchAnniversaries({
    required String groupId,
    String? selectedDate,
  }) async {
    return _fetchTypeWise(
      type: 'A',
      groupId: groupId,
      selectedDate: selectedDate,
      setLoading: (v) => _isAnniversaryLoading = v,
      setResult: (events) => _anniversaries = events,
      errorLabel: 'anniversaries',
    );
  }

  // ─── POST Celebrations/GetMonthEventListTypeWise_National (Type: "E") ──
  Future<bool> fetchEvents({
    required String groupId,
    String? selectedDate,
  }) async {
    return _fetchTypeWise(
      type: 'E',
      groupId: groupId,
      selectedDate: selectedDate,
      setLoading: (v) => _isEventsLoading = v,
      setResult: (events) => _eventsList = events,
      errorLabel: 'events',
    );
  }

  /// Shared logic for fetchBirthdays / fetchAnniversaries / fetchEvents.
  /// Always uses Celebrations/GetMonthEventListTypeWise_National
  /// with static groupCategory:"2" and Type: B/A/E.
  Future<bool> _fetchTypeWise({
    required String type,
    required String groupId,
    required String? selectedDate,
    required void Function(bool) setLoading,
    required void Function(List<CelebrationEvent>) setResult,
    required String errorLabel,
  }) async {
    setLoading(true);
    notifyListeners();

    final date = selectedDate ??
        '${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}-${_selectedMonth.day.toString().padLeft(2, '0')}';

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.celebrationGetMonthEventListTypeWiseNational,
        body: {
          'GroupID': groupId,
          'groupCategory': '2',
          'SelectedDate': date,
          'Type': type,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;

        // Log raw event JSON to identify correct member ID key
        final rawResult =
            jsonData['TBEventListTypeResult'] as Map<String, dynamic>? ??
                jsonData;
        final rawEvents = (rawResult['Result']
            as Map<String, dynamic>?)?['Events'] as List?;
        if (rawEvents != null && rawEvents.isNotEmpty) {
          debugPrint(
              'celebrations raw event[0] keys: ${(rawEvents.first as Map).keys.toList()}');
          debugPrint('celebrations raw event[0]: ${rawEvents.first}');
        }

        final result = TBEventListTypeResult.fromJson(rawResult);

        if (result.isSuccess) {
          setResult(_applyCurrentUserHideFlags(result.events ?? []));
          setLoading(false);
          notifyListeners();
          return true;
        } else {
          _error = result.message ?? 'Failed to load $errorLabel';
        }
      } else {
        _error = 'Server error';
      }
    } catch (e) {
      _error = 'Error loading $errorLabel: $e';
      debugPrint('fetch $errorLabel error: $e');
    }

    setLoading(false);
    notifyListeners();
    return false;
  }

  /// Apply current user's hide flags to their own events in the list.
  /// The celebrations API doesn't return hide_whatsnum/hide_num/hide_mail
  /// per event, so we read the current user's values from LocalStorage
  /// (saved by MyProfileScreen on toggle change) and apply them to events
  /// matching the current user's memberID.
  List<CelebrationEvent> _applyCurrentUserHideFlags(
      List<CelebrationEvent> events) {
    final storage = LocalStorage.instance;
    final masterUid = storage.masterUid ?? '';
    final memberProfileId = storage.memberProfileId ?? '';
    final hideWhatsnum = storage.getString('hide_whatsnum');
    final hideNum = storage.getString('hide_num');
    final hideMail = storage.getString('hide_mail');

    // If no hide flags stored yet, return as-is
    if (hideWhatsnum == null && hideNum == null && hideMail == null) {
      return events;
    }
    if (masterUid.isEmpty && memberProfileId.isEmpty) return events;

    debugPrint(
        'applyHideFlags: masterUid=$masterUid, memberProfileId=$memberProfileId, '
        'flags: whats=$hideWhatsnum, num=$hideNum, mail=$hideMail');

    // Celebrations API returns MemberID with "M" prefix (e.g. "M6035"),
    // while masterUid from login is just the number (e.g. "6035").
    // Build all possible ID variants to match against.
    final idsToMatch = <String>{};
    if (masterUid.isNotEmpty) {
      idsToMatch.add(masterUid);
      idsToMatch.add('M$masterUid');
    }
    if (memberProfileId.isNotEmpty) {
      idsToMatch.add(memberProfileId);
      idsToMatch.add('M$memberProfileId');
    }

    debugPrint('applyHideFlags: idsToMatch=$idsToMatch');

    return events.map((event) {
      final id = event.memberID;
      if (id != null && id.isNotEmpty && idsToMatch.contains(id)) {
        debugPrint(
            'applyHideFlags: MATCHED ${event.title} (memberID=$id) → applying flags');
        return event.withHideFlags(
          hideWhatsnum: hideWhatsnum ?? '1',
          hideNum: hideNum ?? '1',
          hideMail: hideMail ?? '1',
        );
      }
      return event;
    }).toList();
  }

  // ─── POST Celebrations/GetMonthEventListDetails_National → day-wise details ──
  Future<bool> fetchDateWiseEvents({
    required String groupId,
    required String selectedDate,
  }) async {
    _isDateWiseLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.celebrationGetMonthEventListDetailsNational,
        body: {
          'GroupID': groupId,
          'SelectedDate': selectedDate,
          'GroupCategory': '2',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = TBEventListDtlsResult.fromJson(
            jsonData['TBEventListDtlsResult'] as Map<String, dynamic>? ??
                jsonData);

        if (result.isSuccess) {
          _dateWiseEvents =
              _applyCurrentUserHideFlags(result.events ?? []);
          _isDateWiseLoading = false;
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
      debugPrint('fetchDateWiseEvents error: $e');
    }

    _isDateWiseLoading = false;
    notifyListeners();
    return false;
  }

  // ─── iOS: getEventMinDetails → POST Celebrations/GetEventMinDetails ──
  Future<bool> fetchEventMinDetails({
    required String eventID,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.celebrationGetEventMinDetails,
        body: {
          'eventID': eventID,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = TBPublicEventResult.fromJson(
            jsonData['TBPublicEventList'] as Map<String, dynamic>? ??
                jsonData);

        if (result.isSuccess) {
          _selectedEventDetail = result.result;
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _error = 'Failed to load event details';
        }
      } else {
        _error = 'Server error';
      }
    } catch (e) {
      _error = 'Error loading event details: $e';
      debugPrint('fetchEventMinDetails error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ─── iOS: getTodaysBirthday → POST Celebrations/GetTodaysBirthday ──
  Future<bool> fetchTodaysBirthday({
    required String groupID,
  }) async {
    try {
      final response = await ApiClient.instance.post(
        ApiConstants.celebrationGetTodaysBirthday,
        body: {
          'groupID': groupID,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        _todaysBirthday = TodaysBirthdayResult.fromJson(
            jsonData['TBMemberListResult'] as Map<String, dynamic>? ??
                jsonData);
        notifyListeners();
        return _todaysBirthday?.isSuccess ?? false;
      }
    } catch (e) {
      debugPrint('fetchTodaysBirthday error: $e');
    }
    return false;
  }

  /// Get events for a specific date from month events
  List<CelebrationEvent> eventsForDate(DateTime date) {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return _monthEvents
        .where((e) => e.eventDate?.startsWith(dateStr) ?? false)
        .toList();
  }

  /// Get unique event dates for calendar markers
  Set<DateTime> get eventDates {
    final dates = <DateTime>{};
    for (final event in _monthEvents) {
      if (event.eventDate != null) {
        try {
          final parts = event.eventDate!.split(' ')[0].split('-');
          if (parts.length >= 3) {
            dates.add(DateTime(
              int.parse(parts[0]),
              int.parse(parts[1]),
              int.parse(parts[2]),
            ));
          }
        } catch (_) {
          // skip malformed dates
        }
      }
    }
    return dates;
  }

  void clearSelectedEvent() {
    _selectedEventDetail = null;
    notifyListeners();
  }

  void clearAll() {
    _monthEvents = [];
    _birthdays = [];
    _anniversaries = [];
    _eventsList = [];
    _dateWiseEvents = [];
    _selectedEventDetail = null;
    _todaysBirthday = null;
    _isLoading = false;
    _isBirthdayLoading = false;
    _isAnniversaryLoading = false;
    _isEventsLoading = false;
    _isDateWiseLoading = false;
    _error = null;
    _selectedMonth = DateTime.now();
    notifyListeners();
  }
}
