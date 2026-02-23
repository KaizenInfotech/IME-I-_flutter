import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/storage/local_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/common_toast.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../models/ebulletin_list_result.dart';
import '../providers/ebulletin_provider.dart';
import '../widgets/ebulletin_card.dart';
import 'add_ebulletin_screen.dart';
import 'ebulletin_detail_screen.dart';

/// Port of iOS EBulletinListingController — year-wise e-bulletin list.
/// iOS: Year picker filter, search, admin add/delete.
class EbulletinListScreen extends StatefulWidget {
  const EbulletinListScreen({
    super.key,
    this.groupId,
    this.profileId,
    this.isAdmin = false,
    this.moduleId = '',
  });

  final String? groupId;
  final String? profileId;
  final bool isAdmin;
  final String moduleId;

  @override
  State<EbulletinListScreen> createState() => _EbulletinListScreenState();
}

class _EbulletinListScreenState extends State<EbulletinListScreen> {
  final _searchController = TextEditingController();
  String _groupId = '';
  String _profileId = '';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final provider = context.read<EbulletinProvider>();
    provider.initYearOptions();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    final localStorage = LocalStorage.instance;
    _profileId = widget.profileId ?? localStorage.authProfileId ?? '';
    _groupId = widget.groupId ?? localStorage.authGroupId ?? '';
    _fetchEbulletins();
  }

  void _fetchEbulletins() {
    context.read<EbulletinProvider>().fetchYearWiseList(
          memberProfileId: _profileId,
          groupId: _groupId,
        );
  }

  void _onSearch(String query) {
    setState(() => _searchQuery = query);
  }

  void _onYearChanged(String year) {
    context.read<EbulletinProvider>().setSelectedYear(year);
    _fetchEbulletins();
  }

  void _onEbulletinTap(EbulletinItem item) {
    // iOS: if external URL, open in Safari; if document, open detail
    if (item.isExternalUrl) {
      _openExternalUrl(item.ebulletinlink!);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EbulletinDetailScreen(
            ebulletin: item,
            profileId: _profileId,
            isAdmin: widget.isAdmin,
          ),
        ),
      ).then((_) => _fetchEbulletins());
    }
  }

  Future<void> _openExternalUrl(String url) async {
    String finalUrl = url;
    if (!finalUrl.startsWith('http://') && !finalUrl.startsWith('https://')) {
      finalUrl = 'https://$finalUrl';
    }
    final uri = Uri.tryParse(finalUrl);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _onDeleteEbulletin(EbulletinItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete E-Bulletin'),
        content: Text(
            'Are you sure you want to delete "${item.ebulletinTitle}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.systemRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final success = await context.read<EbulletinProvider>().deleteEbulletin(
          ebulletinId: item.ebulletinID ?? '',
          profileId: _profileId,
        );

    if (!mounted) return;
    if (success) {
      CommonToast.success(context, 'E-Bulletin deleted');
    } else {
      CommonToast.error(context, 'Failed to delete e-bulletin');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CommonAppBar(
        title: 'E-Bulletin',
        actions: [
          if (widget.isAdmin)
            IconButton(
              icon: const Icon(Icons.add, color: AppColors.textOnPrimary),
              onPressed: _navigateToAdd,
            ),
        ],
      ),
      body: Column(
        children: [
          // Search and year filter
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Search field
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearch,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search e-bulletins...',
                      hintStyle: const TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 14,
                        color: AppColors.grayMedium,
                      ),
                      prefixIcon: const Icon(Icons.search,
                          color: AppColors.grayMedium),
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
                const SizedBox(width: 8),

                // Year filter (iOS: pickerView)
                Consumer<EbulletinProvider>(
                  builder: (context, provider, _) {
                    return PopupMenuButton<String>(
                      onSelected: _onYearChanged,
                      itemBuilder: (_) => provider.yearOptions
                          .map((year) => PopupMenuItem(
                                value: year,
                                child: Text(
                                  year,
                                  style: TextStyle(
                                    fontWeight:
                                        year == provider.selectedYear
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                ),
                              ))
                          .toList(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundGray,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              provider.selectedYear.isNotEmpty
                                  ? provider.selectedYear
                                  : 'Year',
                              style: AppTextStyles.body3,
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_drop_down,
                                size: 20, color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // List
          Expanded(
            child: Consumer<EbulletinProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return EmptyStateWidget(
                    icon: Icons.error_outline,
                    message: provider.error!,
                    onRetry: _fetchEbulletins,
                    retryLabel: 'Retry',
                  );
                }

                final items = provider.searchEbulletins(_searchQuery);

                if (items.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.article_outlined,
                    message: 'No e-bulletins found',
                    onRetry: _fetchEbulletins,
                    retryLabel: 'Refresh',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => _fetchEbulletins(),
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (_, index) {
                      final item = items[index];
                      return EbulletinCard(
                        ebulletin: item,
                        isAdmin: widget.isAdmin,
                        onTap: () => _onEbulletinTap(item),
                        onDelete: () => _onDeleteEbulletin(item),
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

  void _navigateToAdd() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEbulletinScreen(
          groupId: _groupId,
          profileId: _profileId,
          moduleId: widget.moduleId,
        ),
      ),
    ).then((_) => _fetchEbulletins());
  }
}
