import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/celebration_result.dart';

/// Event detail view — matches Android UpcomingEventDetails.java.
/// Receives event data directly (no API call), displays:
/// image, title, description, venue, date, map link, contact info, RSVP counts.
class DistrictEventDetailScreen extends StatelessWidget {
  const DistrictEventDetailScreen({
    super.key,
    required this.event,
  });

  final CelebrationEvent event;

  Future<void> _openMaps(String? lat, String? lon) async {
    if (lat == null || lon == null || lat.isEmpty || lon.isEmpty) return;

    final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lon');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textOnPrimary),
        title: const Text(
          'Event Details',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 17,
            fontWeight: FontWeight.w400,
            color: AppColors.textOnPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event image
            if (event.eventImg != null && event.eventImg!.isNotEmpty)
              Image.network(
                event.eventImg!.replaceAll(' ', '%20'),
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  height: 220,
                  color: AppColors.backgroundGray,
                  child: const Center(
                    child: Icon(Icons.image_not_supported,
                        color: AppColors.grayMedium, size: 48),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    event.eventTitle ?? event.title ?? '',
                    style: const TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Description
                  if (event.description != null &&
                      event.description!.isNotEmpty)
                    Text(
                      event.description!,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Venue
                  if (event.venue != null && event.venue!.isNotEmpty)
                    _buildInfoRow(
                      Icons.location_on,
                      event.venue!,
                      onTap: () =>
                          _openMaps(event.venueLat, event.venueLon),
                    ),

                  // Date/Time
                  if (event.eventDateTime != null &&
                      event.eventDateTime!.isNotEmpty)
                    _buildInfoRow(
                      Icons.calendar_today,
                      event.eventDateTime!,
                    )
                  else if (event.eventDate != null &&
                      event.eventDate!.isNotEmpty)
                    _buildInfoRow(
                      Icons.calendar_today,
                      event.eventDate!,
                    ),

                  // Contact
                  if (event.hasPhone)
                    _buildInfoRow(
                      Icons.phone,
                      event.contactNumber!,
                      onTap: () async {
                        final uri =
                            Uri(scheme: 'tel', path: event.contactNumber);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      },
                    ),

                  // Email
                  if (event.hasEmail)
                    _buildInfoRow(
                      Icons.email,
                      event.emailId!,
                      onTap: () async {
                        final uri =
                            Uri(scheme: 'mailto', path: event.emailId);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      },
                    ),

                  const SizedBox(height: 16),

                  // RSVP counts
                  if (event.goingCount != null ||
                      event.maybeCount != null ||
                      event.notgoingCount != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildCountChip(
                          'Going',
                          event.goingCount ?? '0',
                          const Color(0xFF4CAF50),
                        ),
                        _buildCountChip(
                          'Not Going',
                          event.notgoingCount ?? '0',
                          const Color(0xFFFF4C4D),
                        ),
                        _buildCountChip(
                          'Maybe',
                          event.maybeCount ?? '0',
                          AppColors.gray,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14,
                  color: onTap != null ? AppColors.primary : AppColors.textPrimary,
                  decoration:
                      onTap != null ? TextDecoration.underline : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountChip(String label, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(76)),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 11,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
