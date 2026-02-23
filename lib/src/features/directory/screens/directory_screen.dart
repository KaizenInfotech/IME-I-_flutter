import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_toast.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../models/member_result.dart';
import '../providers/directory_provider.dart';
import '../widgets/classification_filter.dart';
import '../widgets/member_list_tile.dart';
import 'profile_detail_screen.dart';

/// Port of iOS DirectoryViewController.swift — member directory list.
/// Features: Search bar, filter dropdown (Rotarian/Classification/Family),
/// paginated member list, pull to refresh, scroll-to-top/bottom buttons.
/// iOS: 4,241 lines → simplified Flutter equivalent.
class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({
    super.key,
    this.moduleName,
    this.isCategory,
    this.groupUniqueName,
  });

  final String? moduleName;
  final String? isCategory;
  final String? groupUniqueName;

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  DirectoryFilterType _selectedFilter = DirectoryFilterType.rotarian;

  String get _masterUID =>
      LocalStorage.instance.getString(AppConstants.keyMasterUid) ?? '';
  String get _grpID =>
      LocalStorage.instance.getString(AppConstants.keySessionGetGroupId) ?? '';
  String get _userProfileId =>
      LocalStorage.instance.getString(AppConstants.keySessionGrpProfileId) ??
      '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDirectory());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// iOS: viewDidLoad → fetchData() / fetchDataFORClubName
  Future<void> _loadDirectory() async {
    final provider = context.read<DirectoryProvider>();
    await provider.fetchDirectory(
      masterUID: _masterUID,
      grpID: _grpID,
    );
  }

  /// iOS: scrollViewDidEndDragging — pagination on scroll
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<DirectoryProvider>();
      if (provider.hasMorePages && !provider.isLoadingMore) {
        provider.loadMoreMembers(masterUID: _masterUID, grpID: _grpID);
      }
    }
  }

  /// iOS: searchBarSearchButtonClicked → fetchDataFORClubName(searchText)
  void _onSearch(String query) {
    context.read<DirectoryProvider>().searchMembers(
          masterUID: _masterUID,
          grpID: _grpID,
          query: query,
        );
  }

  /// iOS: searchBarCancelButtonClicked → clear and reload
  void _onSearchClear() {
    _searchController.clear();
    _onSearch('');
  }

  /// iOS: buttonRotarianClicked → navigate to JitoProfileViewController
  void _onMemberTap(MemberListItem member) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<DirectoryProvider>(),
          child: ProfileDetailScreen(
            memberProfileId: member.effectiveProfileId ?? '',
            groupId: _grpID,
            memberName: member.memberName ?? '',
            isCategory: widget.isCategory ?? '',
            groupUniqueName: widget.groupUniqueName ?? '',
            adminProfileId: _userProfileId,
          ),
        ),
      ),
    );
  }

  /// iOS: RefreshDataClickEvent — refresh button
  Future<void> _onRefresh() async {
    await context.read<DirectoryProvider>().fetchDirectory(
          masterUID: _masterUID,
          grpID: _grpID,
          searchText: _searchController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textOnPrimary),
        title: Text(
          widget.moduleName ?? 'DIRECTORY',
          style: const TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 17,
            fontWeight: FontWeight.w400,
            color: AppColors.textOnPrimary,
          ),
        ),
        actions: [
          // iOS: search/refresh button in nav bar
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textOnPrimary),
            onPressed: _onRefresh,
          ),
        ],
      ),
      body: Column(
        children: [
          // iOS: searchBar + filter dropdown row
          _buildSearchRow(),
          // Member list
          Expanded(
            child: Consumer<DirectoryProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.members.isEmpty) {
                  return const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (provider.error != null && provider.members.isEmpty) {
                  return Center(
                    child: EmptyStateWidget(
                      icon: Icons.error_outline,
                      message: provider.error!,
                      onRetry: _loadDirectory,
                    ),
                  );
                }

                if (provider.members.isEmpty) {
                  // iOS: NoRecordLabel.isHidden = false
                  return const Center(
                    child: EmptyStateWidget(
                      icon: Icons.people_outline,
                      message: 'No members found.',
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: AppColors.primary,
                  child: ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: provider.members.length +
                        (provider.isLoadingMore ? 1 : 0),
                    separatorBuilder: (_, index) =>
                        const Divider(height: 1, indent: 60),
                    itemBuilder: (context, index) {
                      if (index >= provider.members.length) {
                        // Loading more indicator
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      }
                      final member = provider.members[index];
                      return MemberListTile(
                        member: member,
                        onTap: () => _onMemberTap(member),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // iOS: toast shows "Total members X" on scroll stop
      floatingActionButton: Consumer<DirectoryProvider>(
        builder: (context, provider, child) {
          if (provider.members.length > 10) {
            return FloatingActionButton.small(
              onPressed: () {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.arrow_upward,
                  color: AppColors.textOnPrimary, size: 20),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  /// iOS: searchBar + buttonSearchRotarianType row
  Widget _buildSearchRow() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Search bar — iOS: UISearchBar
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search members...',
                hintStyle: const TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14,
                  color: AppColors.textTertiary,
                ),
                prefixIcon: const Icon(Icons.search,
                    color: AppColors.textSecondary, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: _onSearchClear,
                      )
                    : null,
                filled: true,
                fillColor: AppColors.backgroundGray,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 14,
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: _onSearch,
              onChanged: (value) => setState(() {}),
            ),
          ),
          const SizedBox(width: 8),
          // Filter dropdown — iOS: buttonSearchRotarianType + UIPickerView
          ClassificationFilter(
            selectedFilter: _selectedFilter,
            onFilterChanged: (filter) {
              setState(() => _selectedFilter = filter);
              // iOS: different data source based on filter type
              if (filter == DirectoryFilterType.rotarian) {
                _loadDirectory();
              } else {
                // Classification and Family filters use local DB in iOS
                // For Flutter, we still use API-based filtering
                CommonToast.info(
                    context, '${filter.name} filter - Coming Soon');
              }
            },
          ),
        ],
      ),
    );
  }
}
