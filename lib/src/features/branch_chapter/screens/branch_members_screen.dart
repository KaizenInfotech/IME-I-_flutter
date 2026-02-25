import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../models/branch_chapter_result.dart';
import '../providers/branch_chapter_provider.dart';
import 'branch_member_profile_screen.dart';

/// Port of iOS BranchMembersViewController.
/// Shows searchable list of branch members with profile pics and names.
/// When [embedded] is true, renders without Scaffold/AppBar (used inside tabs).
class BranchMembersScreen extends StatefulWidget {
  const BranchMembersScreen({
    super.key,
    required this.branchName,
    required this.groupId,
    this.embedded = false,
  });

  final String branchName;
  final String groupId;
  final bool embedded;

  @override
  State<BranchMembersScreen> createState() => _BranchMembersScreenState();
}

class _BranchMembersScreenState extends State<BranchMembersScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context
        .read<BranchChapterProvider>()
        .fetchBranchMemberDetails(widget.groupId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildBody() {
    return Consumer<BranchChapterProvider>(
      builder: (context, provider, _) {
        if (provider.isLoadingMembers) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.branchMemberDetails.isEmpty &&
            provider.membersError != null) {
          return EmptyStateWidget(
            icon: Icons.people,
            message: provider.membersError ?? 'No members found',
            onRetry: () =>
                provider.fetchBranchMemberDetails(widget.groupId),
          );
        }

        return Column(
          children: [
            // Search bar
            Container(
              color: AppColors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: AppTextStyles.body2
                      .copyWith(color: AppColors.grayMedium),
                  prefixIcon: const Icon(Icons.search,
                      color: AppColors.grayMedium, size: 20),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: AppColors.primary),
                  ),
                ),
                onChanged: (val) => provider.searchMembers(val),
              ),
            ),
            const Divider(height: 1),

            // Member list
            Expanded(
              child: provider.branchMemberDetails.isEmpty
                  ? const EmptyStateWidget(
                      icon: Icons.person_search,
                      message: 'No member found',
                    )
                  : ListView.separated(
                      itemCount: provider.branchMemberDetails.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (_, index) {
                        final member = provider.branchMemberDetails[index];
                        return _MemberListTile(
                          member: member,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    BranchMemberProfileScreen(member: member),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) {
      return _buildBody();
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: const CommonAppBar(title: 'Members'),
      body: _buildBody(),
    );
  }
}

class _MemberListTile extends StatelessWidget {
  const _MemberListTile({required this.member, required this.onTap});

  final BranchMemberDetail member;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: AppColors.grayLight,
        backgroundImage: member.hasValidPic
            ? CachedNetworkImageProvider(member.encodedPicUrl!)
            : null,
        child: !member.hasValidPic
            ? const Icon(Icons.person, color: AppColors.primary, size: 28)
            : null,
      ),
      title: Text(
        member.fullName,
        style: AppTextStyles.body2,
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.primary,
        size: 22,
      ),
    );
  }
}
