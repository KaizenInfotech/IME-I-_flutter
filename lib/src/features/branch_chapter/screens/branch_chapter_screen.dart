import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../providers/branch_chapter_provider.dart';
import 'branch_chapter_detail_screen.dart';
import 'branch_members_screen.dart';

/// Port of iOS Branch_ChaptViewController.
/// Shows simple list of branch/chapter names with chevron icons.
class BranchChapterScreen extends StatefulWidget {
  const BranchChapterScreen({super.key});

  @override
  State<BranchChapterScreen> createState() => _BranchChapterScreenState();
}

class _BranchChapterScreenState extends State<BranchChapterScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BranchChapterProvider>().fetchBranches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: const CommonAppBar(title: 'Branch & Chapter Committees'),
      body: Consumer<BranchChapterProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.branches.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.business,
              message: provider.error ?? 'No branches found',
              onRetry: () => provider.fetchBranches(),
            );
          }

          return ListView.separated(
            itemCount: provider.branches.length,
            separatorBuilder: (_, _) =>
                const Divider(height: 1, indent: 16, endIndent: 16),
            itemBuilder: (_, index) {
              final branch = provider.branches[index];
              return ListTile(
                title: Text(
                  branch.groupName ?? '',
                  style: AppTextStyles.body2,
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppColors.primary,
                  size: 22,
                ),
                onTap: () {
                  if (index == 0) {
                    // iOS: First item (Head Office) → BranchMembersViewController directly
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BranchMembersScreen(
                          branchName: branch.groupName ?? '',
                          groupId: (branch.groupId ?? 0).toString(),
                        ),
                      ),
                    );
                  } else {
                    // iOS: Other branches → BranchChaptDetailViewController
                    // with Office Barriers + Members tabs
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BranchChapterDetailScreen(
                          branchName: branch.groupName ?? '',
                          branchAddress: branch.address ?? '',
                          groupId: branch.groupId ?? 0,
                        ),
                      ),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
