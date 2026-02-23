import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/ebulletin_list_result.dart';

/// Port of iOS EbulletineCell — table cell for e-bulletin list.
/// Shows title (purple if unread), publish date, delete button for admin.
class EbulletinCard extends StatelessWidget {
  const EbulletinCard({
    super.key,
    required this.ebulletin,
    this.onTap,
    this.onDelete,
    this.isAdmin = false,
  });

  final EbulletinItem ebulletin;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(
            bottom: BorderSide(color: AppColors.divider, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            // Bulletin icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: ebulletin.hasBeenRead
                    ? AppColors.backgroundGray
                    : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.article_outlined,
                color: ebulletin.hasBeenRead
                    ? AppColors.grayMedium
                    : AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),

            // Title and date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ebulletin.ebulletinTitle ?? 'Untitled',
                    style: AppTextStyles.body2.copyWith(
                      // iOS: purple (40,27,146) if unread, black if read
                      color: ebulletin.hasBeenRead
                          ? AppColors.textPrimary
                          : AppColors.primary,
                      fontWeight: ebulletin.hasBeenRead
                          ? FontWeight.w400
                          : FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ebulletin.publishDateTime ?? ebulletin.createDateTime ?? '',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),

            // Link type indicator
            if (ebulletin.hasValidLink)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  ebulletin.isExternalUrl ? Icons.link : Icons.attach_file,
                  color: AppColors.grayMedium,
                  size: 18,
                ),
              ),

            // Delete button (admin only)
            if (isAdmin)
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: AppColors.systemRed, size: 22),
                onPressed: onDelete,
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
          ],
        ),
      ),
    );
  }
}
