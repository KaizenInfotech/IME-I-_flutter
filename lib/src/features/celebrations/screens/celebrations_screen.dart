import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/storage/local_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../models/celebration_result.dart';
import '../providers/celebrations_provider.dart';
import '../widgets/calendar_grid.dart';
import '../widgets/celebration_list_tile.dart';
import '../widgets/celebration_tab_bar.dart';
import 'district_event_detail_screen.dart';

/// Shows calendar month view + three tabs (Birthday/Anniversary/Event).
/// Uses Celebrations/GetMonthEventListTypeWise_National with static
/// groupCategory:"2" and Type: B/A/E per tab.
/// Matches Android calendar screenshot: white AppBar, MONTH dropdown,
/// flat tabs, section header, list without type icons.
class CelebrationsScreen extends StatefulWidget {
  const CelebrationsScreen({
    super.key,
    this.groupId,
    this.profileId,
  });

  final String? groupId;
  final String? profileId;

  @override
  State<CelebrationsScreen> createState() => _CelebrationsScreenState();
}

class _CelebrationsScreenState extends State<CelebrationsScreen> {
  int _selectedTabIndex = 0;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String _profileId = '';
  String _groupId = '';
  bool _showCalendar = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _loadData();
  }

  Future<void> _loadData() async {
    final localStorage = LocalStorage.instance;
    _profileId = widget.profileId ??
        localStorage.authProfileId ??
        '';
    _groupId = widget.groupId ??
        localStorage.authGroupId ??
        '';

    if (!mounted) return;

    final provider = context.read<CelebrationsProvider>();

    // Fetch month events for calendar markers
    await provider.fetchMonthEvents(
      profileId: _profileId,
      groupId: _groupId,
    );

    if (!mounted) return;
    // Fetch initial tab data
    _fetchTabData();
  }

  String? get _selectedDateStr {
    if (_selectedDay == null) return null;
    return '${_selectedDay!.year}-${_selectedDay!.month.toString().padLeft(2, '0')}-${_selectedDay!.day.toString().padLeft(2, '0')}';
  }

  void _fetchTabData() {
    final provider = context.read<CelebrationsProvider>();
    final date = _selectedDateStr;
    switch (_selectedTabIndex) {
      case 0:
        provider.fetchBirthdays(groupId: _groupId, selectedDate: date);
        break;
      case 1:
        provider.fetchAnniversaries(groupId: _groupId, selectedDate: date);
        break;
      case 2:
        provider.fetchEvents(groupId: _groupId, selectedDate: date);
        break;
    }
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
    _fetchTabData();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    // Re-fetch tab data for the newly selected date
    _fetchTabData();
  }

  void _onPageChanged(DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
    });

    final provider = context.read<CelebrationsProvider>();
    provider.setSelectedMonth(focusedDay);
    provider.fetchMonthEvents(
      profileId: _profileId,
      groupId: _groupId,
    );
    _fetchTabData();
  }

  void _toggleCalendar() {
    setState(() {
      _showCalendar = !_showCalendar;
    });
  }

  void _onEventTap(CelebrationEvent event) {
    // Navigate to detail passing event data directly (matches Android Intent extras).
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DistrictEventDetailScreen(event: event),
      ),
    );
  }

  String get _sectionHeaderText {
    switch (_selectedTabIndex) {
      case 0:
        return "Today's Birthdays";
      case 1:
        return "Today's Anniversaries";
      case 2:
        return 'Events';
      default:
        return '';
    }
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
          'Calendar',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 17,
            fontWeight: FontWeight.w400,
            color: AppColors.textOnPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: _toggleCalendar,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.textOnPrimary, width: 1.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'MONTH',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _showCalendar
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: AppColors.textOnPrimary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<CelebrationsProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              // Tab bar — BIRTHDAY / ANNIVERSARY / EVENTS
              CelebrationTabBar(
                selectedIndex: _selectedTabIndex,
                onTabSelected: _onTabChanged,
              ),

              // Calendar grid — hidden by default, toggled by MONTH button
              if (_showCalendar)
                CelebrationCalendarGrid(
                  focusedDay: _focusedDay,
                  selectedDay: _selectedDay,
                  eventDates: provider.eventDates,
                  onDaySelected: _onDaySelected,
                  onPageChanged: _onPageChanged,
                ),

              // Tab content
              Expanded(
                child: _buildTabContent(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabContent(CelebrationsProvider provider) {
    switch (_selectedTabIndex) {
      case 0:
        return _buildList(
          provider.birthdays,
          provider.isBirthdayLoading,
          'No birthdays found',
        );
      case 1:
        return _buildList(
          provider.anniversaries,
          provider.isAnniversaryLoading,
          'No anniversaries found',
        );
      case 2:
        return _buildEventsList(
          provider.eventsList,
          provider.isEventsLoading,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildList(
    List<CelebrationEvent> events,
    bool isLoading,
    String emptyMessage, {
    bool showActions = true,
  }) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (events.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.celebration,
        message: emptyMessage,
        onRetry: _fetchTabData,
        retryLabel: 'Refresh',
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _fetchTabData(),
      child: ListView.builder(
        itemCount: events.length + 1, // +1 for section header
        itemBuilder: (_, index) {
          if (index == 0) {
            // Section header
            return _buildSectionHeader();
          }
          return CelebrationListTile(
            event: events[index - 1],
            showActions: showActions,
          );
        },
      ),
    );
  }

  Widget _buildEventsList(
    List<CelebrationEvent> events,
    bool isLoading,
  ) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (events.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.event,
        message: 'No events found',
        onRetry: _fetchTabData,
        retryLabel: 'Refresh',
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _fetchTabData(),
      child: ListView.builder(
        itemCount: events.length + 1,
        itemBuilder: (_, index) {
          if (index == 0) {
            return _buildSectionHeader();
          }
          final event = events[index - 1];
          return _buildEventTile(event);
        },
      ),
    );
  }

  Widget _buildEventTile(CelebrationEvent event) {
    return InkWell(
      onTap: () => _onEventTap(event),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(
            bottom: BorderSide(color: AppColors.border, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                event.displayTitle,
                style: const TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right,
                color: AppColors.grayMedium, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      child: Text(
        _sectionHeaderText,
        style: const TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryBlue,
        ),
      ),
    );
  }
}
