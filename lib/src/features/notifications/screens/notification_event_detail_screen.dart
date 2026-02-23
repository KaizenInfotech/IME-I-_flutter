import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_app_bar.dart';

/// Port of Android UpcomingEventDetails.class.
/// Shows event data directly from notification payload (no API call).
/// Displayed when user taps an Event notification from the listing.
class NotificationEventDetailScreen extends StatelessWidget {
  const NotificationEventDetailScreen({
    super.key,
    required this.eventTitle,
    required this.eventDate,
    required this.eventDesc,
    required this.eventImg,
    required this.regLink,
    required this.venue,
  });

  final String eventTitle;
  final String eventDate;
  final String eventDesc;
  final String eventImg;
  final String regLink;
  final String venue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CommonAppBar(title: 'Upcoming Event Details'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event title
            if (eventTitle.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Text(
                  eventTitle,
                  style: AppTextStyles.heading5.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),

            // Event date
            if (eventDate.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                child: Text(
                  eventDate,
                  style: AppTextStyles.body3.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

            // Event description
            if (eventDesc.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 12),
                child: Text(
                  eventDesc,
                  style: AppTextStyles.body3.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

            const Divider(height: 1),

            // Registration link
            if (regLink.isNotEmpty)
              InkWell(
                onTap: () => _openLink(regLink),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text(
                    regLink,
                    style: AppTextStyles.body3.copyWith(
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ),

            // Venue
            if (venue.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Text(
                  venue,
                  style: AppTextStyles.body3.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

            if (regLink.isNotEmpty || venue.isNotEmpty) const Divider(height: 1),

            // Photos section header
            if (eventImg.isNotEmpty) ...[
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: AppColors.grayMedium,
                child: const Text(
                  'Photos',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),

              // Event image
              Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: CachedNetworkImage(
                    imageUrl: eventImg,
                    fit: BoxFit.contain,
                    placeholder: (_, _) => const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (_, _, _) => const SizedBox(
                      height: 200,
                      child: Center(
                        child: Icon(Icons.broken_image,
                            size: 48, color: AppColors.grayMedium),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
