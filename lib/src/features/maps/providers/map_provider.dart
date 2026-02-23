import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

/// Port of iOS MapAddressViewController + GooglePlaceApi logic.
/// Handles Google Places search, geocoding, and reverse geocoding.
class MapProvider extends ChangeNotifier {
  // Google Maps API key — matching iOS GoogleService-Info.plist.
  static const String _apiKey = 'AIzaSyDSQIuWXOdEZX4VwFIRLi4kIQRMpTMqa4E';

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // ─── Selected Location ───────────────────────────────────
  LatLng? _selectedLocation;
  LatLng? get selectedLocation => _selectedLocation;

  String? _selectedAddress;
  String? get selectedAddress => _selectedAddress;

  // ─── Search Results ──────────────────────────────────────
  List<PlacePrediction> _searchResults = [];
  List<PlacePrediction> get searchResults => _searchResults;

  void setSelectedLocation(LatLng location) {
    _selectedLocation = location;
    notifyListeners();
  }

  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }

  // ─── Search Places (Google Places Autocomplete) ──────────
  /// iOS: GooglePlaceApi search functionality.
  Future<void> searchPlaces(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json'
        '?input=${Uri.encodeComponent(query)}'
        '&key=$_apiKey',
      );

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final predictions =
            jsonData['predictions'] as List<dynamic>? ?? [];

        _searchResults = predictions.map((e) {
          final map = e as Map<String, dynamic>;
          return PlacePrediction.fromJson(map);
        }).toList();
      } else {
        _searchResults = [];
      }
    } catch (e) {
      debugPrint('searchPlaces error: $e');
      _searchResults = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // ─── Get Place Details ───────────────────────────────────
  /// Converts a placeId to coordinates.
  Future<LatLng?> getPlaceDetails(String placeId) async {
    try {
      final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json'
        '?place_id=${Uri.encodeComponent(placeId)}'
        '&fields=geometry'
        '&key=$_apiKey',
      );

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = jsonData['result'] as Map<String, dynamic>?;
        final geometry = result?['geometry'] as Map<String, dynamic>?;
        final location = geometry?['location'] as Map<String, dynamic>?;

        if (location != null) {
          final lat = (location['lat'] as num).toDouble();
          final lng = (location['lng'] as num).toDouble();
          final latLng = LatLng(lat, lng);
          _selectedLocation = latLng;
          notifyListeners();
          return latLng;
        }
      }
    } catch (e) {
      debugPrint('getPlaceDetails error: $e');
    }
    return null;
  }

  // ─── Reverse Geocode ─────────────────────────────────────
  /// iOS: CLGeocoder.reverseGeocodeLocation → formatted address.
  /// Uses Google Geocoding API.
  Future<String?> reverseGeocode(LatLng location) async {
    _isLoading = true;
    notifyListeners();

    try {
      final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json'
        '?latlng=${location.latitude},${location.longitude}'
        '&key=$_apiKey',
      );

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final results = jsonData['results'] as List<dynamic>? ?? [];

        if (results.isNotEmpty) {
          final first = results[0] as Map<String, dynamic>;
          final address = first['formatted_address']?.toString();
          _selectedAddress = address;
          _selectedLocation = location;
          _isLoading = false;
          notifyListeners();
          return address;
        }
      }
    } catch (e) {
      debugPrint('reverseGeocode error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return null;
  }

  // ─── Geocode Address ─────────────────────────────────────
  /// iOS: CLGeocoder.geocodeAddressString → coordinates.
  Future<LatLng?> geocodeAddress(String address) async {
    try {
      final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json'
        '?address=${Uri.encodeComponent(address)}'
        '&key=$_apiKey',
      );

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final results = jsonData['results'] as List<dynamic>? ?? [];

        if (results.isNotEmpty) {
          final first = results[0] as Map<String, dynamic>;
          final geometry = first['geometry'] as Map<String, dynamic>?;
          final location = geometry?['location'] as Map<String, dynamic>?;

          if (location != null) {
            final lat = (location['lat'] as num).toDouble();
            final lng = (location['lng'] as num).toDouble();
            return LatLng(lat, lng);
          }
        }
      }
    } catch (e) {
      debugPrint('geocodeAddress error: $e');
    }
    return null;
  }
}

/// Google Places autocomplete prediction.
class PlacePrediction {
  PlacePrediction({this.placeId, this.description, this.mainText, this.secondaryText});

  final String? placeId;
  final String? description;
  final String? mainText;
  final String? secondaryText;

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    final structured =
        json['structured_formatting'] as Map<String, dynamic>? ?? {};
    return PlacePrediction(
      placeId: json['place_id']?.toString(),
      description: json['description']?.toString(),
      mainText: structured['main_text']?.toString(),
      secondaryText: structured['secondary_text']?.toString(),
    );
  }
}
