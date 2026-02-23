import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../models/governing_council_result.dart';
import '../providers/governing_council_provider.dart';

/// Port of iOS GoverningCouncilViewController.
/// Shows governing council members with year filter and contact actions.
/// Matches Android member.jpg screenshot layout.
class GoverningCouncilScreen extends StatefulWidget {
  const GoverningCouncilScreen({super.key});

  @override
  State<GoverningCouncilScreen> createState() =>
      _GoverningCouncilScreenState();
}

class _GoverningCouncilScreenState extends State<GoverningCouncilScreen> {
  @override
  void initState() {
    super.initState();
    final provider = context.read<GoverningCouncilProvider>();
    provider.fetchCouncilMembers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textOnPrimary),
        title: const Text(
          'Governing Council Members',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 17,
            fontWeight: FontWeight.w400,
            color: AppColors.textOnPrimary,
          ),
        ),
      ),
      body: Consumer<GoverningCouncilProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.members.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.groups,
              message: provider.error ?? 'No records found',
              onRetry: () => provider.fetchCouncilMembers(),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.only(top: 0),
            itemCount: provider.members.length,
            separatorBuilder: (_, _) =>
                const Divider(height: 1, color: AppColors.border),
            itemBuilder: (_, index) {
              return _CouncilMemberTile(member: provider.members[index]);
            },
          );
        },
      ),
    );
  }
}

class _CouncilMemberTile extends StatelessWidget {
  const _CouncilMemberTile({required this.member});

  final CouncilMember member;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile image — large circle matching screenshot
          CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.border,
            backgroundImage:
                (member.pic != null && member.pic!.isNotEmpty)
                    ? NetworkImage(member.pic!)
                    : null,
            child: (member.pic == null || member.pic!.isEmpty)
                ? const Icon(Icons.person, color: AppColors.grayMedium, size: 36)
                : null,
          ),
          const SizedBox(width: 16),
          // Info + action buttons below
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Designation (gray, above name)
                if (member.memberDesignation != null &&
                    member.memberDesignation!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      member.memberDesignation!,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                // Member name (bold, black)
                Text(
                  member.memberName ?? '',
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                // Contact action buttons — below name
                _buildActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final hasMobile = member.membermobile != null && member.membermobile!.isNotEmpty;
    final hasEmail = member.email != null && member.email!.isNotEmpty;

    return Row(
      children: [
        // Phone
        _actionIcon(
          Icons.phone,
          AppColors.primary,
          hasMobile ? () => _launchPhone(member.membermobile!) : null,
        ),
        const SizedBox(width: 20),
        // Message
        _actionIcon(
          Icons.chat,
          Colors.amber.shade700,
          hasMobile ? () => _launchSms(member.membermobile!) : null,
        ),
        const SizedBox(width: 20),
        // Email
        _actionIcon(
          Icons.email,
          AppColors.primaryBlue,
          hasEmail ? () => _launchEmail(member.email!) : null,
        ),
        const SizedBox(width: 20),
        // WhatsApp
        GestureDetector(
          onTap: hasMobile ? () => _launchWhatsApp(member.membermobile!) : null,
          child: hasMobile
              ? Image.asset('assets/images/whatsapp.png', width: 26, height: 26)
              : Image.asset('assets/images/whats_grey.png', width: 22, height: 22, color: AppColors.grayMedium),
        ),
      ],
    );
  }

  Widget _actionIcon(IconData icon, Color color, VoidCallback? onTap) {
    final effectiveColor = onTap != null ? color : AppColors.grayMedium;
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, size: 26, color: effectiveColor),
    );
  }

  Future<void> _launchPhone(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _launchSms(String number) async {
    final uri = Uri(scheme: 'sms', path: number);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _launchWhatsApp(String number) async {
    final clean = number.replaceAll(RegExp(r'[^0-9+]'), '');
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
