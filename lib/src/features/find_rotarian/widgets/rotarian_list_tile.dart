import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/rotarian_result.dart';

/// Port of iOS SearchFindARotarianTableViewCell — rotarian list item.
/// Shows profile picture, name, club name, grade, and category.
/// Matches findmember.PNG layout.
class RotarianListTile extends StatelessWidget {
  const RotarianListTile({
    super.key,
    required this.item,
    this.onTap,
  });

  final RotarianItem item;
  final VoidCallback? onTap;

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
            // Profile picture
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: ClipOval(
                child: item.hasValidPic
                    ? Image.network(
                        item.encodedPicUrl!,
                        fit: BoxFit.cover,
                        width: 48,
                        height: 48,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.person,
                          size: 28,
                          color: AppColors.grayMedium,
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        size: 28,
                        color: AppColors.grayMedium,
                      ),
              ),
            ),
            const SizedBox(width: 12),

            // Name, club, grade, category
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Member name
                  Text(
                    item.memberName ?? '',
                    style: AppTextStyles.body2.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Club name
                  if (item.clubName != null &&
                      item.clubName!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.clubName!,
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  // Grade
                  if (item.grade != null && item.grade!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.grade!,
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  // Category
                  if (item.memCategory != null &&
                      item.memCategory!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.memCategory!,
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Chevron
            Icon(
                    Icons.chevron_right,
                    color: AppColors.primary,
                    size: 22,
                  ),
          ],
        ),
      ),
    );
  }
}
