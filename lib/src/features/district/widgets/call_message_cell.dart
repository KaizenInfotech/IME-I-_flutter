import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Port of iOS CallTableViewCell + DistrictCallMessageTableViewCell +
/// DistrictEmailTableViewCell — contact action buttons.
/// Provides Call, Message, Email, WhatsApp actions.
class CallMessageCell extends StatelessWidget {
  const CallMessageCell({
    super.key,
    required this.phoneNumbers,
    required this.emails,
  });

  final List<String> phoneNumbers;
  final List<String> emails;

  Future<void> _makeCall(BuildContext context) async {
    if (phoneNumbers.isEmpty) return;
    if (phoneNumbers.length == 1) {
      final uri = Uri.parse('tel:${phoneNumbers.first}');
      if (await canLaunchUrl(uri)) await launchUrl(uri);
      return;
    }
    _showPicker(context, 'Select Number', phoneNumbers, (number) async {
      final uri = Uri.parse('tel:$number');
      if (await canLaunchUrl(uri)) await launchUrl(uri);
    });
  }

  Future<void> _sendSms(BuildContext context) async {
    if (phoneNumbers.isEmpty) return;
    if (phoneNumbers.length == 1) {
      final uri = Uri.parse('sms:${phoneNumbers.first}');
      if (await canLaunchUrl(uri)) await launchUrl(uri);
      return;
    }
    _showPicker(context, 'Select Number', phoneNumbers, (number) async {
      final uri = Uri.parse('sms:$number');
      if (await canLaunchUrl(uri)) await launchUrl(uri);
    });
  }

  Future<void> _sendEmail(BuildContext context) async {
    if (emails.isEmpty) return;
    if (emails.length == 1) {
      final uri = Uri.parse('mailto:${emails.first}');
      if (await canLaunchUrl(uri)) await launchUrl(uri);
      return;
    }
    _showPicker(context, 'Select Email', emails, (email) async {
      final uri = Uri.parse('mailto:$email');
      if (await canLaunchUrl(uri)) await launchUrl(uri);
    });
  }

  Future<void> _openWhatsApp(BuildContext context) async {
    if (phoneNumbers.isEmpty) return;
    if (phoneNumbers.length == 1) {
      await _launchWhatsApp(phoneNumbers.first);
      return;
    }
    _showPicker(context, 'Select Number', phoneNumbers, _launchWhatsApp);
  }

  Future<void> _launchWhatsApp(String number) async {
    final cleaned = number.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.length < 7) return;
    final uri = Uri.parse('https://wa.me/$cleaned');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showPicker(
    BuildContext context,
    String title,
    List<String> items,
    void Function(String) onSelected,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(title, style: AppTextStyles.heading6),
            ),
            const Divider(height: 1),
            ...items.map((item) => ListTile(
                  title: Text(item),
                  onTap: () {
                    Navigator.pop(ctx);
                    onSelected(item);
                  },
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasPhone = phoneNumbers.isNotEmpty;
    final hasEmail = emails.isNotEmpty;

    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildAction(
            icon: Icons.call,
            label: 'Call',
            color: hasPhone ? AppColors.primary : AppColors.grayMedium,
            onTap: hasPhone ? () => _makeCall(context) : null,
          ),
          _buildAction(
            icon: Icons.message,
            label: 'Message',
            color: hasPhone ? Colors.amber.shade700 : AppColors.grayMedium,
            onTap: hasPhone ? () => _sendSms(context) : null,
          ),
          _buildAction(
            icon: Icons.email,
            label: 'Email',
            color: hasEmail ? AppColors.primaryBlue : AppColors.grayMedium,
            onTap: hasEmail ? () => _sendEmail(context) : null,
          ),
          InkWell(
            onTap: hasPhone ? () => _openWhatsApp(context) : null,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  hasPhone
                      ? Image.asset('assets/images/whatsapp.png', width: 28, height: 28)
                      : Image.asset('assets/images/whats_grey.png', width: 30, height: 30, color: AppColors.grayMedium),
                  const SizedBox(height: 4),
                  Text(
                    'WhatsApp',
                    style: AppTextStyles.captionSmall.copyWith(
                      color: hasPhone ? AppColors.green : AppColors.grayMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAction({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.captionSmall.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
