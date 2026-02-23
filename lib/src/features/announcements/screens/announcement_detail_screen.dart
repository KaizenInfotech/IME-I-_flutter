import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/announcement_list_result.dart';

/// Android: AnnouncementsDetailActivity — displays announcement detail
/// using data passed directly from the list (no separate API call).
/// Fields displayed: title, publishDateTime, description, image, reglink.
class AnnouncementDetailScreen extends StatelessWidget {
  const AnnouncementDetailScreen({
    super.key,
    required this.announcement,
  });

  /// The full announcement object from the list — Android passes these via Intent extras:
  /// annTitle, annPublishedDate, annDescription, announImg, annRegLink
  final AnnounceList announcement;

  Future<void> _openLink(String link) async {
    var url = link;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'http://$url';
    }
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
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
          'Announcement',
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
            // Android: img_announcement_Gallery1 — loaded via Glide
            if (announcement.hasValidImage)
              GestureDetector(
                onTap: () => _showFullImage(context, announcement.announImg!),
                child: Image.network(
                  announcement.announImg!.replaceAll(' ', '%20'),
                  width: double.infinity,
                  height: 252,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 252,
                    color: AppColors.backgroundGray,
                    child: const Center(
                      child: Icon(Icons.image_not_supported,
                          color: AppColors.grayMedium, size: 48),
                    ),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Android: tvAnnouncementsTitle
                  Text(
                    announcement.announTitle ?? '',
                    style: const TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Android: tvAnnouncementsPublishedDate
                  if (announcement.publishDateTime != null &&
                      announcement.publishDateTime!.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          announcement.publishDateTime!,
                          style: const TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),

                  // Android: tv_AnnouncementRegLink — shown and clickable
                  if (announcement.hasLink) ...[
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () => _openLink(announcement.link!),
                      child: Row(
                        children: [
                          const Icon(Icons.link,
                              size: 16, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              announcement.link!,
                              style: const TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                fontSize: 14,
                                color: AppColors.primary,
                                decoration: TextDecoration.underline,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Android: tvAnnouncementsDescription
                  if (announcement.announceDEsc != null &&
                      announcement.announceDEsc!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    Text(
                      announcement.announceDEsc!,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.network(
                  imageUrl.replaceAll(' ', '%20'),
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.image_not_supported,
                    color: AppColors.white,
                    size: 64,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.close, color: AppColors.white, size: 28),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
