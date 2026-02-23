import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/leaderboard_result.dart';

class LeaderboardProvider extends ChangeNotifier {
  // ─── State ──────────────────────────────────────────────
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<ZoneItem> _zones = [];
  List<ZoneItem> get zones => _zones;

  ZoneItem? _selectedZone;
  ZoneItem? get selectedZone => _selectedZone;

  String _selectedYear = '';
  String get selectedYear => _selectedYear;

  List<String> _yearOptions = [];
  List<String> get yearOptions => _yearOptions;

  TBLeaderBoardResult? _leaderboardData;
  TBLeaderBoardResult? get leaderboardData => _leaderboardData;

  String _groupId = '';
  String _profileId = '';

  // ─── Init ───────────────────────────────────────────────
  LeaderboardProvider() {
    _initYears();
  }

  /// Build year options matching iOS: from 2015 to current rotary year,
  /// reversed so most recent first. Rotary year flips in July.
  void _initYears() {
    final now = DateTime.now();
    int endYear = now.year;
    if (now.month >= 7) {
      endYear = now.year + 1;
    }

    final options = <String>[];
    for (int i = 2015; i < endYear; i++) {
      options.add('$i-${i + 1}');
    }
    _yearOptions = options.reversed.toList();

    if (_yearOptions.isNotEmpty) {
      _selectedYear = _yearOptions.first;
    }

    _selectedZone = ZoneItem(pkZoneId: '0', zoneName: 'All');
  }

  /// Short display for the year (e.g. "24-25" from "2024-2025").
  String get displayYear {
    if (_selectedYear.isEmpty) return '';
    final parts = _selectedYear.split('-');
    if (parts.length != 2) return _selectedYear;
    final last1 = parts[0].length >= 2
        ? parts[0].substring(parts[0].length - 2)
        : parts[0];
    final last2 = parts[1].length >= 2
        ? parts[1].substring(parts[1].length - 2)
        : parts[1];
    return '$last1-$last2';
  }

  // ─── Zone / Year selection ─────────────────────────────
  void selectZone(ZoneItem zone) {
    _selectedZone = zone;
    notifyListeners();
    _fetchLeaderboardInternal();
  }

  void selectYear(String year) {
    _selectedYear = year;
    notifyListeners();
    _fetchLeaderboardInternal();
  }

  // ─── Fetch Zone List ────────────────────────────────────
  Future<void> fetchZoneList({required String groupId}) async {
    try {
      final response = await ApiClient.instance.post(
        ApiConstants.getZoneList,
        body: {'grpId': groupId},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = TBZoneListResult.fromJson(jsonData);

        if (result.message != 'failed' && result.list != null) {
          _zones = [
            ZoneItem(pkZoneId: '0', zoneName: 'All'),
            ...result.list!,
          ];
        } else {
          _zones = [ZoneItem(pkZoneId: '0', zoneName: 'All')];
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('fetchZoneList error: $e');
    }
  }

  // ─── Fetch Leaderboard ──────────────────────────────────
  Future<void> fetchLeaderboard({
    required String groupId,
    required String profileId,
  }) async {
    _groupId = groupId;
    _profileId = profileId;
    await _fetchLeaderboardInternal();
  }

  Future<void> _fetchLeaderboardInternal() async {
    if (_groupId.isEmpty) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.getLeaderBoardDetails,
        body: {
          'GroupID': _groupId,
          'RowYear': _selectedYear,
          'ProfileID': _profileId,
          'fk_zoneid': _selectedZone?.pkZoneId ?? '0',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = TBLeaderBoardResult.fromJson(jsonData);

        if (result.status == '0') {
          _leaderboardData = result;
          _error = null;
        } else {
          _leaderboardData = null;
          _error = 'No Record Found';
        }
      } else {
        _error = 'Something went wrong, Please try again later';
      }
    } catch (e) {
      _error = 'Something went wrong, Please try again later';
      debugPrint('fetchLeaderboard error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Initialize: fetch zones + leaderboard together.
  Future<void> initialize({
    required String groupId,
    required String profileId,
  }) async {
    _groupId = groupId;
    _profileId = profileId;
    await Future.wait([
      fetchZoneList(groupId: groupId),
      _fetchLeaderboardInternal(),
    ]);
  }
}
