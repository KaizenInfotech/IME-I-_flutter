import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/empty_state_widget.dart';

/// Port of iOS district committee screen.
/// API: District/GetDistrictCommittee (POST)
/// Shows district committee members grouped by committee.
class DistrictCommitteeScreen extends StatelessWidget {
  const DistrictCommitteeScreen({
    super.key,
    required this.groupId,
    this.committees = const [],
  });

  final String groupId;
  final List<Map<String, dynamic>> committees;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CommonAppBar(title: 'District Committee'),
      body: committees.isEmpty
          ? EmptyStateWidget(
              icon: Icons.groups,
              message: 'No committee data available',
            )
          : ListView.builder(
              itemCount: committees.length,
              itemBuilder: (_, index) {
                final item = committees[index];
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
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person,
                            color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name']?.toString() ?? 'Unknown',
                              style: AppTextStyles.body2.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (item['designation'] != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                item['designation'].toString(),
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
