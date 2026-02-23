import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../profile/models/bod_member_result.dart';
import '../../profile/providers/profile_provider.dart';

/// Port of iOS ExecutiveCommiteeViewController.
/// Shows executive committee members using Member/GetBODList API.
/// Displays name, designation, photo, and action buttons (Call, SMS, WhatsApp, Email).
class ExecutiveCommitteeScreen extends StatefulWidget {
  const ExecutiveCommitteeScreen({
    super.key,
    required this.groupId,
  });

  final String groupId;

  @override
  State<ExecutiveCommitteeScreen> createState() =>
      _ExecutiveCommitteeScreenState();
}

class _ExecutiveCommitteeScreenState extends State<ExecutiveCommitteeScreen> {
  @override
  void initState() {
    super.initState();
    // Android: passes only grpId, searchText (empty), YearFilter (empty)
    context.read<ProfileProvider>().fetchBodList(
          groupId: widget.groupId,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: const CommonAppBar(title: 'Executive Committee'),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, _) {
          if (provider.isLoadingBod) {
            return const Center(child: CircularProgressIndicator());
          }

          final members = provider.bodMembers;
          if (members.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.groups,
              message: provider.error ?? 'No records found',
              onRetry: () => provider.fetchBodList(
                groupId: widget.groupId,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: members.length,
            itemBuilder: (_, index) {
              return _ExecutiveMemberTile(member: members[index]);
            },
          );
        },
      ),
    );
  }
}

class _ExecutiveMemberTile extends StatelessWidget {
  const _ExecutiveMemberTile({required this.member});

  final BodMember member;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Profile image
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.border,
              backgroundImage:
                  (member.pic != null && member.pic!.isNotEmpty)
                      ? NetworkImage(member.pic!)
                      : null,
              child: (member.pic == null || member.pic!.isEmpty)
                  ? const Icon(Icons.person,
                      color: AppColors.grayMedium, size: 28)
                  : null,
            ),
            const SizedBox(width: 12),
            // Name + designation
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.memberName ?? '',
                    style: AppTextStyles.body2
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (member.designation != null &&
                      member.designation!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        member.designation!,
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.primary),
                      ),
                    ),
                ],
              ),
            ),
            // Action buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (member.mobile != null && member.mobile!.isNotEmpty)
                  _actionIcon(Icons.call, () => _launchPhone(member.mobile!),
                  color: AppColors.primary),
                if (member.mobile != null && member.mobile!.isNotEmpty)
                  _actionIcon(Icons.chat, () => _launchSms(member.mobile!),
                      color: Colors.amber.shade700),
                      if (member.email != null && member.email!.isNotEmpty)
                  _actionIcon(
                      Icons.email, () => _launchEmail(member.email!),
                      color: AppColors.primaryBlue),
                if (member.mobile != null && member.mobile!.isNotEmpty)
                  InkWell(
                    onTap: () => _launchWhatsApp(member.mobile!),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Image.asset('assets/images/whatsapp.png', width: 20, height: 20),
                    ),
                  ),                
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionIcon(IconData icon, VoidCallback onTap, {Color? color}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 20, color: color ?? AppColors.primary),
      ),
    );
  }

  Future<void> _launchPhone(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _launchWhatsApp(String number) async {
    final clean = number.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('https://wa.me/91$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchSms(String number) async {
    final uri = Uri(scheme: 'sms', path: number);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}
