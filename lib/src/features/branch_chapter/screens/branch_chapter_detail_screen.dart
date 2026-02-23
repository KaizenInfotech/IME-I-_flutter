import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../models/branch_chapter_result.dart';
import '../providers/branch_chapter_provider.dart';
import 'branch_members_screen.dart';

/// Port of iOS BranchChaptDetailViewController.
/// Tabbed screen: "OFFICE BARRIERS" (from Table1) + "Members" (from GetMemberListSync).
class BranchChapterDetailScreen extends StatefulWidget {
  const BranchChapterDetailScreen({
    super.key,
    required this.branchName,
    required this.branchAddress,
    required this.groupId,
  });

  final String branchName;
  final String branchAddress;
  final int groupId;

  @override
  State<BranchChapterDetailScreen> createState() =>
      _BranchChapterDetailScreenState();
}

class _BranchChapterDetailScreenState extends State<BranchChapterDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CommonAppBar(title: 'Branch & Chapters Committees'),
      body: Column(
        children: [
          // Tab bar
          Container(
            color: AppColors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelStyle:
                  AppTextStyles.body2.copyWith(fontWeight: FontWeight.w700),
              unselectedLabelStyle: AppTextStyles.body2,
              tabs: const [
                Tab(text: 'OFFICE BARRIERS'),
                Tab(text: 'Members'),
              ],
            ),
          ),
          const Divider(height: 1),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Office Barriers
                _OfficeBearersTab(
                  branchName: widget.branchName,
                  branchAddress: widget.branchAddress,
                  groupId: widget.groupId,
                ),
                // Tab 2: Members
                BranchMembersScreen(
                  branchName: widget.branchName,
                  groupId: widget.groupId.toString(),
                  embedded: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Office Bearers tab — shows branch name, address, and office bearer list from Table1.
class _OfficeBearersTab extends StatelessWidget {
  const _OfficeBearersTab({
    required this.branchName,
    required this.branchAddress,
    required this.groupId,
  });

  final String branchName;
  final String branchAddress;
  final int groupId;

  @override
  Widget build(BuildContext context) {
    return Consumer<BranchChapterProvider>(
      builder: (context, provider, _) {
        final members = provider.getBranchMembers(groupId);

        return ListView(
          children: [
            // Branch name
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                branchName,
                style:
                    AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            // Address
            if (branchAddress.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text(
                  branchAddress,
                  style: AppTextStyles.body2
                      .copyWith(color: AppColors.textSecondary),
                ),
              ),
            const Divider(height: 1),

            if (members.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: EmptyStateWidget(
                  icon: Icons.people,
                  message: 'No office bearers found',
                ),
              )
            else
              ...members.map((m) => _OfficeBearerTile(member: m)),
          ],
        );
      },
    );
  }
}

/// Single office bearer tile matching barrier.PNG:
/// Designation label, profile icon + name, then call/msg/email/whatsapp icons.
class _OfficeBearerTile extends StatelessWidget {
  const _OfficeBearerTile({required this.member});

  final BranchMemberItem member;

  @override
  Widget build(BuildContext context) {
    final name = member.memberName ?? '';
    final designation = member.designation ?? '';
    final mobile = member.mobileNo ?? '';
    final email = member.emailId ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Designation label
        if (designation.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(68, 12, 16, 4),
            child: Text(
              designation,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textSecondary),
            ),
          ),

        // Profile icon + Name
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.grayLight,
                child:
                    Icon(Icons.person, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: AppTextStyles.body2
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),

        // Action icons row
        Padding(
          padding: const EdgeInsets.fromLTRB(56, 4, 16, 8),
          child: Row(
            children: [
              if (mobile.isNotEmpty)
                _actionIcon(Icons.call, AppColors.primary, () async {
                  final uri = Uri(scheme: 'tel', path: mobile);
                  if (await canLaunchUrl(uri)) await launchUrl(uri);
                }),
              if (mobile.isNotEmpty)
                _actionIcon(Icons.chat, Colors.amber.shade700,
                    () async {
                  final uri = Uri(scheme: 'sms', path: mobile);
                  if (await canLaunchUrl(uri)) await launchUrl(uri);
                }),
              if (email.isNotEmpty)
                _actionIcon(Icons.email, AppColors.primaryBlue, () async {
                  final uri = Uri(scheme: 'mailto', path: email);
                  if (await canLaunchUrl(uri)) await launchUrl(uri);
                }),
              if (mobile.isNotEmpty)
                InkWell(
                  onTap: () async {
                    final clean =
                        mobile.replaceAll(RegExp(r'[^0-9+]'), '');
                    final uri = Uri.parse('https://wa.me/$clean');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                    }
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Image.asset('assets/images/whatsapp.png',
                        width: 22, height: 22),
                  ),
                ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _actionIcon(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 22, color: color),
      ),
    );
  }
}
