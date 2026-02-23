import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/mer_result.dart';

/// Provider for MER(I) and iMelange — shared with type parameter.
/// iOS: MERDashViewController (Type/TransType "1") and iMelengaViewController (Type/TransType "2").
class MerProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isLoadingYears = false;
  String? _error;
  List<YearItem> _years = [];
  List<MerItem> _merItems = [];
  String _selectedYear = '';

  bool get isLoading => _isLoading;
  bool get isLoadingYears => _isLoadingYears;
  String? get error => _error;
  List<YearItem> get years => _years;
  List<MerItem> get merItems => _merItems;
  String get selectedYear => _selectedYear;

  /// iOS: functionForGetYearList()
  /// POST Gallery/GetYear with Type ("1" for MER, "2" for iMélange).
  Future<void> fetchYears({required String type}) async {
    _isLoadingYears = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.galleryGetYear,
        body: {'Type': type},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = YearResult.fromJson(jsonData);
        _years = result.years;
        if (_years.isNotEmpty) {
          _selectedYear = _years.first.financeYear ?? '';
        }
      } else {
        _error = 'Server error';
      }
    } catch (e) {
      _error = 'Failed to load years';
      debugPrint('fetchYears error: $e');
    }

    _isLoadingYears = false;
    notifyListeners();
  }

  /// iOS: functionForGetMERList() / functionForiMelengeList()
  /// POST Gallery/GetMER_List with FinanceYear and TransType ("1" or "2").
  Future<void> fetchMerList({
    required String financeYear,
    required String transType,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.galleryGetMerList,
        body: {
          'FinanceYear': financeYear,
          'TransType': transType,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = MerResult.fromJson(jsonData);
        _merItems = result.items;
        if (_merItems.isEmpty) {
          _error = 'No records found';
        }
      } else {
        _error = 'Server error';
      }
    } catch (e) {
      _error = 'Failed to load data';
      debugPrint('fetchMerList error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void setSelectedYear(String year) {
    _selectedYear = year;
    notifyListeners();
  }
}
