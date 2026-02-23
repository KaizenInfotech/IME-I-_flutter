import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/announcement_list_result.dart';

/// Port of iOS announcement list cell — announcement card for list view.
/// Shows: image thumbnail, title, publish date, read/unread indicator.
class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({
    super.key,
    required this.announcement,
    this.onTap,
  });

  final AnnounceList announcement;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isRead = announcement.hasBeenRead;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isRead ? AppColors.white : AppColors.primary.withAlpha(8),
          border: const Border(
            bottom: BorderSide(color: AppColors.border, width: 0.5),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image thumbnail
            if (announcement.hasValidImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  announcement.announImg!.replaceAll(' ', '%20'),
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _buildImagePlaceholder(),
                ),
              )
            else
              _buildImagePlaceholder(),

            const SizedBox(width: 12),

            // Title, date, description preview
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    announcement.announTitle ?? '',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 15,
                      fontWeight: isRead ? FontWeight.w400 : FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Publish date — iOS: publishDateTime formatted
                  if (announcement.publishDateTime != null &&
                      announcement.publishDateTime!.isNotEmpty)
                    Text(
                      announcement.publishDateTime!,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),

                  const SizedBox(height: 2),

                  // Description preview
                  if (announcement.announceDEsc != null &&
                      announcement.announceDEsc!.isNotEmpty)
                    Text(
                      announcement.announceDEsc!,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 12,
                        color: AppColors.grayMedium,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),

            // Unread indicator
            if (!isRead)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.backgroundGray,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.campaign,
        color: AppColors.grayMedium,
        size: 28,
      ),
    );
  }
}
