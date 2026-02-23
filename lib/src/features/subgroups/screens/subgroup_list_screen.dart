import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../providers/subgroups_provider.dart';
import 'add_subgroup_screen.dart';
import 'subgroup_detail_screen.dart';

/// Port of iOS SubGroupListController — sub-group list screen.
/// Shows sub-groups with member count, admin can add new sub-groups.
class SubgroupListScreen extends StatefulWidget {
  const SubgroupListScreen({
    super.key,
    this.isAdmin = false,
  });

  final bool isAdmin;

  @override
  State<SubgroupListScreen> createState() => _SubgroupListScreenState();
}

class _SubgroupListScreenState extends State<SubgroupListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<SubgroupsProvider>().fetchSubGroupList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    context.read<SubgroupsProvider>().searchSubgroups(query);
  }

  void _navigateToDetail(String subgrpId, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SubgroupDetailScreen(
          subgrpId: subgrpId,
          title: title,
        ),
      ),
    );
  }

  void _navigateToAdd() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddSubgroupScreen(),
      ),
    ).then((_) {
      if (mounted) {
        context.read<SubgroupsProvider>().fetchSubGroupList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CommonAppBar(
        title: 'Sub-Groups',
        actions: [
          if (widget.isAdmin)
            IconButton(
              icon: const Icon(Icons.add, color: AppColors.white),
              onPressed: _navigateToAdd,
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search sub-groups...',
                hintStyle: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
                prefixIcon: const Icon(Icons.search,
                    color: AppColors.textSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear,
                            color: AppColors.textSecondary),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.backgroundGray,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const Divider(height: 1),

          // Sub-groups list
          Expanded(
            child: Consumer<SubgroupsProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return EmptyStateWidget(
                    icon: Icons.error_outline,
                    message: provider.error!,
                    onRetry: () => provider.fetchSubGroupList(),
                    retryLabel: 'Retry',
                  );
                }

                final list = provider.subgroups;
                if (list.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.group_work,
                    message: 'No sub-groups found',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.fetchSubGroupList(),
                  child: ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (_, index) {
                      final item = list[index];
                      return InkWell(
                        onTap: () => _navigateToDetail(
                          item.subgrpId ?? '',
                          item.subgrpTitle ?? 'Sub-Group',
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: const BoxDecoration(
                            color: AppColors.white,
                            border: Border(
                              bottom: BorderSide(
                                  color: AppColors.divider, width: 0.5),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.group_work,
                                  color: AppColors.primary,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.subgrpTitle ?? 'Unknown',
                                      style: AppTextStyles.body2.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.displayMemberCount,
                                      style: AppTextStyles.caption,
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: AppColors.primary,
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
