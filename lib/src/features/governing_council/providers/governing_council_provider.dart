import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/governing_council_result.dart';

/// Provider for Governing Council Members.
/// iOS: GoverningCouncilViewController — POST Member/GetGoverningCouncl.
class GoverningCouncilProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<CouncilMember> _members = [];
  String _selectedYear = '';

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<CouncilMember> get members => _members;
  String get selectedYear => _selectedYear;

  /// iOS: functionForGetGoverningCouncilMemberList()
  /// POST Member/GetGoverningCouncl with searchText and YearFilter.
  Future<void> fetchCouncilMembers({
    String searchText = '',
    String yearFilter = '',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.memberGetGoverningCouncil,
        body: {
          'searchText': searchText,
          'YearFilter': yearFilter,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = GoverningCouncilResult.fromJson(jsonData);
        _members = result.members;
        if (_members.isEmpty) {
          _error = 'No records found';
        }
      } else {
        _error = 'Server error';
      }
    } catch (e) {
      _error = 'Failed to load governing council members';
      debugPrint('fetchCouncilMembers error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void setSelectedYear(String year) {
    _selectedYear = year;
    notifyListeners();
  }
}
