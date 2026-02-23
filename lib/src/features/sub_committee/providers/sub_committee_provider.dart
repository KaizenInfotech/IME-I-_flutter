import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/sub_committee_result.dart';

/// Provider for Sub Committees.
/// iOS: SubCommitteeViewController — GET FindClub/GetCommitteelist.
class SubCommitteeProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<SubCommittee> _committees = [];
  List<SubCommitteeMember> _allMembers = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<SubCommittee> get committees => _committees;

  /// Get members for a specific committee by filtering Table1 data.
  List<SubCommitteeMember> getMembers(int committeeId) {
    return _allMembers
        .where((m) => m.pkSubcommitteeId == committeeId)
        .toList();
  }

  /// iOS: functionForGetSubCommitteeList()
  /// GET FindClub/GetCommitteelist — returns both committee list and member list.
  Future<void> fetchCommittees() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.get(
        ApiConstants.findClubGetCommitteeList,
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = SubCommitteeResult.fromJson(jsonData);
        _committees = result.committees;
        _allMembers = result.members;
        if (_committees.isEmpty) {
          _error = 'No committees found';
        }
      } else {
        _error = 'Server error';
      }
    } catch (e) {
      _error = 'Failed to load committees';
      debugPrint('fetchCommittees error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
