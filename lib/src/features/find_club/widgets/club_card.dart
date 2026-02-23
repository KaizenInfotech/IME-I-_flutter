import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/club_result.dart';

/// Port of iOS SearchAnyClubNearMeClubCell — club search result card.
/// Shows club name, meeting day/time, and distance (if near-me).
class ClubCard extends StatelessWidget {
  const ClubCard({
    super.key,
    required this.club,
    this.onTap,
  });

  final ClubItem club;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(
            bottom: BorderSide(color: AppColors.divider, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            // Club icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.business,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),

            // Club name + meeting info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    club.clubName ?? 'Unknown Club',
                    style: AppTextStyles.body2.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (club.displayMeetingInfo.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      club.displayMeetingInfo,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ],
              ),
            ),

            // Distance (for near-me results)
            if (club.displayDistance != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  club.displayDistance!,
                  style: AppTextStyles.captionSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],

            const SizedBox(width: 4),
            const Icon(
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
