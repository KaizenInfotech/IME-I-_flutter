import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../models/sub_committee_result.dart';

/// Port of iOS SubCommProfileViewController.
/// Displays sub committee member profile details with action buttons
/// (Call, Message, WhatsApp, Email).
class SubCommitteeProfileScreen extends StatelessWidget {
  const SubCommitteeProfileScreen({
    super.key,
    required this.member,
  });

  final SubCommitteeMember member;

  Future<void> _launchPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _launchSms(String phone) async {
    final uri = Uri(scheme: 'sms', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _launchWhatsApp(String phone) async {
    // iOS: "https://wa.me/91\(phone)"
    final cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('https://wa.me/91$cleaned');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final name = member.membername ?? '';
    final mobile = member.mobilenumber ?? '';
    final secondaryMobile = member.othermobilenumber ?? '';
    final email = member.emailId ?? '';

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: const CommonAppBar(title: 'Profile'),
      body: ListView(
        children: [
          // ─── Profile Header (centered) ──────────────
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                // Avatar with initial
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.border,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Name
                Text(
                  name,
                  style: AppTextStyles.heading6
                      .copyWith(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                if (member.designation != null &&
                    member.designation!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    member.designation!,
                    style: AppTextStyles.body2
                        .copyWith(color: AppColors.primary),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 16),
                // ─── Action Buttons (Call, Message, Email, WhatsApp) ───
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildActionButton(
                      icon: Icons.call,
                      label: 'Call',
                      color: AppColors.primary,
                      enabled: mobile.isNotEmpty,
                      onTap: () => _launchPhone(mobile),
                    ),
                    const SizedBox(width: 20),
                    _buildActionButton(
                      icon: Icons.message,
                      label: 'Message',
                      color: Colors.amber.shade700,
                      enabled: mobile.isNotEmpty,
                      onTap: () => _launchSms(mobile),
                    ),
                    const SizedBox(width: 20),
                    _buildActionButton(
                      icon: Icons.email,
                      label: 'Email',
                      color: AppColors.primaryBlue,
                      enabled: email.isNotEmpty,
                      onTap: () => _launchEmail(email),
                    ),
                    const SizedBox(width: 20),
                    _buildWhatsAppButton(
                      enabled: mobile.isNotEmpty,
                      onTap: () => _launchWhatsApp(mobile),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ─── Detail Rows ──────────────────────────
          Container(
            color: AppColors.white,
            child: Column(
              children: [
                if (member.branch != null && member.branch!.isNotEmpty)
                  _buildDetailRow('Chapter/Branch Name', member.branch!),
                if (member.committeName != null &&
                    member.committeName!.isNotEmpty)
                  _buildDetailRow('Committee Name', member.committeName!),
                if (member.designation != null &&
                    member.designation!.isNotEmpty)
                  _buildDetailRow('Designation', member.designation!),
                if (mobile.isNotEmpty)
                  _buildDetailRow('Mobile', mobile),
                if (secondaryMobile.isNotEmpty)
                  _buildDetailRow('Secondary Mobile', secondaryMobile),
                if (email.isNotEmpty)
                  _buildDetailRow('Email', email),
                if (member.otheremailid != null &&
                    member.otheremailid!.isNotEmpty)
                  _buildDetailRow('Secondary Email', member.otheremailid!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style:
                AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.body2),
        ],
      ),
    );
  }

  Widget _buildWhatsAppButton({
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: enabled ? AppColors.green.withAlpha(25) : AppColors.backgroundGray,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: enabled
                  ? Image.asset('assets/images/whatsapp.png', width: 22, height: 22)
                  : Image.asset('assets/images/whatsapp.png', width: 22, height: 22, color: AppColors.grayMedium,),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'WhatsApp',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: enabled ? color.withAlpha(25) : AppColors.backgroundGray,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 22,
              color: enabled ? color : AppColors.grayMedium,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: enabled ? AppColors.textSecondary : AppColors.grayMedium,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
