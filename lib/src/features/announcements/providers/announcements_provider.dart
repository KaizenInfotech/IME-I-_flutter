import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/add_announcement_result.dart';
import '../models/announcement_list_result.dart';

/// Port of iOS WebserviceClass announcement methods — announcements state management.
/// Matches: getAllAnnouncementOFUSer, getAnnouceDetail, addAnnouncementResult.
class AnnouncementsProvider extends ChangeNotifier {
  // ─── STATE ──────────────────────────────────────────────
  List<AnnounceList> _announcements = [];
  List<AnnounceList> get announcements => _announcements;

  AnnounceList? _selectedAnnouncement;
  AnnounceList? get selectedAnnouncement => _selectedAnnouncement;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  String? _smsCount;
  String? get smsCount => _smsCount;

  // ─── Android: POST Announcement/GetAnnouncementList ──
  // Params: memberProfileId (MEM_PROFILE_ID), groupId (GROUP_ID), searchText, moduleId ("3")
  Future<bool> fetchAnnouncements({
    required String groupId,
    required String memberProfileId,
    String searchText = '',
    String moduleId = '3',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.announcementGetList,
        body: {
          'groupId': groupId,
          'memberProfileId': memberProfileId,
          'searchText': searchText,
          'moduleId': moduleId,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = TBAnnounceListResult.fromJson(
            jsonData['TBAnnounceListResult'] as Map<String, dynamic>? ??
                jsonData);

        if (result.isSuccess) {
          _announcements = result.announcements ?? [];
          _smsCount = result.smscount;
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _error = result.message ?? 'Failed to load announcements';
        }
      } else {
        _error = 'Server error';
      }
    } catch (e) {
      _error = 'Error loading announcements: $e';
      debugPrint('fetchAnnouncements error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ─── iOS: getAnnouceDetail → POST Announcement/GetAnnouncementDetails ──
  Future<bool> fetchAnnouncementDetail({
    required String announID,
    required String grpID,
    required String memberProfileID,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.announcementGetDetails,
        body: {
          'announID': announID,
          'grpID': grpID,
          'memberProfileID': memberProfileID,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = TBAnnounceListResult.fromJson(
            jsonData['TBAnnounceListResult'] as Map<String, dynamic>? ??
                jsonData);

        if (result.isSuccess) {
          _selectedAnnouncement = result.firstAnnouncement;
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _error = result.message ?? 'Failed to load announcement details';
        }
      } else {
        _error = 'Server error';
      }
    } catch (e) {
      _error = 'Error loading announcement details: $e';
      debugPrint('fetchAnnouncementDetail error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ─── iOS: addAnnouncementResult → POST Announcement/AddAnnouncement ──
  // ALL parameters from iOS AddAnnounceController
  Future<TBAddAnnouncementResult?> addAnnouncement({
    required String announID,
    required String annType,
    required String announTitle,
    required String announceDEsc,
    required String memID,
    required String grpID,
    required String inputIDs,
    required String announImg,
    required String publishDate,
    required String expiryDate,
    required String sendSMSNonSmartPh,
    required String sendSMSAll,
    required String moduleId,
    required String announcementRepeatDates,
    String reglink = '',
    String isSubGrpAdmin = '0',
  }) async {
    try {
      final response = await ApiClient.instance.post(
        ApiConstants.announcementAdd,
        body: {
          'announID': announID,
          'annType': annType,
          'announTitle': announTitle,
          'announceDEsc': announceDEsc,
          'memID': memID,
          'grpID': grpID,
          'inputIDs': inputIDs,
          'announImg': announImg,
          'publishDate': publishDate,
          'expiryDate': expiryDate,
          'sendSMSNonSmartPh': sendSMSNonSmartPh,
          'sendSMSAll': sendSMSAll,
          'moduleId': moduleId,
          'AnnouncementRepeatDates': announcementRepeatDates,
          'reglink': reglink,
          'isSubGrpAdmin': isSubGrpAdmin,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return TBAddAnnouncementResult.fromJson(
            jsonData['TBAddAnnouncementResult'] as Map<String, dynamic>? ??
                jsonData);
      }
    } catch (e) {
      debugPrint('addAnnouncement error: $e');
    }
    return null;
  }

  /// Search announcements
  Future<void> searchAnnouncements({
    required String groupId,
    required String memberProfileId,
    required String query,
    String moduleId = '3',
  }) async {
    await fetchAnnouncements(
      groupId: groupId,
      memberProfileId: memberProfileId,
      searchText: query,
      moduleId: moduleId,
    );
  }

  void clearSelectedAnnouncement() {
    _selectedAnnouncement = null;
    notifyListeners();
  }

  void clearAll() {
    _announcements = [];
    _selectedAnnouncement = null;
    _isLoading = false;
    _error = null;
    _smsCount = null;
    notifyListeners();
  }
}
