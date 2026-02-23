import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/group_result.dart';

/// Port of iOS group picker / ExitGroupAction — group selection bottom sheet.
/// iOS: PickerView with ["My Profile", "My Club"] and group list navigation.
/// In Flutter, shows a bottom sheet with all available groups.
class GroupSwitcher extends StatelessWidget {
  const GroupSwitcher({
    super.key,
    required this.groups,
    required this.selectedGroup,
    required this.onGroupSelected,
  });

  final List<GroupResult> groups;
  final GroupResult? selectedGroup;
  final void Function(GroupResult group) onGroupSelected;

  /// Show group picker as a bottom sheet.
  static Future<GroupResult?> show(
    BuildContext context, {
    required List<GroupResult> groups,
    GroupResult? selectedGroup,
  }) {
    return showModalBottomSheet<GroupResult>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.8,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grayMedium,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Select Group',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Divider(height: 1),
              // Group list
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  itemCount: groups.length,
                  separatorBuilder: (_, index) =>
                      const Divider(height: 1, indent: 72),
                  itemBuilder: (context, index) {
                    final group = groups[index];
                    final isSelected =
                        selectedGroup?.grpId == group.grpId;
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.backgroundGray,
                        backgroundImage:
                            group.grpImg != null && group.grpImg!.isNotEmpty
                                ? NetworkImage(group.grpImg!)
                                : null,
                        child: group.grpImg == null || group.grpImg!.isEmpty
                            ? const Icon(Icons.group,
                                color: AppColors.primary, size: 22)
                            : null,
                      ),
                      title: Text(
                        group.grpName ?? '',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 15,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                      subtitle: group.isAdmin
                          ? const Text(
                              'Admin',
                              style: TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                fontSize: 12,
                                color: AppColors.green,
                              ),
                            )
                          : null,
                      trailing: isSelected
                          ? const Icon(Icons.check_circle,
                              color: AppColors.primary, size: 22)
                          : null,
                      onTap: () => Navigator.of(context).pop(group),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await show(
          context,
          groups: groups,
          selectedGroup: selectedGroup,
        );
        if (result != null) {
          onGroupSelected(result);
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              selectedGroup?.grpName ?? 'Select Group',
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textOnPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.arrow_drop_down,
            color: AppColors.textOnPrimary,
            size: 24,
          ),
        ],
      ),
    );
  }
}
