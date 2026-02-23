import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/celebration_result.dart';

/// Port of iOS CelebreationEventAnnivBirthdayTableViewCell — celebration list item.
/// Shows "Name (Branch)" and contact actions (call/SMS/email/WhatsApp).
/// Matches Android calendar screenshot layout.
class CelebrationListTile extends StatelessWidget {
  const CelebrationListTile({
    super.key,
    required this.event,
    this.onTap,
    this.showActions = true,
  });

  final CelebrationEvent event;
  final VoidCallback? onTap;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.border, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            // Name and branch
            Expanded(
              child: Text(
                event.displayTitle,
                style: const TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (showActions) ...[
              const SizedBox(width: 8),

              // Action buttons — phone, message, email, WhatsApp
              if (event.hasPhone)
                _buildActionIcon(
                  Icons.phone,
                  AppColors.primary,
                  () => _makeCall(event.firstPhone!),
                )
              else
                _buildDisabledIcon(Icons.phone),
              const SizedBox(width: 16),
              if (event.hasPhone)
                _buildActionIcon(
                  Icons.chat,
                  Colors.amber.shade700,
                  () => _sendSms(event.firstPhone!),
                )
              else
                _buildDisabledIcon(Icons.chat),
              const SizedBox(width: 16),
              if (event.hasEmail)
                _buildActionIcon(
                  Icons.email,
                  AppColors.primaryBlue,
                  () => _sendEmail(event.firstEmail!),
                )
              else
                _buildDisabledIcon(Icons.email),
              const SizedBox(width: 16),
              if (event.hasPhone)
                _buildWhatsAppIcon(
                  () => _openWhatsApp(event.firstPhone!),
                )
              else
               Image.asset('assets/images/whats_grey.png', width: 30, height: 30, color: AppColors.grayMedium),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, Color color, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Icon(icon, size: 26, color: color),
    );
  }

  Widget _buildWhatsAppIcon(VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Image.asset('assets/images/whatsapp.png', width: 26, height: 26),
    );
  }

  Widget _buildDisabledIcon(IconData icon) {
    return Icon(icon, size: 26, color: AppColors.grayMedium);
  }

  Future<void> _makeCall(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendSms(String phone) async {
    final uri = Uri(scheme: 'sms', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// iOS NationalBirthdayViewController.whatsApButton:
  /// Opens WhatsApp chat with country code 91 + cleaned number.
  Future<void> _openWhatsApp(String phone) async {
    var cleaned = phone;
    if (cleaned.startsWith('+91 ')) {
      cleaned = cleaned.substring(4);
    }
    cleaned = cleaned.replaceAll(RegExp(r'[^0-9]'), '');
    final url = Uri.parse('https://api.whatsapp.com/send?phone=91$cleaned');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
