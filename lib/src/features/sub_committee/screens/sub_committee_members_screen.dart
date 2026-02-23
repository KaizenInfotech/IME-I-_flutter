import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../models/sub_committee_result.dart';
import '../providers/sub_committee_provider.dart';

/// Port of iOS SubCommitteeMemberVC.
/// Shows members of a specific sub committee.
class SubCommitteeMembersScreen extends StatelessWidget {
  const SubCommitteeMembersScreen({
    super.key,
    required this.committeeId,
    required this.committeeName,
  });

  final int committeeId;
  final String committeeName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CommonAppBar(title: committeeName),
      body: Consumer<SubCommitteeProvider>(
        builder: (context, provider, _) {
          final members = provider.getMembers(committeeId);

          if (members.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.people,
              message: 'No members found',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: members.length,
            itemBuilder: (_, index) {
              return _CommitteeMemberTile(member: members[index]);
            },
          );
        },
      ),
    );
  }
}

class _CommitteeMemberTile extends StatelessWidget {
  const _CommitteeMemberTile({required this.member});

  final SubCommitteeMember member;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/sub-committee/members/profile', extra: {
          'member': member,
        });
      },
      child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Avatar placeholder
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.border,
              child: Text(
                (member.membername ?? '').isNotEmpty
                    ? member.membername![0].toUpperCase()
                    : '?',
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.membername ?? '',
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
                  if (member.branch != null && member.branch!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        member.branch!,
                        style: AppTextStyles.caption,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.primary, size: 22),
          ],
        ),
      ),
    ),
    );
  }

}
