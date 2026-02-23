import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/storage/local_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/common_text_field.dart';
import '../../../core/widgets/common_toast.dart';
import '../../directory/providers/directory_provider.dart';
import '../providers/subgroups_provider.dart';

/// Port of iOS CreateSubgrpViewController — create new sub-group.
/// Shows sub-group name field + member selection list with checkboxes.
class AddSubgroupScreen extends StatefulWidget {
  const AddSubgroupScreen({super.key});

  @override
  State<AddSubgroupScreen> createState() => _AddSubgroupScreenState();
}

class _AddSubgroupScreenState extends State<AddSubgroupScreen> {
  final _titleController = TextEditingController();
  final _searchController = TextEditingController();
  final Set<String> _selectedProfileIds = {};
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Fetch all group members to select from
    final localStorage = LocalStorage.instance;
    context.read<DirectoryProvider>().fetchDirectory(
          masterUID: localStorage.masterUid ?? '',
          grpID: localStorage.authGroupId ?? '',
        );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// iOS: creatSubGRpClick — validate and create sub-group.
  Future<void> _create() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      CommonToast.show(context, 'Please enter sub-group name');
      return;
    }

    if (_selectedProfileIds.isEmpty) {
      CommonToast.show(context, 'Please select at least one member');
      return;
    }

    final success = await context.read<SubgroupsProvider>().createSubGroup(
          title: title,
          memberProfileIds: _selectedProfileIds.toList(),
        );

    if (!mounted) return;

    if (success) {
      CommonToast.success(context, 'Sub-group created successfully');
      Navigator.pop(context);
    } else {
      CommonToast.error(context, 'Failed to create sub-group');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CommonAppBar(
        title: 'Create Sub-Group',
        actions: [
          TextButton(
            onPressed: _create,
            child: const Text(
              'Save',
              style: TextStyle(color: AppColors.white, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Sub-group title
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.all(16),
            child: CommonTextField(
              controller: _titleController,
              label: 'Sub-Group Name',
              hint: 'Enter sub-group name',
            ),
          ),
          const SizedBox(height: 8),

          // Search members
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (query) {
                setState(() => _searchQuery = query.toLowerCase());
              },
              decoration: InputDecoration(
                hintText: 'Search members...',
                hintStyle: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
                prefixIcon: const Icon(Icons.search,
                    color: AppColors.textSecondary),
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

          // Selected count
          Container(
            width: double.infinity,
            color: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '${_selectedProfileIds.length} members selected',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Divider(height: 1),

          // Member selection list
          Expanded(
            child: Consumer<DirectoryProvider>(
              builder: (context, dirProvider, _) {
                if (dirProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Client-side filter on memberName
                final allMembers = dirProvider.members;
                final memberList = _searchQuery.isEmpty
                    ? allMembers
                    : allMembers.where((m) {
                        final name = m.memberName?.toLowerCase() ?? '';
                        return name.contains(_searchQuery);
                      }).toList();

                if (memberList.isEmpty) {
                  return const Center(
                    child: Text('No members available'),
                  );
                }

                return ListView.builder(
                  itemCount: memberList.length,
                  itemBuilder: (_, index) {
                    final member = memberList[index];
                    final profileId = member.profileId ?? '';
                    final isSelected =
                        _selectedProfileIds.contains(profileId);

                    return InkWell(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedProfileIds.remove(profileId);
                          } else {
                            _selectedProfileIds.add(profileId);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: const BoxDecoration(
                          color: AppColors.white,
                          border: Border(
                            bottom: BorderSide(
                                color: AppColors.divider, width: 0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Checkbox
                            Icon(
                              isSelected
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.grayMedium,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                member.memberName ?? 'Unknown',
                                style: AppTextStyles.body2.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
