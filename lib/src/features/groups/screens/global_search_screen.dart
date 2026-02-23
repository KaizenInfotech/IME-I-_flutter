import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/storage/local_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/common_text_field.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../providers/groups_provider.dart';
import '../widgets/group_card.dart';

/// Port of iOS GlobalSearchGroup screen.
/// Searches groups via Group/GlobalSearchGroup.
class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final text = _searchController.text.trim();
    if (text.isEmpty) return;

    final masterId = LocalStorage.instance.masterUid ?? '';
    context.read<GroupsProvider>().globalSearchGroup(
          memId: masterId,
          otherMemId: text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CommonAppBar(title: 'Search Groups'),
      body: Column(
        children: [
          // Search bar
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: CommonTextField(
                    controller: _searchController,
                    hint: 'Search by member ID or name',
                    useBorderStyle: true,
                    onSubmitted: (_) => _performSearch(),
                    suffixIcon: IconButton(
                      icon:
                          const Icon(Icons.search, color: AppColors.primary),
                      onPressed: _performSearch,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Results
          Expanded(
            child: Consumer<GroupsProvider>(
              builder: (context, provider, _) {
                if (provider.isSearching) {
                  return const Center(child: CircularProgressIndicator());
                }

                final result = provider.searchResult;
                if (result == null) {
                  return EmptyStateWidget(
                    icon: Icons.search,
                    message: 'Search for groups by member ID',
                  );
                }

                final groups = result.groups ?? [];
                if (groups.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.search_off,
                    message: 'No groups found',
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Member info header
                    if (result.memberName != null &&
                        result.memberName!.isNotEmpty)
                      Container(
                        color: AppColors.white,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.border,
                              backgroundImage: (result.profilePicPath !=
                                          null &&
                                      result.profilePicPath!.isNotEmpty)
                                  ? NetworkImage(result.profilePicPath!)
                                  : null,
                              child: (result.profilePicPath == null ||
                                      result.profilePicPath!.isEmpty)
                                  ? const Icon(Icons.person,
                                      color: AppColors.grayMedium, size: 20)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    result.memberName!,
                                    style: AppTextStyles.body2.copyWith(
                                        fontWeight: FontWeight.w600),
                                  ),
                                  if (result.memberMobile != null &&
                                      result.memberMobile!.isNotEmpty)
                                    Text(
                                      result.memberMobile!,
                                      style: AppTextStyles.caption,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Groups list
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: groups.length,
                        itemBuilder: (_, index) {
                          final group = groups[index];
                          return GroupCard(
                            grpName: group.grpName ?? '',
                            grpImg: group.grpImg,
                            isMember: group.isMember,
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
