import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../providers/events_provider.dart';
import '../widgets/event_card.dart';
import 'add_event_screen.dart';
import 'event_detail_screen.dart';

/// Port of iOS ClubEventsListViewController.swift — event listing screen.
/// Features: search bar, event list with pagination, pull-to-refresh,
/// FAB for adding events (admin), navigation to event detail.
/// iOS: 4,241 lines → simplified Flutter equivalent.
class EventsListScreen extends StatefulWidget {
  const EventsListScreen({
    super.key,
    this.moduleName,
    this.isCategory,
    this.isAdmin = false,
  });

  final String? moduleName;
  final String? isCategory;
  final bool isAdmin;

  @override
  State<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String get _grpProfileId =>
      LocalStorage.instance.getString(AppConstants.keySessionGrpProfileId) ??
      LocalStorage.instance.grpProfileId ??
      LocalStorage.instance.masterUid ??
      '';
  String get _grpID =>
      LocalStorage.instance.getString(AppConstants.keySessionGetGroupId) ??
      LocalStorage.instance.groupIdPrimary ??
      '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadEvents());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// iOS: viewDidLoad → functionForGetEventDetails
  Future<void> _loadEvents() async {
    await context.read<EventsProvider>().fetchEventList(
          groupProfileID: _grpProfileId,
          grpId: _grpID,
          admin: widget.isAdmin ? '1' : '0',
        );
  }

  /// iOS: scrollViewDidEndDragging — pagination
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<EventsProvider>();
      if (provider.hasMorePages && !provider.isLoadingMore) {
        provider.loadMoreEvents(
          groupProfileID: _grpProfileId,
          grpId: _grpID,
          admin: widget.isAdmin ? '1' : '0',
          searchText: _searchController.text,
        );
      }
    }
  }

  /// iOS: searchBarSearchButtonClicked
  void _onSearch(String query) {
    context.read<EventsProvider>().searchEvents(
          groupProfileID: _grpProfileId,
          grpId: _grpID,
          query: query,
          admin: widget.isAdmin ? '1' : '0',
        );
  }

  void _onSearchClear() {
    _searchController.clear();
    _onSearch('');
  }

  /// iOS: buttonMainClickedEvent → navigate to event detail
  void _onEventTap(String eventID, String eventTitle) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<EventsProvider>(),
          child: EventDetailScreen(
            eventID: eventID,
            groupProfileID: _grpProfileId,
            grpId: _grpID,
            eventTitle: eventTitle,
            isCategory: widget.isCategory ?? '',
            isAdmin: widget.isAdmin,
          ),
        ),
      ),
    );
  }

  /// iOS: RefreshDataClickEvent
  Future<void> _onRefresh() async {
    await context.read<EventsProvider>().fetchEventList(
          groupProfileID: _grpProfileId,
          grpId: _grpID,
          admin: widget.isAdmin ? '1' : '0',
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
          widget.moduleName ?? 'EVENTS',
          style: const TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 17,
            fontWeight: FontWeight.w400,
            color: AppColors.textOnPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textOnPrimary),
            onPressed: _onRefresh,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar — iOS: UISearchBar
          _buildSearchBar(),
          // Event list
          Expanded(
            child: Consumer<EventsProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.events.isEmpty) {
                  return const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (provider.error != null && provider.events.isEmpty) {
                  return Center(
                    child: EmptyStateWidget(
                      icon: Icons.error_outline,
                      message: provider.error!,
                      onRetry: _loadEvents,
                    ),
                  );
                }

                if (provider.events.isEmpty) {
                  return const Center(
                    child: EmptyStateWidget(
                      icon: Icons.event_busy,
                      message: 'No events found.',
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: AppColors.primary,
                  child: ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: provider.events.length +
                        (provider.isLoadingMore ? 1 : 0),
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, indent: 0),
                    itemBuilder: (context, index) {
                      if (index >= provider.events.length) {
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
                      final event = provider.events[index];
                      return EventCard(
                        event: event,
                        onTap: () => _onEventTap(
                          event.eventID ?? '',
                          event.eventTitle ?? '',
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
      // iOS: Add event FAB (admin only)
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider.value(
                      value: context.read<EventsProvider>(),
                      child: AddEventScreen(
                        grpId: _grpID,
                        groupProfileID: _grpProfileId,
                        isCategory: widget.isCategory ?? '',
                      ),
                    ),
                  ),
                );
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: AppColors.textOnPrimary),
            )
          : null,
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search events...',
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
    );
  }
}
