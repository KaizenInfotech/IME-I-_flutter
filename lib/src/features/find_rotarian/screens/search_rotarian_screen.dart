import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../providers/find_rotarian_provider.dart';
import '../widgets/rotarian_list_tile.dart';
import 'rotarian_profile_screen.dart';

/// Port of iOS SearchFindArotarianViewController — search results list.
/// Shows rotarian search results with local search filtering.
class SearchRotarianScreen extends StatefulWidget {
  const SearchRotarianScreen({super.key});

  @override
  State<SearchRotarianScreen> createState() => _SearchRotarianScreenState();
}

class _SearchRotarianScreenState extends State<SearchRotarianScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    context.read<FindRotarianProvider>().searchRotarians(query);
  }

  void _navigateToProfile(String profileId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RotarianProfileScreen(
          memberProfileId: profileId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CommonAppBar(title: 'Search Results'),
      body: Column(
        children: [
          // iOS: Search bar
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search by name or club...',
                hintStyle: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
                prefixIcon: const Icon(Icons.search,
                    color: AppColors.textSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear,
                            color: AppColors.textSecondary),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
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

          // Results list
          Expanded(
            child: Consumer<FindRotarianProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final list = provider.rotarians;

                if (list.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.person_search,
                    message: 'No rotarians found',
                  );
                }

                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (_, index) {
                    final item = list[index];
                    return RotarianListTile(
                      item: item,
                      onTap: () =>
                          _navigateToProfile(item.masterUID ?? ''),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
