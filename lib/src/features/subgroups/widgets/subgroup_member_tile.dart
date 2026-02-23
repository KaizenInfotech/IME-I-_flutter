import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/subgroup_detail_result.dart';

/// Port of iOS SubGrpDetailCell — sub-group member tile.
/// Shows member name and mobile number with call action.
class SubgroupMemberTile extends StatelessWidget {
  const SubgroupMemberTile({
    super.key,
    required this.member,
  });

  final SubgroupMember member;

  Future<void> _makeCall() async {
    if (member.mobile == null || member.mobile!.isEmpty) return;
    final uri = Uri.parse('tel:${member.mobile}');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Person icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),

          // Name + mobile
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.memname ?? 'Unknown',
                  style: AppTextStyles.body2.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (member.mobile != null &&
                    member.mobile!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    member.mobile!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Call button
          if (member.mobile != null && member.mobile!.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.call, color: AppColors.primary),
              onPressed: _makeCall,
            ),
        ],
      ),
    );
  }
}
