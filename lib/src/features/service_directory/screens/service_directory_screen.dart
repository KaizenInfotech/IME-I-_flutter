import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../providers/service_directory_provider.dart';
import 'service_category_screen.dart';

/// Port of iOS CategoryServiceDirectoryViewController — service directory categories.
/// Shows categories with count, tap to view services in that category.
class ServiceDirectoryScreen extends StatefulWidget {
  const ServiceDirectoryScreen({super.key});

  @override
  State<ServiceDirectoryScreen> createState() =>
      _ServiceDirectoryScreenState();
}

class _ServiceDirectoryScreenState extends State<ServiceDirectoryScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ServiceDirectoryProvider>().fetchCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    context.read<ServiceDirectoryProvider>().searchCategories(query);
  }

  void _navigateToCategory(int categoryId, String categoryName) {
    context
        .read<ServiceDirectoryProvider>()
        .fetchServicesByCategory(categoryId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceCategoryScreen(
          categoryName: categoryName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CommonAppBar(title: 'Service Directory'),
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
                hintText: 'Search categories...',
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

          // Categories list
          Expanded(
            child: Consumer<ServiceDirectoryProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return EmptyStateWidget(
                    icon: Icons.error_outline,
                    message: provider.error!,
                    onRetry: () => provider.fetchCategories(),
                    retryLabel: 'Retry',
                  );
                }

                final cats = provider.filteredCategories;
                if (cats.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.folder_open,
                    message: 'No categories found',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.fetchCategories(),
                  child: ListView.builder(
                    itemCount: cats.length,
                    itemBuilder: (_, index) {
                      final cat = cats[index];
                      return InkWell(
                        onTap: () => _navigateToCategory(
                          cat.id ?? 0,
                          cat.categoryName ?? 'Unknown',
                        ),
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
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.category,
                                  color: AppColors.primary,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  cat.categoryName ?? 'Unknown',
                                  style: AppTextStyles.body2.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              // Count badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${cat.totalCount ?? 0}',
                                  style: AppTextStyles.captionSmall.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.chevron_right,
                                color: AppColors.primary,
                                size: 22,
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
}
