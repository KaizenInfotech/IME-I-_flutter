import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../models/branch_chapter_result.dart';

/// Port of iOS BranchMemDetailViewController.
/// Shows member profile with contact actions and detail rows.
class BranchMemberProfileScreen extends StatelessWidget {
  const BranchMemberProfileScreen({super.key, required this.member});

  final BranchMemberDetail member;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: const CommonAppBar(title: 'Profile'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),

            // Profile picture
            CircleAvatar(
              radius: 44,
              backgroundColor: AppColors.grayLight,
              backgroundImage: member.hasValidPic
                  ? CachedNetworkImageProvider(member.encodedPicUrl!)
                  : null,
              child: !member.hasValidPic
                  ? const Icon(Icons.person,
                      color: AppColors.grayMedium, size: 52)
                  : null,
            ),
            const SizedBox(height: 12),

            // Name
            Text(
              member.fullName,
              style: AppTextStyles.body1
                  .copyWith(fontWeight: FontWeight.w600, fontSize: 17),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Action buttons row: Call, Message, WhatsApp, Email
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ActionButton(
                  icon: Icons.call,
                  color: AppColors.primary,
                  enabled: !member.isPhoneHidden &&
                      (member.memberMobile?.isNotEmpty ?? false),
                  onTap: () => _launchCall(member.memberMobile!),
                ),
                const SizedBox(width: 20),
                _ActionButton(
                  icon: Icons.chat,
                  color: Colors.amber.shade700,
                  enabled: !member.isPhoneHidden &&
                      (member.memberMobile?.isNotEmpty ?? false),
                  onTap: () => _launchSms(member.memberMobile!),
                ),
                const SizedBox(width: 20),
                _ActionButton(
                  icon: Icons.email,
                  color: AppColors.primaryBlue,
                  enabled: !member.isEmailHidden &&
                      (member.memberEmail?.isNotEmpty ?? false),
                  onTap: () => _launchEmail(member.memberEmail!),
                ),
                const SizedBox(width: 20),
                _WhatsAppButton(
                  enabled: !member.isPhoneHidden &&
                      (member.memberMobile?.isNotEmpty ?? false),
                  onTap: () => _launchWhatsApp(member.memberMobile!),
                ),
                
              ],
            ),
            const SizedBox(height: 24),

            // Detail rows
            const Divider(height: 1),
            ..._buildDetailRows(),
          ],
        ),
      ),
    );
  }

  /// Format date from API format (dd/MM/yyyy) to display format (d MMM yyyy)
  /// e.g. "26/07/2002" → "26 Jul 2002"
  String? _formatDate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    try {
      final parsed = DateFormat('dd/MM/yyyy').parse(value.trim());
      return DateFormat('d MMM yyyy').format(parsed);
    } catch (_) {
      return value;
    }
  }

  List<Widget> _buildDetailRows() {
    final rows = <_DetailRow>[];

    if (member.grpName != null && member.grpName!.isNotEmpty) {
      rows.add(_DetailRow(label: 'Chapter/Branch Name', value: member.grpName!));
    }
    if (member.clubName != null && member.clubName!.isNotEmpty) {
      rows.add(_DetailRow(label: 'Club Name', value: member.clubName!));
    }
    if (member.memberIMEIID != null && member.memberIMEIID!.isNotEmpty) {
      rows.add(
          _DetailRow(label: 'Membership No.', value: member.memberIMEIID!));
    }
    if (member.membershipGrade != null &&
        member.membershipGrade!.isNotEmpty) {
      rows.add(_DetailRow(
          label: 'Membership Grade', value: member.membershipGrade!));
    }
    if (member.category != null && member.category!.isNotEmpty) {
      rows.add(_DetailRow(label: 'Category', value: member.category!));
    }
    if (member.companyName != null && member.companyName!.isNotEmpty) {
      rows.add(
          _DetailRow(label: 'Company Name', value: member.companyName!));
    }
    if (!member.isPhoneHidden &&
        member.memberMobile != null &&
        member.memberMobile!.isNotEmpty) {
      rows.add(_DetailRow(
          label: 'Mobile No. (Active WhatsApp)',
          value: member.memberMobile!));
    }
    if (!_isSecondaryHidden &&
        member.secondryMobileNo != null &&
        member.secondryMobileNo!.isNotEmpty) {
      rows.add(_DetailRow(
          label: 'Secondary Mobile No.',
          value: member.secondryMobileNo!));
    }
    final formattedDob = _formatDate(member.memberDateOfBirth);
    if (formattedDob != null) {
      rows.add(_DetailRow(label: 'Date of Birth', value: formattedDob));
    }
    final formattedAnniv = _formatDate(member.memberDateOfWedding);
    if (formattedAnniv != null) {
      rows.add(
          _DetailRow(label: 'Date of Anniversary', value: formattedAnniv));
    }
    if (member.bloodGroup != null && member.bloodGroup!.isNotEmpty) {
      rows.add(_DetailRow(label: 'Blood Group', value: member.bloodGroup!));
    }
    if (!member.isEmailHidden &&
        member.memberEmail != null &&
        member.memberEmail!.isNotEmpty) {
      rows.add(_DetailRow(label: 'Email ID', value: member.memberEmail!));
    }
    if (member.fullAddress.isNotEmpty) {
      rows.add(_DetailRow(label: 'Address', value: member.fullAddress));
    }
    if (member.pincode != null && member.pincode!.isNotEmpty) {
      rows.add(_DetailRow(label: 'Pincode', value: member.pincode!));
    }
    if (member.memberCountry != null && member.memberCountry!.isNotEmpty) {
      rows.add(_DetailRow(label: 'Country', value: member.memberCountry!));
    }

    return rows;
  }

  /// iOS: hide_num == "0" means secondary number is hidden
  bool get _isSecondaryHidden => member.hideNum == '0';

  Future<void> _launchCall(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _launchSms(String phone) async {
    final uri = Uri(scheme: 'sms', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _launchWhatsApp(String phone) async {
    final clean = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('https://wa.me/$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}

class _WhatsAppButton extends StatelessWidget {
  const _WhatsAppButton({
    required this.enabled,
    required this.onTap,
  });

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled ? Colors.green.withAlpha(25) : AppColors.grayLight,
        ),
        child: Center(
          child: enabled
              ? Image.asset('assets/images/whatsapp.png', width: 22, height: 22)
              : Image.asset('assets/images/whats_grey.png', width: 30, height: 30, color: AppColors.grayMedium),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.color,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled ? color.withAlpha(25) : AppColors.grayLight,
        ),
        child: Icon(
          icon,
          size: 22,
          color: enabled ? color : AppColors.grayMedium,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: Text(
                  label,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                child: Text(
                  value,
                  style: AppTextStyles.body2,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}
