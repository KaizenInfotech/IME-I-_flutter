import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/attendance_result.dart';

/// Port of iOS AttendanceViewController + AttendanceEditViewController logic.
/// Matches: GetAttendanceListNew, getAttendanceDetails, AttendanceDelete.
class AttendanceProvider extends ChangeNotifier {
  // ─── STATE ──────────────────────────────────────────────
  List<AttendanceItem> _attendanceList = [];
  List<AttendanceItem> get attendanceList => _attendanceList;

  AttendanceDetail? _selectedDetail;
  AttendanceDetail? get selectedDetail => _selectedDetail;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // ─── Android: EventAttendanceActivity — POST Attendance/GetAttendanceListNew
  // Params: GroupId only
  Future<bool> fetchAttendanceList({
    required String groupId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.attendanceGetList,
        body: {
          'GroupId': groupId,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = TBAttendanceListResult.fromJson(
            jsonData['TBAttendanceListResult'] as Map<String, dynamic>? ??
                jsonData);

        if (result.isSuccess) {
          _attendanceList = result.attendanceList ?? [];
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _error = result.message ?? 'Failed to load attendance';
        }
      } else {
        _error = 'Server error';
      }
    } catch (e) {
      _error = 'Error loading attendance: $e';
      debugPrint('fetchAttendanceList error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ─── iOS: functionForFetchingAttendanceDetailData ──
  // POST Attendance/getAttendanceDetails with AttendanceID
  Future<bool> fetchAttendanceDetails({
    required String attendanceId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.attendanceGetDetails,
        body: {
          'AttendanceID': attendanceId,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = TBAttendanceDetailsResult.fromJson(
            jsonData['TBAttendanceDetailsResult'] as Map<String, dynamic>? ??
                jsonData);

        if (result.isSuccess) {
          _selectedDetail = result.detail;
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _error = result.message ?? 'Failed to load details';
        }
      } else {
        _error = 'Server error';
      }
    } catch (e) {
      _error = 'Error loading attendance details: $e';
      debugPrint('fetchAttendanceDetails error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ─── iOS: functionForDeletingAttendance ──
  // POST Attendance/AttendanceDelete with AttendanceID, createdBy
  Future<bool> deleteAttendance({
    required String attendanceId,
    required String createdBy,
  }) async {
    try {
      final response = await ApiClient.instance.post(
        ApiConstants.attendanceDelete,
        body: {
          'AttendanceID': attendanceId,
          'createdBy': createdBy,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final status = jsonData['status']?.toString();
        if (status == '0') {
          _attendanceList
              .removeWhere((a) => a.attendanceID == attendanceId);
          _selectedDetail = null;
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      debugPrint('deleteAttendance error: $e');
    }
    return false;
  }

  // ─── Android: AttendanceMembersDetailsActivity — POST GetAttendanceMemberDetails
  // Params: AttendanceID, type=1
  List<AttendanceMemberItem> _membersList = [];
  List<AttendanceMemberItem> get membersList => _membersList;

  Future<bool> fetchAttendanceMembers({
    required String attendanceId,
  }) async {
    _isLoading = true;
    _error = null;
    _membersList = [];
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.attendanceGetMemberDetails,
        body: {
          'AttendanceID': attendanceId,
          'type': '1',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = jsonData['TBAttendanceMemberDetailsResult']
                as Map<String, dynamic>? ??
            jsonData;
        final status = result['status']?.toString();

        if (status == '0') {
          final list =
              result['AttendanceMemberResult'] as List<dynamic>? ?? [];
          _membersList = list
              .map((e) =>
                  AttendanceMemberItem.fromJson(e as Map<String, dynamic>))
              .toList();
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _error = result['message']?.toString() ?? 'Failed to load members';
        }
      } else {
        _error = 'Server error';
      }
    } catch (e) {
      _error = 'Error loading members: $e';
      debugPrint('fetchAttendanceMembers error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ─── Android: AttendanceVisitorsDetailsActivity — POST GetAttendanceVisitorsDetails
  // Params: AttendanceID, type=2
  List<AttendanceVisitorItem> _visitorsList = [];
  List<AttendanceVisitorItem> get visitorsList => _visitorsList;

  Future<bool> fetchAttendanceVisitors({
    required String attendanceId,
  }) async {
    _isLoading = true;
    _error = null;
    _visitorsList = [];
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.attendanceGetVisitorsDetails,
        body: {
          'AttendanceID': attendanceId,
          'type': '2',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = jsonData['TBAttendanceVisitorsDetailsResult']
                as Map<String, dynamic>? ??
            jsonData;
        final status = result['status']?.toString();

        if (status == '0') {
          final list =
              result['AttendanceVisitorsResult'] as List<dynamic>? ?? [];
          _visitorsList = list
              .map((e) =>
                  AttendanceVisitorItem.fromJson(e as Map<String, dynamic>))
              .toList();
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _error = result['message']?.toString() ?? 'Failed to load visitors';
        }
      } else {
        _error = 'Server error';
      }
    } catch (e) {
      _error = 'Error loading visitors: $e';
      debugPrint('fetchAttendanceVisitors error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  void clearSelectedDetail() {
    _selectedDetail = null;
    notifyListeners();
  }

  void clearAll() {
    _attendanceList = [];
    _selectedDetail = null;
    _membersList = [];
    _visitorsList = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
