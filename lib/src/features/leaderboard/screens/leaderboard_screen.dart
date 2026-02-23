import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../models/leaderboard_result.dart';
import '../providers/leaderboard_provider.dart';
import '../widgets/leaderboard_collection_cell.dart';
import '../widgets/leaderboard_table_cell.dart';

/// Port of iOS LeaderBoardViewController.
/// Shows zone/year filter dropdowns, stats grid, and ranked clubs list.
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({
    super.key,
    required this.groupId,
    required this.profileId,
    this.moduleName = 'Leaderboard',
  });

  final String groupId;
  final String profileId;
  final String moduleName;

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<LeaderboardProvider>().initialize(
          groupId: widget.groupId,
          profileId: widget.profileId,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CommonAppBar(title: widget.moduleName),
      body: Consumer<LeaderboardProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.leaderboardData == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Zone & Year filter row
              _buildFilterRow(provider),
              const Divider(height: 1),

              // Content
              Expanded(
                child: provider.leaderboardData == null
                    ? EmptyStateWidget(
                        icon: Icons.leaderboard,
                        message: provider.error ?? 'No Record Found',
                      )
                    : _buildContent(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterRow(LeaderboardProvider provider) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Zone dropdown
          Expanded(
            child: GestureDetector(
              onTap: () => _showZonePicker(provider),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        provider.selectedZone?.zoneName ?? 'All',
                        style: AppTextStyles.body2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down,
                        color: AppColors.textSecondary, size: 20),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Year dropdown
          Expanded(
            child: GestureDetector(
              onTap: () => _showYearPicker(provider),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        provider.displayYear,
                        style: AppTextStyles.body2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down,
                        color: AppColors.textSecondary, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(LeaderboardProvider provider) {
    final data = provider.leaderboardData!;
    final stats = data.statsItems;
    final entries = data.leaderBoardResult ?? [];

    return RefreshIndicator(
      onRefresh: () => provider.fetchLeaderboard(
        groupId: widget.groupId,
        profileId: widget.profileId,
      ),
      child: ListView(
        children: [
          // Stats grid (collection view)
          if (stats.isNotEmpty) _buildStatsGrid(stats),

          const SizedBox(height: 8),

          // Leaderboard list header
          if (entries.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: AppColors.backgroundGray,
              child: Row(
                children: [
                  const SizedBox(width: 32 + 12),
                  Expanded(
                    child: Text('Club Name',
                        style: AppTextStyles.label
                            .copyWith(fontWeight: FontWeight.w600)),
                  ),
                  Text('Points',
                      style: AppTextStyles.label
                          .copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            ),

          // Ranked clubs
          if (entries.isNotEmpty)
            ...entries.asMap().entries.map((e) => LeaderboardTableCell(
                  entry: e.value,
                  rank: e.key + 1,
                ))
          else
            Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'This place is reserved for Clubs to show their citation points.',
                style: AppTextStyles.body2
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(List<LeaderBoardStat> stats) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.9,
        ),
        itemCount: stats.length,
        itemBuilder: (_, index) => LeaderboardCollectionCell(
          stat: stats[index],
          index: index,
        ),
      ),
    );
  }

  void _showZonePicker(LeaderboardProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Select Zone', style: AppTextStyles.heading6),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: provider.zones.length,
                itemBuilder: (_, index) {
                  final zone = provider.zones[index];
                  return ListTile(
                    title: Text(zone.zoneName ?? ''),
                    trailing: zone.pkZoneId ==
                            provider.selectedZone?.pkZoneId
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () {
                      Navigator.pop(ctx);
                      provider.selectZone(zone);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showYearPicker(LeaderboardProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Select Year', style: AppTextStyles.heading6),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: provider.yearOptions.length,
                itemBuilder: (_, index) {
                  final year = provider.yearOptions[index];
                  final parts = year.split('-');
                  final display = parts.length == 2
                      ? '${parts[0].substring(parts[0].length - 2)}-${parts[1].substring(parts[1].length - 2)}'
                      : year;
                  return ListTile(
                    title: Text(display),
                    trailing: year == provider.selectedYear
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () {
                      Navigator.pop(ctx);
                      provider.selectYear(year);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
