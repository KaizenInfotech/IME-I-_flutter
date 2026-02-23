import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/club_result.dart';

/// Port of iOS AnyClubNewViewController + InfoSegmentFindAClubViewController
/// data logic — club search, near-me, club details, members.
class FindClubProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  // Search results
  List<ClubItem> _clubs = [];
  List<ClubItem> _filteredClubs = [];
  String _searchQuery = '';

  // Club detail
  ClubDetail? _selectedDetail;
  bool _isLoadingDetail = false;

  // Club members
  List<ClubMember> _clubMembers = [];
  bool _isLoadingMembers = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ClubItem> get clubs =>
      _searchQuery.isEmpty ? _clubs : _filteredClubs;
  ClubDetail? get selectedDetail => _selectedDetail;
  bool get isLoadingDetail => _isLoadingDetail;
  List<ClubMember> get clubMembers => _clubMembers;
  bool get isLoadingMembers => _isLoadingMembers;

  /// iOS: functionForSearchFindAclub() — search clubs by criteria.
  /// API: FindClub/GetClubList (POST)
  /// Parameters: keyword, country, stateProvinceCity, district
  Future<void> fetchClubList({
    String keyword = '',
    String country = '',
    String stateProvinceCity = '',
    String district = '',
  }) async {
    _isLoading = true;
    _error = null;
    _searchQuery = '';
    notifyListeners();

    try {
      final params = <String, String>{
        'keyword': keyword,
        'country': country,
        'stateProvinceCity': stateProvinceCity,
        'district': district,
      };

      final response = await ApiClient.instance.post(
        ApiConstants.findClubGetClubList,
        body: params,
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = TBGetClubResult.fromJson(
            jsonData['TBGetClubResult'] as Map<String, dynamic>? ?? jsonData);
        if (result.isSuccess) {
          _clubs = result.clubs ?? [];
          _filteredClubs = _clubs;
        } else {
          _clubs = [];
          _error = result.message ?? 'No clubs found';
        }
      } else {
        _error = 'Server error';
      }
    } catch (e) {
      _error = 'Failed to search clubs';
      debugPrint('fetchClubList error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// iOS: Near me search — uses device location.
  /// API: FindClub/GetClubsNearMe (POST)
  Future<void> fetchClubsNearMe({
    required double latitude,
    required double longitude,
  }) async {
    _isLoading = true;
    _error = null;
    _searchQuery = '';
    notifyListeners();

    try {
      final params = <String, String>{
        'lat': latitude.toString(),
        'longi': longitude.toString(),
      };

      final response = await ApiClient.instance.post(
        ApiConstants.findClubGetClubsNearMe,
        body: params,
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = TBGetClubResult.fromJson(
            jsonData['TBGetClubResult'] as Map<String, dynamic>? ?? jsonData);
        if (result.isSuccess) {
          _clubs = result.clubs ?? [];
          _filteredClubs = _clubs;
        } else {
          _clubs = [];
          _error = result.message ?? 'No clubs found nearby';
        }
      } else {
        _error = 'Server error';
      }
    } catch (e) {
      _error = 'Failed to find nearby clubs';
      debugPrint('fetchClubsNearMe error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// iOS: SearchBar text change — client-side filter on club name / meeting day.
  void searchClubs(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredClubs = _clubs;
    } else {
      final lower = query.toLowerCase();
      _filteredClubs = _clubs.where((c) {
        final name = c.clubName?.toLowerCase() ?? '';
        final meeting = c.meetingDay?.toLowerCase() ?? '';
        return name.contains(lower) || meeting.contains(lower);
      }).toList();
    }
    notifyListeners();
  }

  /// iOS: InfoSegmentFindAClubViewController — fetch club details.
  /// API: FindClub/GetClubDetails (POST)
  /// Parameter: grpId
  Future<void> fetchClubDetails({required String grpId}) async {
    _isLoadingDetail = true;
    _selectedDetail = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.findClubGetClubDetails,
        body: {'grpId': grpId},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = TBGetClubDetailResult.fromJson(
            jsonData['TBGetClubDetailResult'] as Map<String, dynamic>? ??
                jsonData);
        if (result.isSuccess) {
          _selectedDetail = result.detail;
        }
      }
    } catch (e) {
      debugPrint('fetchClubDetails error: $e');
    }

    _isLoadingDetail = false;
    notifyListeners();
  }

  /// iOS: MemberSegmentViewController — fetch club members.
  /// API: FindClub/GetClubMembers (POST)
  /// Parameter: grpId
  Future<void> fetchClubMembers({required String grpId}) async {
    _isLoadingMembers = true;
    _clubMembers = [];
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.findClubGetClubMembers,
        body: {'grpId': grpId},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final memberList = jsonData['MemberResult'] as List<dynamic>?;
        if (memberList != null) {
          _clubMembers = memberList
              .map((e) => ClubMember.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('fetchClubMembers error: $e');
    }

    _isLoadingMembers = false;
    notifyListeners();
  }

  /// iOS: GetPublicAlbumsList — fetch public albums for a club.
  /// API: FindClub/GetPublicAlbumsList (POST)
  Future<List<Map<String, dynamic>>> fetchPublicAlbums({
    required String grpId,
  }) async {
    try {
      final response = await ApiClient.instance.post(
        ApiConstants.findClubGetPublicAlbumsList,
        body: {'grpId': grpId},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final list = jsonData['AlbumResult'] as List<dynamic>? ??
            jsonData['albums'] as List<dynamic>? ??
            [];
        return list.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint('fetchPublicAlbums error: $e');
    }
    return [];
  }

  /// iOS: GetPublicEventsList — fetch public events for a club.
  /// API: FindClub/GetPublicEventsList (POST)
  Future<List<Map<String, dynamic>>> fetchPublicEvents({
    required String grpId,
  }) async {
    try {
      final response = await ApiClient.instance.post(
        ApiConstants.findClubGetPublicEventsList,
        body: {'grpId': grpId},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final list = jsonData['EventResult'] as List<dynamic>? ??
            jsonData['events'] as List<dynamic>? ??
            [];
        return list.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint('fetchPublicEvents error: $e');
    }
    return [];
  }

  /// iOS: GetPublicNewsletterList — fetch public newsletters for a club.
  /// API: FindClub/GetPublicNewsletterList (POST)
  Future<List<Map<String, dynamic>>> fetchPublicNewsletters({
    required String grpId,
  }) async {
    try {
      final response = await ApiClient.instance.post(
        ApiConstants.findClubGetPublicNewsletterList,
        body: {'grpId': grpId},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final list = jsonData['NewsletterResult'] as List<dynamic>? ??
            jsonData['newsletters'] as List<dynamic>? ??
            [];
        return list.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint('fetchPublicNewsletters error: $e');
    }
    return [];
  }

  /// Clear search results.
  void clearResults() {
    _clubs = [];
    _filteredClubs = [];
    _searchQuery = '';
    notifyListeners();
  }
}
