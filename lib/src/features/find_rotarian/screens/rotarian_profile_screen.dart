import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../models/rotarian_result.dart';
import '../providers/find_rotarian_provider.dart';

/// Port of iOS JitoProfileViewController — member profile from Find Member search.
/// Shows profile picture, name, 4 action buttons (Call, Message, WhatsApp, Email),
/// then detail rows: Chapter/Branch Name, Membership No., Membership Grade,
/// Category, Email, Date of Birth, Date of Anniversary.
class RotarianProfileScreen extends StatefulWidget {
  const RotarianProfileScreen({
    super.key,
    required this.memberProfileId,
  });

  final String memberProfileId;

  @override
  State<RotarianProfileScreen> createState() => _RotarianProfileScreenState();
}

class _RotarianProfileScreenState extends State<RotarianProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FindRotarianProvider>().fetchRotarianDetails(
          memberProfileId: widget.memberProfileId,
        );
  }

  Future<void> _makeCall(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _sendSms(String number) async {
    final uri = Uri(scheme: 'sms', path: number);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _openWhatsApp(String number) async {
    final cleaned = number.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.length < 7) return;
    final uri = Uri.parse('https://wa.me/$cleaned');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _sendEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  /// Show picker when multiple numbers/emails available.
  void _showContactPicker({
    required List<String> items,
    required String title,
    required void Function(String) onSelected,
  }) {
    if (items.isEmpty) return;
    if (items.length == 1) {
      onSelected(items.first);
      return;
    }

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
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: const CommonAppBar(title: 'Profile'),
      body: Consumer<FindRotarianProvider>(
        builder: (context, provider, _) {
          if (provider.isLoadingDetail) {
            return const Center(child: CircularProgressIndicator());
          }

          final detail = provider.selectedDetail;
          if (detail == null) {
            return const Center(
              child: Text('No details available'),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Profile header: photo + name
                _buildProfileHeader(detail),

                // 4 action buttons row
                _buildActionButtons(detail),

                const Divider(height: 1),

                // Detail rows
                _buildDetailRows(detail),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Profile photo centered + name below.
  Widget _buildProfileHeader(RotarianDetail detail) {
    return Container(
      width: double.infinity,
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Column(
        children: [
          // Circular profile image
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border, width: 1),
              color: AppColors.grayLight,
            ),
            child: ClipOval(
              child: detail.hasValidPic
                  ? Image.network(
                      detail.encodedPicUrl!,
                      fit: BoxFit.cover,
                      width: 100,
                      height: 100,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.person,
                        size: 50,
                        color: AppColors.grayMedium,
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      size: 50,
                      color: AppColors.grayMedium,
                    ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            detail.memberName ?? 'Unknown',
            style: AppTextStyles.heading5,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// iOS: 4 action buttons — Call, Message, WhatsApp, Email.
  /// Matching profile.PNG: outlined icons in a row.
  /// Icons are coloured when hide flag == "1" (visible) and greyed when "0" (hidden).
  /// If hide flag is null (not in API response), falls back to checking if data exists.
  Widget _buildActionButtons(RotarianDetail detail) {
    final phones = detail.allPhoneNumbers;
    final emails = detail.allEmails;
    // Use whatsapp number if available, else fall back to phone numbers
    final whatsappNumbers = <String>[];
    if (detail.whatsappNum != null && detail.whatsappNum!.trim().isNotEmpty) {
      whatsappNumbers.add(detail.whatsappNum!.trim());
    } else {
      whatsappNumbers.addAll(phones);
    }

    // Apply hide flag logic: "1" = visible (coloured), "0" = hidden (grey).
    // For call, SMS, WhatsApp: if EITHER hide_whatsnum or hide_num is "1",
    // all three phone-related icons are coloured.
    // If both flags are null, fall back to checking if data exists.
    final bool hasAnyPhoneFlag =
        detail.hideWhatsnum != null || detail.hideNum != null;
    final bool anyPhoneVisible =
        detail.hideWhatsnum == '1' || detail.hideNum == '1';
    final bool phoneEnabled =
        hasAnyPhoneFlag ? anyPhoneVisible : phones.isNotEmpty;
    final bool whatsappEnabled =
        hasAnyPhoneFlag ? anyPhoneVisible : whatsappNumbers.isNotEmpty;
    final bool emailEnabled = detail.hideMail != null
        ? detail.hideMail == '1'
        : emails.isNotEmpty;

    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ActionButton(
            icon: Icons.call,
            color: AppColors.primary,
            enabled: phoneEnabled,
            onTap: () => _showContactPicker(
              items: phones,
              title: 'Select Number',
              onSelected: _makeCall,
            ),
          ),
          const SizedBox(width: 24),
          _ActionButton(
            icon: Icons.chat,
            color: Colors.amber.shade700,
            enabled: phoneEnabled,
            onTap: () => _showContactPicker(
              items: phones,
              title: 'Select Number',
              onSelected: _sendSms,
            ),
          ),
          const SizedBox(width: 24),
          _ActionButton(
            icon: Icons.email,
            color: AppColors.primaryBlue,
            enabled: emailEnabled,
            onTap: () => _showContactPicker(
              items: emails,
              title: 'Select Email',
              onSelected: _sendEmail,
            ),
          ),
          const SizedBox(width: 24),
          _WhatsAppButton(
            enabled: whatsappEnabled,
            onTap: () => _showContactPicker(
              items: whatsappNumbers,
              title: 'Select Number',
              onSelected: _openWhatsApp,
            ),
          ),
        ],
      ),
    );
  }

  /// Detail rows matching profile.PNG: label on top (gray), value below (black).
  Widget _buildDetailRows(RotarianDetail detail) {
    final fields = detail.profileFields;
    if (fields.isEmpty) return const SizedBox.shrink();

    return Container(
      color: AppColors.white,
      child: Column(
        children: fields.map((entry) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.divider, width: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label (gray, smaller text)
                Text(
                  entry.key,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.grayMedium,
                  ),
                ),
                const SizedBox(height: 6),
                // Value (black, larger text)
                Text(
                  entry.value,
                  style: AppTextStyles.body2,
                ),
              ],
            ),
          );
        }).toList(),
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
          color: enabled
              ? const Color(0xFF25D366).withAlpha(25)
              : AppColors.grayLight,
        ),
        child: Center(
          child: Image.asset(
            enabled
                ? 'assets/images/whatsapp.png'
                : 'assets/images/whats_grey.png',
            width: 25,
            height: 25,
            color: enabled ? null : AppColors.grayMedium,
          ),
        ),
      ),
    );
  }
}
