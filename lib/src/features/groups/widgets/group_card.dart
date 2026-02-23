import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Reusable group card widget.
/// iOS: Group cell in group lists, global search results.
class GroupCard extends StatelessWidget {
  const GroupCard({
    super.key,
    required this.grpName,
    this.grpImg,
    this.isMember = false,
    this.subtitle,
    this.onTap,
  });

  final String grpName;
  final String? grpImg;
  final bool isMember;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.border,
          backgroundImage: (grpImg != null && grpImg!.isNotEmpty)
              ? NetworkImage(grpImg!)
              : null,
          child: (grpImg == null || grpImg!.isEmpty)
              ? const Icon(Icons.group, color: AppColors.grayMedium, size: 22)
              : null,
        ),
        title: Text(
          grpName,
          style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w600),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: subtitle != null
            ? Text(subtitle!, style: AppTextStyles.caption)
            : null,
        trailing: isMember
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Joined',
                  style: AppTextStyles.captionSmall.copyWith(
                    color: AppColors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : const Icon(Icons.chevron_right,
                color: AppColors.primary, size: 22),
      ),
    );
  }
}
