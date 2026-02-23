import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../models/past_event_result.dart';
import '../providers/branch_chapter_provider.dart';

/// Port of iOS PastEventsViewController.
/// Shows past events with year picker dropdown and search.
/// APIs: Gallery/Fillyearlist, Gallery/GetAlbumsList_New.
class PastEventsScreen extends StatefulWidget {
  const PastEventsScreen({
    super.key,
    required this.groupId,
  });

  final String groupId;

  @override
  State<PastEventsScreen> createState() => _PastEventsScreenState();
}

class _PastEventsScreenState extends State<PastEventsScreen> {
  final _searchController = TextEditingController();
  String _selectedYear = '';
  bool _showYearPicker = false;

  @override
  void initState() {
    super.initState();
    // Default: current year
    _selectedYear = DateTime.now().year.toString();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final provider = context.read<BranchChapterProvider>();
    await provider.fetchYearList(grpId: widget.groupId);

    if (!mounted) return;

    // If the years list has values, use the first one or keep default
    final years = provider.years;
    if (years.isNotEmpty && !years.contains(_selectedYear)) {
      _selectedYear = years.first;
    }

    provider.fetchPastEvents(
      groupId: widget.groupId,
      year: _selectedYear,
    );
  }

  void _onYearSelected(String year) {
    setState(() {
      _selectedYear = year;
      _showYearPicker = false;
    });
    _searchController.clear();
    context.read<BranchChapterProvider>().fetchPastEvents(
          groupId: widget.groupId,
          year: year,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: const CommonAppBar(title: 'Past Events'),
      body: Consumer<BranchChapterProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              // Year picker button + search bar
              Container(
                color: AppColors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    // Year dropdown button
                    GestureDetector(
                      onTap: () {
                        setState(() => _showYearPicker = !_showYearPicker);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedYear.isNotEmpty
                                  ? _selectedYear
                                  : 'Select Year',
                              style: AppTextStyles.body2,
                            ),
                            Icon(
                              _showYearPicker
                                  ? Icons.arrow_drop_up
                                  : Icons.arrow_drop_down,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Search bar
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search events...',
                        hintStyle: AppTextStyles.body2
                            .copyWith(color: AppColors.grayMedium),
                        prefixIcon: const Icon(Icons.search,
                            color: AppColors.grayMedium, size: 20),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: AppColors.primary),
                        ),
                      ),
                      onChanged: (val) =>
                          provider.searchPastEvents(val),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Year picker list (shown/hidden)
              if (_showYearPicker)
                _buildYearList(provider),

              // Event list
              if (!_showYearPicker)
                Expanded(child: _buildEventList(provider)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildYearList(BranchChapterProvider provider) {
    if (provider.isLoadingYears) {
      return const Expanded(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final years = provider.years;
    if (years.isEmpty) {
      return const Expanded(
        child: EmptyStateWidget(
          icon: Icons.calendar_today,
          message: 'No years available',
        ),
      );
    }

    return Expanded(
      child: Container(
        color: AppColors.white,
        child: ListView.separated(
          itemCount: years.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (_, index) {
            final year = years[index];
            final isSelected = year == _selectedYear;
            return ListTile(
              title: Text(
                year,
                style: AppTextStyles.body2.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check, color: AppColors.primary, size: 20)
                  : null,
              onTap: () => _onYearSelected(year),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEventList(BranchChapterProvider provider) {
    if (provider.isLoadingPastEvents) {
      return const Center(child: CircularProgressIndicator());
    }

    final events = provider.pastEvents;
    if (events.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.event_busy,
        message: provider.pastEventsError ?? 'No events found',
        onRetry: () => provider.fetchPastEvents(
          groupId: widget.groupId,
          year: _selectedYear,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchPastEvents(
        groupId: widget.groupId,
        year: _selectedYear,
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: events.length,
        itemBuilder: (_, index) {
          final event = events[index];
          return _PastEventTile(
            event: event,
            onTap: () {
              context.push(
                '/branch-dashboard/past-events/detail',
                extra: {
                  'event': event,
                  'year': _selectedYear,
                },
              );
            },
          );
        },
      ),
    );
  }
}

/// iOS: EventNameCell with eventTitle, eventDesc, eventDate.
class _PastEventTile extends StatelessWidget {
  const _PastEventTile({required this.event, required this.onTap});

  final PastEventAlbum event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              event.title ?? '',
              style:
                  AppTextStyles.body2.copyWith(fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (event.description != null &&
                event.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                event.description!,
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (event.projectDate != null &&
                event.projectDate!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    event.projectDate!,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ],
            if (event.attendance != null &&
                event.attendance!.isNotEmpty &&
                event.attendance != '0') ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.people,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    'Attendance: ${event.attendance}',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      ),
    );
  }
}
