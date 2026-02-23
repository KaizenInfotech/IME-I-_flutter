import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/rotarian_result.dart';

/// Port of iOS FinddArotarianViewController + SearchFindArotarianViewController
/// data logic — cascading zone/chapter dropdowns, rotarian search, details.
class FindRotarianProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  // Zone / Chapter dropdown data
  List<ZoneItem> _zones = [];
  List<ChapterItem> _allChapters = [];
  List<ChapterItem> _filteredChapters = [];
  ZoneItem? _selectedZone;
  ChapterItem? _selectedChapter;

  // Search results
  List<RotarianItem> _rotarians = [];
  List<RotarianItem> _filteredRotarians = [];
  String _searchQuery = '';

  // Detail
  RotarianDetail? _selectedDetail;
  bool _isLoadingDetail = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ZoneItem> get zones => _zones;
  List<ChapterItem> get filteredChapters => _filteredChapters;
  ZoneItem? get selectedZone => _selectedZone;
  ChapterItem? get selectedChapter => _selectedChapter;
  List<RotarianItem> get rotarians =>
      _searchQuery.isEmpty ? _rotarians : _filteredRotarians;
  RotarianDetail? get selectedDetail => _selectedDetail;
  bool get isLoadingDetail => _isLoadingDetail;

  /// iOS: GetDropDownList() — fetches all zones and chapters.
  /// API: FindRotarian/GetZonechapterlist (GET-style, but uses POST)
  Future<void> fetchZoneChapterList() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.findRotarianGetZoneChapterList,
        body: {},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = TBZoneChapterResult.fromJson(
            jsonData['ZoneChapterResult'] as Map<String, dynamic>? ??
                jsonData);
        _zones = result.zones ?? [];
        _allChapters = result.chapters ?? [];
        _filteredChapters = [];
        _selectedZone = null;
        _selectedChapter = null;
      } else {
        _error = 'Server error';
      }
    } catch (e) {
      _error = 'Failed to load zones and chapters';
      debugPrint('fetchZoneChapterList error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// iOS: pickerView(didSelectRow) for zone — filters chapters by ZoneID.
  void selectZone(ZoneItem? zone) {
    _selectedZone = zone;
    _selectedChapter = null;

    if (zone != null && zone.zoneID != null) {
      // iOS: getChapterList() — filter mainArrr where chapter.ZoneID == selectedZoneID
      _filteredChapters = _allChapters
          .where((c) => c.zoneID == zone.zoneID)
          .toList();
    } else {
      _filteredChapters = [];
    }

    notifyListeners();
  }

  /// iOS: pickerView(didSelectRow) for chapter.
  void selectChapter(ChapterItem? chapter) {
    _selectedChapter = chapter;
    notifyListeners();
  }

  /// iOS: functionForSearchFindAclub() — search rotarians.
  /// API: FindRotarian/GetRotarianList (POST)
  /// Parameters: name, Grade, memberMobile, club, Category
  Future<void> fetchRotarianList({
    String name = '',
    String grade = '',
    String memberMobile = '',
    String club = '',
    String category = '',
  }) async {
    _isLoading = true;
    _error = null;
    _searchQuery = '';
    notifyListeners();

    try {
      final params = <String, String>{
        'name': name,
        'Grade': grade,
        'memberMobile': memberMobile,
        'club': club,
        'Category': category,
      };

      final response = await ApiClient.instance.post(
        ApiConstants.findRotarianGetList,
        body: params,
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = TBGetRotarianResult.fromJson(
            jsonData['TBGetRotarianResult'] as Map<String, dynamic>? ??
                jsonData);
        if (result.isSuccess) {
          _rotarians = result.rotarians ?? [];
          _filteredRotarians = _rotarians;
        } else {
          _rotarians = [];
          _error = result.message ?? 'No results found';
        }
      } else {
        _error = 'Server error';
      }
    } catch (e) {
      _error = 'Failed to search rotarians';
      debugPrint('fetchRotarianList error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// iOS: SearchBar text change — client-side filter on memberName.
  void searchRotarians(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredRotarians = _rotarians;
    } else {
      final lower = query.toLowerCase();
      _filteredRotarians = _rotarians.where((r) {
        final name = r.memberName?.toLowerCase() ?? '';
        final club = r.clubName?.toLowerCase() ?? '';
        return name.contains(lower) || club.contains(lower);
      }).toList();
    }
    notifyListeners();
  }

  /// iOS: RotarianProfileBusinessDetailsViewController.functionForGetRotarianDetails()
  /// API: FindRotarian/GetrotarianDetails (POST, lowercase 'r')
  /// Parameter: memberProfileId
  Future<void> fetchRotarianDetails({
    required String memberProfileId,
  }) async {
    _isLoadingDetail = true;
    _selectedDetail = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.findRotarianGetDetailsAlt,
        body: {'memberProfileId': memberProfileId},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        // iOS: response → TBGetRotarianResult → { status, message, Result → { Table: [...] } }
        final wrapper =
            jsonData['TBGetRotarianResult'] as Map<String, dynamic>? ??
                jsonData;
        final result = TBRotarianDetailResult.fromJson(wrapper);
        if (result.isSuccess) {
          _selectedDetail = result.detail;
        }
      }
    } catch (e) {
      debugPrint('fetchRotarianDetails error: $e');
    }

    _isLoadingDetail = false;
    notifyListeners();
  }

  /// Clear search results when navigating back.
  void clearResults() {
    _rotarians = [];
    _filteredRotarians = [];
    _searchQuery = '';
    notifyListeners();
  }

  // ─── Find Member dropdown data (IMEI modules) ─────────────────

  List<DropdownItem> _gradeList = [];
  List<DropdownItem> _clubList = [];
  List<DropdownItem> _categoryList = [];
  bool _isLoadingDropdowns = false;

  List<DropdownItem> get gradeList => _gradeList;
  List<DropdownItem> get clubList => _clubList;
  List<DropdownItem> get categoryList => _categoryList;
  bool get isLoadingDropdowns => _isLoadingDropdowns;

  /// iOS: Fetches all three dropdown lists for Find Member screen.
  /// Grade: FindRotarian/GetMemberGradeList
  /// Club: FindRotarian/GetClubList
  /// Category: FindRotarian/GetCategoryList
  /// All return { str: { table: [{ id, name }] } }
  Future<void> fetchFindMemberDropdowns() async {
    _isLoadingDropdowns = true;
                                 notifyListeners();

    try {
      final emptyParams = <String, String>{
        'name': '',
        'Grade': '',
        'club': '',
        'Category': '',
        'memberMobile': '',
      };

      final futures = await Future.wait([
        ApiClient.instance.post(
          ApiConstants.findRotarianGetMemberGradeList,
          body: emptyParams,
        ),
        ApiClient.instance.post(
          ApiConstants.findRotarianGetClubList,
          body: emptyParams,
        ),
        ApiClient.instance.post(
          ApiConstants.findRotarianGetCategoryList,
          body: emptyParams,
        ),
      ]);

      _gradeList = _parseDropdownResponse(futures[0].body);
      _clubList = _parseDropdownResponse(futures[1].body);
      _categoryList = _parseDropdownResponse(futures[2].body);
    } catch (e) {
      debugPrint('fetchFindMemberDropdowns error: $e');
    }

    _isLoadingDropdowns = false;
    notifyListeners();
  }

  List<DropdownItem> _parseDropdownResponse(String body) {
    try {
      final jsonData = json.decode(body) as Map<String, dynamic>;
      // iOS: Gradessssss struct — { status, message, str: { Table: [...] } }
      final str = jsonData['str'] as Map<String, dynamic>?;
      // iOS CodingKey: case table = "Table" (capital T)
      final table = str?['Table'] as List<dynamic>? ?? [];
      return table
          .map((e) => DropdownItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('_parseDropdownResponse error: $e');
      return [];
    }
  }
}

/// Simple dropdown item with id and name.
/// iOS: GradessTable struct — used for Grade, Club, Category dropdowns.
class DropdownItem {
  DropdownItem({this.id, this.name});

  final int? id;
  final String? name;

  factory DropdownItem.fromJson(Map<String, dynamic> json) {
    return DropdownItem(
      id: json['id'] as int?,
      name: json['name']?.toString(),
    );
  }
}
