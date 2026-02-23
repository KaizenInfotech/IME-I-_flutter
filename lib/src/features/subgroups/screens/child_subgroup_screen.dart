import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../models/subgroup_list_result.dart';

/// Port of iOS ChildSubgrpViewController — child sub-groups screen.
/// Shows child sub-groups under a parent sub-group.
class ChildSubgroupScreen extends StatelessWidget {
  const ChildSubgroupScreen({
    super.key,
    required this.parentTitle,
    this.childSubgroups = const [],
  });

  final String parentTitle;
  final List<SubgroupItem> childSubgroups;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CommonAppBar(title: parentTitle),
      body: childSubgroups.isEmpty
          ? EmptyStateWidget(
              icon: Icons.group_work,
              message: 'No child sub-groups',
            )
          : ListView.builder(
              itemCount: childSubgroups.length,
              itemBuilder: (_, index) {
                final item = childSubgroups[index];
                return Container(
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
                      const Icon(
                        Icons.subdirectory_arrow_right,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.subgrpTitle ?? 'Unknown',
                          style: AppTextStyles.body2.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        item.displayMemberCount,
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
