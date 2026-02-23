import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../providers/district_provider.dart';
import '../widgets/district_member_tile.dart';
import 'district_member_detail_screen.dart';

/// Port of iOS DistrictDirectoryOnlineViewController — district directory.
/// Shows Rotarian list / Classification list toggle with search and pagination.
class DistrictDirectoryScreen extends StatefulWidget {
  const DistrictDirectoryScreen({
    super.key,
    required this.groupId,
  });

  final String groupId;

  @override
  State<DistrictDirectoryScreen> createState() =>
      _DistrictDirectoryScreenState();
}

class _DistrictDirectoryScreenState extends State<DistrictDirectoryScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadData() {
    final provider = context.read<DistrictProvider>();
    if (provider.filterMode == 'Rotarian') {
      provider.fetchDistrictMembers(groupId: widget.groupId);
    } else {
      provider.fetchClassifications(groupId: widget.groupId);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<DistrictProvider>();
      if (provider.filterMode == 'Rotarian') {
        provider.loadMoreMembers(groupId: widget.groupId);
      }
    }
  }

  void _onFilterChanged(String mode) {
    context.read<DistrictProvider>().setFilterMode(mode);
    _searchController.clear();
    _loadData();
  }

  void _onSearch(String text) {
    final provider = context.read<DistrictProvider>();
    if (provider.filterMode == 'Rotarian') {
      provider.fetchDistrictMembers(
          groupId: widget.groupId, searchText: text);
    } else {
      provider.fetchClassifications(
          groupId: widget.groupId, searchText: text);
    }
  }

  void _navigateToDetail(String profileId, String groupId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DistrictMemberDetailScreen(
          memberProfileId: profileId,
          groupId: groupId,
        ),
      ),
    );
  }

  void _navigateToClassificationMembers(String classification) {
    context.read<DistrictProvider>().fetchMembersByClassification(
          groupId: widget.groupId,
          classification: classification,
        );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ClassificationMembersScreen(
          classification: classification,
          groupId: widget.groupId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CommonAppBar(title: 'District Directory'),
      body: Column(
        children: [
          // Filter toggle + search
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Rotarian / Classification toggle
                Consumer<DistrictProvider>(
                  builder: (context, provider, _) {
                    return Row(
                      children: [
                        Expanded(
                          child: _buildFilterChip(
                            'Rotarian',
                            provider.filterMode == 'Rotarian',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildFilterChip(
                            'Classification',
                            provider.filterMode == 'Classification',
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 10),

                // Search
                TextField(
                  controller: _searchController,
                  onSubmitted: _onSearch,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: AppTextStyles.body2
                        .copyWith(color: AppColors.textSecondary),
                    prefixIcon: const Icon(Icons.search,
                        color: AppColors.textSecondary),
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
              ],
            ),
          ),
          const Divider(height: 1),

          // Content
          Expanded(
            child: Consumer<DistrictProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return EmptyStateWidget(
                    icon: Icons.error_outline,
                    message: provider.error!,
                    onRetry: _loadData,
                    retryLabel: 'Retry',
                  );
                }

                if (provider.filterMode == 'Rotarian') {
                  return _buildMemberList(provider);
                } else {
                  return _buildClassificationList(provider);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => _onFilterChanged(label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.backgroundGray,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildMemberList(DistrictProvider provider) {
    final list = provider.members;
    if (list.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.people_outline,
        message: 'No members found',
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: list.length + (provider.hasMorePages ? 1 : 0),
      itemBuilder: (_, index) {
        if (index == list.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final member = list[index];
        return DistrictMemberTile(
          member: member,
          onTap: () => _navigateToDetail(
            member.profileId ?? '',
            member.grpID ?? widget.groupId,
          ),
        );
      },
    );
  }

  Widget _buildClassificationList(DistrictProvider provider) {
    final list = provider.classifications;
    if (list.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.category,
        message: 'No classifications found',
      );
    }

    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (_, index) {
        final item = list[index];
        return InkWell(
          onTap: () => _navigateToClassificationMembers(
              item.classificationName ?? ''),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: AppColors.white,
              border: Border(
                bottom: BorderSide(color: AppColors.divider, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item.classificationName ?? 'Unknown',
                    style: AppTextStyles.body2
                        .copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
                if (item.count != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${item.count}',
                      style: AppTextStyles.captionSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right,
                    color: AppColors.primary, size: 22),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Internal screen for classification member list.
class _ClassificationMembersScreen extends StatelessWidget {
  const _ClassificationMembersScreen({
    required this.classification,
    required this.groupId,
  });

  final String classification;
  final String groupId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CommonAppBar(title: classification),
      body: Consumer<DistrictProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final list = provider.members;
          if (list.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.people_outline,
              message: 'No members found',
            );
          }

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, index) {
              final member = list[index];
              return DistrictMemberTile(
                member: member,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DistrictMemberDetailScreen(
                        memberProfileId: member.profileId ?? '',
                        groupId: member.grpID ?? groupId,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
