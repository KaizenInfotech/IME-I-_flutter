import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../providers/district_provider.dart';

/// Port of iOS DistrictClubMemberListViewController — district clubs list.
/// Shows list of clubs in the district with search.
class DistrictClubMembersScreen extends StatefulWidget {
  const DistrictClubMembersScreen({
    super.key,
    required this.groupId,
  });

  final String groupId;

  @override
  State<DistrictClubMembersScreen> createState() =>
      _DistrictClubMembersScreenState();
}

class _DistrictClubMembersScreenState extends State<DistrictClubMembersScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context
        .read<DistrictProvider>()
        .fetchDistrictClubs(groupId: widget.groupId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    context.read<DistrictProvider>().searchClubs(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CommonAppBar(title: 'District Clubs'),
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
                hintText: 'Search clubs...',
                hintStyle: AppTextStyles.body2
                    .copyWith(color: AppColors.textSecondary),
                prefixIcon:
                    const Icon(Icons.search, color: AppColors.textSecondary),
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

          // Clubs list
          Expanded(
            child: Consumer<DistrictProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final list = provider.clubs;
                if (list.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.business,
                    message: 'No clubs found',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.fetchDistrictClubs(
                      groupId: widget.groupId),
                  child: ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (_, index) {
                      final club = list[index];
                      return InkWell(
                        onTap: () {
                          // Navigate to club detail (reuses find_club detail)
                        },
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
                                  Icons.business,
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
                                      club.clubName ?? 'Unknown',
                                      style: AppTextStyles.body2.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (club.displayMeetingInfo
                                        .isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        club.displayMeetingInfo,
                                        style: AppTextStyles.caption,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right,
                                  color: AppColors.primary, size: 22),
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
