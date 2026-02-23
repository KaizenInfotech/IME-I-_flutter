import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/local_storage.dart';
import '../models/add_service_result.dart';
import '../models/service_directory_result.dart';
import '../models/service_list_result.dart';

/// Port of iOS CategoryServiceDirectoryViewController + ServiceDirectoryListViewController
/// data logic — categories, service list, add/edit, detail.
class ServiceDirectoryProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  // Categories + all directory data
  List<ServiceCategory> _categories = [];
  List<ServiceDirectoryItem> _allDirectoryData = [];

  // Filtered services (by category)
  List<ServiceDirectoryItem> _services = [];
  List<ServiceDirectoryItem> _filteredServices = [];
  String _searchQuery = '';

  // Selected service detail
  ServiceDirectoryItem? _selectedDetail;
  bool _isLoadingDetail = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ServiceCategory> get categories => _categories;
  List<ServiceDirectoryItem> get services =>
      _searchQuery.isEmpty ? _services : _filteredServices;
  ServiceDirectoryItem? get selectedDetail => _selectedDetail;
  bool get isLoadingDetail => _isLoadingDetail;

  /// iOS: fetchDistrictCommittee — fetch categories + directory data.
  /// API: ServiceDirectory/GetServiceCategoriesData (POST)
  Future<void> fetchCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final localStorage = LocalStorage.instance;
      final grpId = localStorage.authGroupId ?? '';

      final response = await ApiClient.instance.post(
        ApiConstants.serviceDirectoryGetCategories,
        body: {'groupId': grpId},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = TBServiceCategoriesResult.fromJson(
            jsonData['TBGetServiceCategoriesDataList']
                    as Map<String, dynamic>? ??
                jsonData);
        if (result.isSuccess) {
          _categories = result.categories ?? [];
          _allDirectoryData = result.directoryData ?? [];
        } else {
          _error = result.message ?? 'Failed to load categories';
        }
      } else {
        _error = 'Server error';
      }
    } catch (e) {
      _error = 'Failed to load service directory';
      debugPrint('fetchCategories error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// iOS: Category click → filter directory data by categoryId.
  void fetchServicesByCategory(int categoryId) {
    _services = _allDirectoryData
        .where((s) => s.categoryId == categoryId.toString())
        .toList();
    _filteredServices = _services;
    _searchQuery = '';
    notifyListeners();
  }

  /// iOS: SearchBar — client-side filter on memberName and keywords.
  void searchServices(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredServices = _services;
    } else {
      final lower = query.toLowerCase();
      _filteredServices = _services.where((s) {
        final name = s.memberName?.toLowerCase() ?? '';
        final kw = s.keywords?.toLowerCase() ?? '';
        return name.contains(lower) || kw.contains(lower);
      }).toList();
    }
    notifyListeners();
  }

  /// iOS: SearchBar on category screen — filter categories + providers.
  void searchCategories(String query) {
    // This is handled at the UI level by filtering the categories list
    _searchQuery = query;
    notifyListeners();
  }

  /// Filtered categories based on search query.
  List<ServiceCategory> get filteredCategories {
    if (_searchQuery.isEmpty) return _categories;
    final lower = _searchQuery.toLowerCase();
    return _categories.where((c) {
      return c.categoryName?.toLowerCase().contains(lower) ?? false;
    }).toList();
  }

  /// iOS: GetServiceDirectoryDetails — fetch individual service detail.
  /// API: ServiceDirectory/GetServiceDirectoryDetails (POST)
  Future<void> fetchServiceDetail({
    required String serviceDirId,
  }) async {
    _isLoadingDetail = true;
    _selectedDetail = null;
    notifyListeners();

    try {
      final localStorage = LocalStorage.instance;
      final grpId = localStorage.authGroupId ?? '';

      final response = await ApiClient.instance.post(
        ApiConstants.serviceDirectoryGetDetails,
        body: {
          'groupId': grpId,
          'serviceDirId': serviceDirId,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = TBServiceDirectoryListResult.fromJson(
            jsonData['TBServiceDirectoryListResult']
                    as Map<String, dynamic>? ??
                jsonData);
        if (result.isSuccess) {
          _selectedDetail = result.detail;
        }
      }
    } catch (e) {
      debugPrint('fetchServiceDetail error: $e');
    }

    _isLoadingDetail = false;
    notifyListeners();
  }

  /// iOS: addeditServiceDirList — add or edit a service.
  /// API: ServiceDirectory/AddServiceDirectory (POST)
  Future<bool> addService({
    String serviceId = '',
    required String memberName,
    String description = '',
    String image = '',
    String countryCode1 = '',
    String mobileNo1 = '',
    String countryCode2 = '',
    String mobileNo2 = '',
    String paxNo = '',
    String email = '',
    String keywords = '',
    String address = '',
    String latitude = '',
    String longitude = '',
    String city = '',
    String state = '',
    String country = '',
    String zipCode = '',
    String moduleId = '',
    String website = '',
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final localStorage = LocalStorage.instance;
      final grpId = localStorage.authGroupId ?? '';
      final profileId = localStorage.authProfileId ?? '';

      final response = await ApiClient.instance.post(
        ApiConstants.serviceDirectoryAdd,
        body: {
          'serviceId': serviceId,
          'groupId': grpId,
          'memberName': memberName,
          'description': description,
          'image': image,
          'countryCode1': countryCode1,
          'mobileNo1': mobileNo1,
          'countryCode2': countryCode2,
          'mobileNo2': mobileNo2,
          'paxNo': paxNo,
          'email': email,
          'keywords': keywords,
          'address': address,
          'latitude': latitude,
          'longitude': longitude,
          'createdBy': profileId,
          'city': city,
          'state': state,
          'addressCountry': country,
          'zipcode': zipCode,
          'moduleId': moduleId,
          'website': website,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = TBAddServiceResult.fromJson(
            jsonData['TBAddServiceResult'] as Map<String, dynamic>? ??
                jsonData);
        _isLoading = false;
        notifyListeners();
        return result.isSuccess;
      }
    } catch (e) {
      debugPrint('addService error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
}
