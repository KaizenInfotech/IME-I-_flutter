import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/add_ebulletin_result.dart';
import '../models/ebulletin_list_result.dart';

/// Port of iOS EBulletinListingController + AddEBulletineController logic.
/// Matches: getYearWiseEbulletinList, addEbulletin, delete.
class EbulletinProvider extends ChangeNotifier {
  // ─── STATE ──────────────────────────────────────────────
  List<EbulletinItem> _ebulletins = [];
  List<EbulletinItem> get ebulletins => _ebulletins;

  String? _smsCount;
  String? get smsCount => _smsCount;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  String _selectedYear = '';
  String get selectedYear => _selectedYear;

  List<String> _yearOptions = [];
  List<String> get yearOptions => _yearOptions;

  // ─── iOS: fiscal year calculation (July–June) ──
  void initYearOptions() {
    final now = DateTime.now();
    int endYear = now.year;
    // iOS: if month >= 7, fiscal year ends next year
    if (now.month >= 7) {
      endYear = now.year + 1;
    }

    _yearOptions = [];
    for (int y = 2015; y <= endYear + 1; y++) {
      _yearOptions.add('$y-${y + 1}');
    }
    _yearOptions = _yearOptions.reversed.toList();

    // Default: current fiscal year
    _selectedYear = '${endYear - 1}-$endYear';
  }

  void setSelectedYear(String year) {
    _selectedYear = year;
    notifyListeners();
  }

  // ─── iOS: getYearWiseEbulletinList → POST Ebulletin/GetYearWiseEbulletinList ──
  Future<bool> fetchYearWiseList({
    required String memberProfileId,
    required String groupId,
    String? yearFilter,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.ebulletinGetYearWiseList,
        body: {
          'memberProfileId': memberProfileId,
          'groupId': groupId,
          'YearFilter': yearFilter ?? _selectedYear,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = TBEbulletinListResult.fromJson(
            jsonData['TBYearWiseEbulletinList'] as Map<String, dynamic>? ??
                jsonData);

        if (result.isSuccess) {
          _ebulletins = result.ebulletins ?? [];
          _smsCount = result.smscount;
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _error = result.message ?? 'Failed to load e-bulletins';
        }
      } else {
        _error = 'Server error';
      }
    } catch (e) {
      _error = 'Error loading e-bulletins: $e';
      debugPrint('fetchYearWiseList error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ─── iOS: addEBulletineResult → POST Ebulletin/AddEbulletin ──
  Future<TBAddEbulletinResult?> addEbulletin({
    String ebulletinID = '0',
    required String ebulletinType,
    required String ebulletinTitle,
    String ebulletinlink = '',
    String ebulletinfileid = '0',
    required String memID,
    required String grpID,
    String inputIDs = '',
    required String publishDate,
    String expiryDate = '2099-04-05 15:09:00',
    String sendSMSAll = '0',
    String isSubGrpAdmin = '0',
  }) async {
    try {
      final response = await ApiClient.instance.post(
        ApiConstants.ebulletinAdd,
        body: {
          'ebulletinID': ebulletinID,
          'ebulletinType': ebulletinType,
          'ebulletinTitle': ebulletinTitle,
          'ebulletinlink': ebulletinlink,
          'ebulletinfileid': ebulletinfileid,
          'memID': memID,
          'grpID': grpID,
          'inputIDs': inputIDs,
          'publishDate': publishDate,
          'expiryDate': expiryDate,
          'sendSMSAll': sendSMSAll,
          'isSubGrpAdmin': isSubGrpAdmin,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return TBAddEbulletinResult.fromJson(
            jsonData['TBAddEbulletinResult'] as Map<String, dynamic>? ??
                jsonData);
      }
    } catch (e) {
      debugPrint('addEbulletin error: $e');
    }
    return null;
  }

  // ─── iOS: deleteDataWebservice → POST Group/DeleteByModuleName ──
  Future<bool> deleteEbulletin({
    required String ebulletinId,
    required String profileId,
  }) async {
    try {
      final response = await ApiClient.instance.post(
        ApiConstants.groupDeleteByModuleName,
        body: {
          'typeID': ebulletinId,
          'type': 'Ebulletin',
          'profileID': profileId,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final status = jsonData['status']?.toString();
        if (status == '0') {
          _ebulletins.removeWhere((e) => e.ebulletinID == ebulletinId);
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      debugPrint('deleteEbulletin error: $e');
    }
    return false;
  }

  /// Client-side search filter matching iOS NSPredicate on ebulletinTitle
  List<EbulletinItem> searchEbulletins(String query) {
    if (query.isEmpty) return _ebulletins;
    final lower = query.toLowerCase();
    return _ebulletins
        .where((e) =>
            e.ebulletinTitle?.toLowerCase().contains(lower) == true)
        .toList();
  }

  void clearAll() {
    _ebulletins = [];
    _isLoading = false;
    _error = null;
    _smsCount = null;
    notifyListeners();
  }
}
