import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/storage/local_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/common_loader.dart';
import '../../../core/widgets/common_toast.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../providers/events_provider.dart';

/// Port of iOS ClubEventsListViewController.swift.
/// Shows a searchable list of club events with title, date, venue, and
/// RSVP count. Tapping navigates to event detail.
class ClubEventsListScreen extends StatefulWidget {
  const ClubEventsListScreen({
    super.key,
    required this.groupId,
    this.profileId,
    this.moduleName,
  });

  final String groupId;
  final String? profileId;
  final String? moduleName;

  @override
  State<ClubEventsListScreen> createState() => _ClubEventsListScreenState();
}

class _ClubEventsListScreenState extends State<ClubEventsListScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  String get _profileId =>
      widget.profileId ??
      LocalStorage.instance.grpProfileId ??
      '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadEvents());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// iOS: functionForGetEventDetails — fetch club events
  Future<void> _loadEvents() async {
    final provider = context.read<EventsProvider>();
    CommonLoader.show(context);

    final success = await provider.fetchEventList(
      groupProfileID: _profileId,
      grpId: widget.groupId,
    );

    if (!mounted) return;
    CommonLoader.dismiss(context);

    if (!success && provider.error != null) {
      CommonToast.error(context, provider.error!);
    }
  }

  /// iOS: SearchFromMemberNameAndYear — search events
  Future<void> _searchEvents(String query) async {
    await context.read<EventsProvider>().searchEvents(
          groupProfileID: _profileId,
          grpId: widget.groupId,
          query: query,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CommonAppBar(
        title: widget.moduleName ?? 'Club Events',
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: AppColors.textOnPrimary,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _loadEvents();
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // iOS: searchBar
          if (_isSearching)
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search events...',
                  hintStyle: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  prefixIcon:
                      const Icon(Icons.search, color: AppColors.textSecondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
                onSubmitted: _searchEvents,
                onChanged: (value) {
                  if (value.isEmpty) _loadEvents();
                },
              ),
            ),
          // Events list
          Expanded(
            child: Consumer<EventsProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                final events = provider.events;

                if (events.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.event_busy,
                    message: 'No events found',
                    onRetry: _loadEvents,
                    retryLabel: 'Refresh',
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _loadEvents,
                  child: ListView.separated(
                    itemCount: events.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final event = events[index];

                      return InkWell(
                        onTap: () {
                          // iOS: buttonMainClickedEvent → navigate to detail
                          context.push(
                            '/events/${event.eventID ?? ''}',
                            extra: {
                              'groupProfileID': _profileId,
                              'grpId': widget.groupId,
                              'eventTitle': event.eventTitle ?? '',
                            },
                          );
                        },
                        child: Container(
                          color: AppColors.white,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // iOS: eventTitle
                              Text(
                                event.eventTitle ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              // iOS: eventDateTime
                              if (event.eventDateTime != null &&
                                  event.eventDateTime!.isNotEmpty)
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today,
                                        size: 14,
                                        color: AppColors.primaryBlue),
                                    const SizedBox(width: 6),
                                    Text(
                                      event.eventDateTime!,
                                      style: const TextStyle(
                                        fontFamily: AppTextStyles.fontFamily,
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 4),
                              // iOS: venue
                              if (event.venue != null &&
                                  event.venue!.isNotEmpty)
                                Row(
                                  children: [
                                    const Icon(Icons.location_on,
                                        size: 14, color: AppColors.systemRed),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        event.venue!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontFamily: AppTextStyles.fontFamily,
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 6),
                              // iOS: goingCount, maybeCount, notgoingCount
                              Row(
                                children: [
                                  _rsvpChip('Going',
                                      event.goingCount ?? '0', AppColors.green),
                                  const SizedBox(width: 8),
                                  _rsvpChip('Maybe',
                                      event.maybeCount ?? '0', AppColors.orange),
                                  const SizedBox(width: 8),
                                  _rsvpChip(
                                      'Not Going',
                                      event.notgoingCount ?? '0',
                                      AppColors.systemRed),
                                ],
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

  Widget _rsvpChip(String label, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label: $count',
        style: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}
