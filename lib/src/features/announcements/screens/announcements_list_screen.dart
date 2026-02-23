import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/storage/local_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../models/announcement_list_result.dart';
import '../providers/announcements_provider.dart';
import '../widgets/announcement_card.dart';
import 'add_announcement_screen.dart';
import 'announcement_detail_screen.dart';

/// Port of iOS announcement list view — shows all announcements for a group.
/// iOS: getAllAnnouncementOFUSer with search, filter, and admin add button.
class AnnouncementsListScreen extends StatefulWidget {
  const AnnouncementsListScreen({
    super.key,
    this.groupId,
    this.profileId,
    this.moduleId = '3',
  });

  final String? groupId;
  final String? profileId;
  final String moduleId;

  @override
  State<AnnouncementsListScreen> createState() =>
      _AnnouncementsListScreenState();
}

class _AnnouncementsListScreenState extends State<AnnouncementsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _groupId = '';
  String _profileId = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Android: AnnouncementsActivity uses MEM_PROFILE_ID and GROUP_ID
  Future<void> _loadData() async {
    final localStorage = LocalStorage.instance;
    _profileId = widget.profileId ?? localStorage.memberProfileId ?? '';
    _groupId = widget.groupId ?? localStorage.groupId ?? '';

    if (!mounted) return;
    _fetchAnnouncements();
  }

  void _fetchAnnouncements({String searchText = ''}) {
    context.read<AnnouncementsProvider>().fetchAnnouncements(
          groupId: _groupId,
          memberProfileId: _profileId,
          searchText: searchText,
          moduleId: widget.moduleId,
        );
  }

  void _onSearch(String query) {
    _fetchAnnouncements(searchText: query);
  }

  /// Android: AnnouncementListAdapter passes data via Intent extras directly
  /// (no separate API call for details).
  void _onAnnouncementTap(AnnounceList announcement) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnnouncementDetailScreen(
          announcement: announcement,
        ),
      ),
    ).then((_) {
      // Refresh list when returning from detail
      _fetchAnnouncements(searchText: _searchController.text);
    });
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
          'Announcements',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 17,
            fontWeight: FontWeight.w400,
            color: AppColors.textOnPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Search announcements...',
                hintStyle: const TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14,
                  color: AppColors.grayMedium,
                ),
                prefixIcon:
                    const Icon(Icons.search, color: AppColors.grayMedium),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear,
                            color: AppColors.grayMedium),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.backgroundGray,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // List
          Expanded(
            child: Consumer<AnnouncementsProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return EmptyStateWidget(
                    icon: Icons.error_outline,
                    message: provider.error!,
                    onRetry: () =>
                        _fetchAnnouncements(searchText: _searchController.text),
                    retryLabel: 'Retry',
                  );
                }

                if (provider.announcements.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.campaign,
                    message: 'No announcements found',
                    onRetry: () =>
                        _fetchAnnouncements(searchText: _searchController.text),
                    retryLabel: 'Refresh',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async =>
                      _fetchAnnouncements(searchText: _searchController.text),
                  child: ListView.builder(
                    itemCount: provider.announcements.length,
                    itemBuilder: (_, index) {
                      final announcement = provider.announcements[index];
                      return AnnouncementCard(
                        announcement: announcement,
                        onTap: () => _onAnnouncementTap(announcement),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: AppColors.primary,
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (_) => AddAnnouncementScreen(
      //           groupId: _groupId,
      //           profileId: _profileId,
      //           moduleId: widget.moduleId,
      //         ),
      //       ),
      //     ).then((_) {
      //       _fetchAnnouncements(searchText: _searchController.text);
      //     });
      //   },
      //   child: const Icon(Icons.add, color: AppColors.textOnPrimary),
      // ),
    );
  }
}
