import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../models/service_directory_result.dart';
import '../providers/service_directory_provider.dart';
import '../widgets/service_list_tile.dart';
import 'service_website_screen.dart';

/// Port of iOS ServiceDirectoryListViewController — services in a category.
/// Shows service providers filtered by category with search.
class ServiceCategoryScreen extends StatefulWidget {
  const ServiceCategoryScreen({
    super.key,
    required this.categoryName,
  });

  final String categoryName;

  @override
  State<ServiceCategoryScreen> createState() => _ServiceCategoryScreenState();
}

class _ServiceCategoryScreenState extends State<ServiceCategoryScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    context.read<ServiceDirectoryProvider>().searchServices(query);
  }

  Future<void> _makeCall(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _sendEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  void _openWebsite(ServiceDirectoryItem item) {
    if (!item.hasWebsite) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceWebsiteScreen(
          url: item.website!,
          title: item.memberName ?? 'Website',
        ),
      ),
    );
  }

  Future<void> _openMap(ServiceDirectoryItem item) async {
    if (!item.hasCoordinates) return;
    final lat = item.latitude!;
    final lng = item.longitude!;
    final uri = Uri.parse(
        'https://maps.apple.com/?daddr=$lat,$lng&dirflg=d');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CommonAppBar(title: widget.categoryName),
      body: Column(
        children: [
          // Search
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search services...',
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

          // Services list
          Expanded(
            child: Consumer<ServiceDirectoryProvider>(
              builder: (context, provider, _) {
                final list = provider.services;
                if (list.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.business_center,
                    message: 'No services found in this category',
                  );
                }

                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (_, index) {
                    final item = list[index];
                    return ServiceListTile(
                      item: item,
                      onCall: item.contactNo != null &&
                              item.contactNo!.isNotEmpty
                          ? () => _makeCall(item.contactNo!)
                          : null,
                      onEmail: item.email != null && item.email!.isNotEmpty
                          ? () => _sendEmail(item.email!)
                          : null,
                      onWebsite:
                          item.hasWebsite ? () => _openWebsite(item) : null,
                      onMap: item.hasCoordinates
                          ? () => _openMap(item)
                          : null,
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
