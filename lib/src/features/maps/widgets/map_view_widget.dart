import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/theme/app_colors.dart';

/// Reusable Google Map widget for displaying a location with a marker.
/// Port of iOS MKMapView usage in various view controllers.
class MapViewWidget extends StatelessWidget {
  const MapViewWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    this.markerTitle,
    this.height = 200,
    this.zoom = 15,
    this.onTap,
    this.interactive = false,
  });

  final double latitude;
  final double longitude;
  final String? markerTitle;
  final double height;
  final double zoom;
  final VoidCallback? onTap;

  /// If false, map is static (no gestures). If true, allows interaction.
  final bool interactive;

  @override
  Widget build(BuildContext context) {
    final position = LatLng(latitude, longitude);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border, width: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: position,
            zoom: zoom,
          ),
          markers: {
            Marker(
              markerId: const MarkerId('location'),
              position: position,
              infoWindow: markerTitle != null
                  ? InfoWindow(title: markerTitle)
                  : InfoWindow.noText,
            ),
          },
          zoomControlsEnabled: false,
          scrollGesturesEnabled: interactive,
          zoomGesturesEnabled: interactive,
          rotateGesturesEnabled: interactive,
          tiltGesturesEnabled: false,
          myLocationButtonEnabled: false,
          myLocationEnabled: false,
          liteModeEnabled: !interactive,
        ),
      ),
    );
  }
}
