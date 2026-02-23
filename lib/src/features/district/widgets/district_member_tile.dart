import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/district_result.dart';

/// Port of iOS DistrictDirOnlineTableCell — district member list item.
/// Shows profile pic, name, and club name.
class DistrictMemberTile extends StatelessWidget {
  const DistrictMemberTile({
    super.key,
    required this.member,
    this.onTap,
  });

  final DistrictMember member;
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
            // Profile pic
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: ClipOval(
                child: member.hasValidPic
                    ? Image.network(
                        member.encodedPicUrl!,
                        fit: BoxFit.cover,
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

            // Name + club
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.memberName ?? 'Unknown',
                    style: AppTextStyles.body2.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (member.clubName != null &&
                      member.clubName!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      member.clubName!,
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            const Icon(Icons.chevron_right,
                color: AppColors.primary, size: 22),
          ],
        ),
      ),
    );
  }
}
