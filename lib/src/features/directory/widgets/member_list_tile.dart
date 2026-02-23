import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/member_result.dart';

/// Port of iOS DirectoryCell — member row in directory table view.
/// iOS: cell.nameLabel.text, cell.mobileLabel.text, cell.profilePic (sd_setImage),
/// cell.buttonRotarian (navigates to JitoProfileViewController).
/// Height: 90 for Rotarian view.
class MemberListTile extends StatelessWidget {
  const MemberListTile({
    super.key,
    required this.member,
    required this.onTap,
    this.onCall,
    this.onMessage,
    this.onEmail,
  });

  final MemberListItem member;
  final VoidCallback onTap;
  final VoidCallback? onCall;
  final VoidCallback? onMessage;
  final VoidCallback? onEmail;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        height: 90,
        child: Row(
          children: [
            // Profile picture — iOS: cell.profilePic.sd_setImage
            _buildProfilePic(),
            const SizedBox(width: 12),
            // Name and mobile — iOS: cell.nameLabel, cell.mobileLabel
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.memberName ?? '',
                    style: const TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (member.memberMobile != null &&
                      member.memberMobile!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      member.memberMobile!,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  if (member.designation != null &&
                      member.designation!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      member.designation!,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            // Action buttons — iOS: call/sms/email buttons on cell
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (member.memberMobile != null &&
                    member.memberMobile!.isNotEmpty)
                  _actionButton(
                    Icons.phone,
                    AppColors.green,
                    onCall ??
                        () => _launchUrl(
                            'tel:${member.memberMobile}'),
                  ),
                if (member.memberMobile != null &&
                    member.memberMobile!.isNotEmpty)
                  _actionButton(
                    Icons.message,
                    Colors.amber.shade700,
                    onMessage ??
                        () => _launchUrl(
                            'sms:${member.memberMobile}'),
                  ),
                if (member.memberEmail != null &&
                    member.memberEmail!.isNotEmpty)
                  _actionButton(
                    Icons.email,
                    AppColors.orange,
                    onEmail ??
                        () => _launchUrl(
                            'mailto:${member.memberEmail}'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePic() {
    return GestureDetector(
      child: CircleAvatar(
        radius: 28,
        backgroundColor: AppColors.backgroundGray,
        backgroundImage: member.hasValidProfilePic
            ? NetworkImage(
                member.profilePic!.replaceAll(' ', '%20'),
              )
            : null,
        child: !member.hasValidProfilePic
            ? const Icon(Icons.person, color: AppColors.textSecondary, size: 28)
            : null,
      ),
    );
  }

  Widget _actionButton(IconData icon, Color color, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, color: color, size: 20),
      onPressed: onPressed,
      padding: const EdgeInsets.all(6),
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    );
  }

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
