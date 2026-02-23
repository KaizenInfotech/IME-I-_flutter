import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/map_provider.dart';

/// Port of iOS MapAddressViewController.
/// Google Map with draggable center pin, address display, search.
/// Returns selected address + coordinates on Done.
class MapAddressScreen extends StatefulWidget {
  const MapAddressScreen({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.initialAddress,
  });

  final double? initialLatitude;
  final double? initialLongitude;
  final String? initialAddress;

  @override
  State<MapAddressScreen> createState() => _MapAddressScreenState();
}

class _MapAddressScreenState extends State<MapAddressScreen> {
  GoogleMapController? _mapController;
  final _searchController = TextEditingController();
  bool _showSearch = false;

  // iOS default: user's location or fallback
  static const LatLng _defaultLocation = LatLng(19.0760, 72.8777); // Mumbai

  LatLng get _initialPosition => LatLng(
        widget.initialLatitude ?? _defaultLocation.latitude,
        widget.initialLongitude ?? _defaultLocation.longitude,
      );

  @override
  void initState() {
    super.initState();
    final provider = context.read<MapProvider>();
    provider.setSelectedLocation(_initialPosition);
    if (widget.initialAddress != null) {
      // Already have address
    } else {
      // Reverse geocode initial position
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.reverseGeocode(_initialPosition);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  /// iOS: regionDidChangeAnimated → reverse geocode new center.
  void _onCameraIdle() {
    final provider = context.read<MapProvider>();
    final location = provider.selectedLocation;
    if (location != null) {
      provider.reverseGeocode(location);
    }
  }

  void _onCameraMove(CameraPosition position) {
    context.read<MapProvider>().setSelectedLocation(position.target);
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isEmpty) return;
    context.read<MapProvider>().searchPlaces(query);
  }

  Future<void> _selectPrediction(PlacePrediction prediction) async {
    final provider = context.read<MapProvider>();
    provider.clearSearch();
    _searchController.clear();
    setState(() => _showSearch = false);

    if (prediction.placeId != null) {
      final latLng = await provider.getPlaceDetails(prediction.placeId!);
      if (latLng != null && _mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(latLng),
        );
      }
    }
  }

  /// iOS: Done button → passes address + lat/lng back.
  void _onDone() {
    final provider = context.read<MapProvider>();
    final result = <String, dynamic>{
      'address': provider.selectedAddress ?? '',
      'latitude': provider.selectedLocation?.latitude ?? 0.0,
      'longitude': provider.selectedLocation?.longitude ?? 0.0,
    };
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: AppColors.textOnPrimary),
        title: const Text(
          'Address',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 17,
            color: AppColors.textOnPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => setState(() => _showSearch = !_showSearch),
          ),
          TextButton(
            onPressed: _onDone,
            child: const Text(
              'Done',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textOnPrimary,
              ),
            ),
          ),
        ],
      ),
      body: Consumer<MapProvider>(
        builder: (context, provider, _) {
          return Stack(
            children: [
              // Google Map
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _initialPosition,
                  zoom: 15, // iOS: 0.01 delta ≈ zoom 15
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                onCameraMove: _onCameraMove,
                onCameraIdle: _onCameraIdle,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: false,
              ),

              // Center pin (iOS: MKPinAnnotationView at center)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 36),
                  child: Icon(
                    Icons.location_pin,
                    size: 48,
                    color: AppColors.systemRed,
                  ),
                ),
              ),

              // Search overlay
              if (_showSearch)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _buildSearchOverlay(provider),
                ),

              // Address bar at bottom (iOS: buttonAddress)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildAddressBar(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchOverlay(MapProvider provider) {
    return Container(
      color: AppColors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              style: AppTextStyles.input,
              decoration: InputDecoration(
                hintText: 'Search address...',
                hintStyle: AppTextStyles.inputHint,
                prefixIcon:
                    const Icon(Icons.search, color: AppColors.textSecondary),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    provider.clearSearch();
                    setState(() => _showSearch = false);
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              onChanged: (val) {
                if (val.length >= 3) {
                  provider.searchPlaces(val);
                }
              },
              onSubmitted: _onSearchSubmitted,
            ),
          ),
          if (provider.searchResults.isNotEmpty)
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: provider.searchResults.length,
                itemBuilder: (_, index) {
                  final prediction = provider.searchResults[index];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.location_on,
                        size: 18, color: AppColors.textSecondary),
                    title: Text(
                      prediction.mainText ?? '',
                      style: AppTextStyles.body3
                          .copyWith(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      prediction.secondaryText ?? '',
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => _selectPrediction(prediction),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  /// iOS: buttonAddress — yellow border, white bg, shows selected address.
  Widget _buildAddressBar(MapProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFFFCC00), width: 2), // Yellow border
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on,
              color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: provider.isLoading
                ? const Text(
                    'Loading address...',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 13,
                      color: AppColors.textHint,
                    ),
                  )
                : Text(
                    provider.selectedAddress ?? 'Drag pin to select address',
                    style: const TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
        ],
      ),
    );
  }
}
