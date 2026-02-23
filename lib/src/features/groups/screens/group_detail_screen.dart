import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../models/entity_info_result.dart';
import '../providers/groups_provider.dart';

/// Port of iOS GroupDetail / EntityInfo screen.
/// Shows group detail info from Group/GetGroupDetail.
class GroupDetailScreen extends StatefulWidget {
  const GroupDetailScreen({
    super.key,
    required this.groupId,
    required this.memberMainId,
    this.moduleName = 'Group Detail',
  });

  final String groupId;
  final String memberMainId;
  final String moduleName;

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GroupsProvider>().fetchGroupDetail(
          memberMainId: widget.memberMainId,
          groupId: widget.groupId,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CommonAppBar(title: widget.moduleName),
      body: Consumer<GroupsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoadingDetail) {
            return const Center(child: CircularProgressIndicator());
          }

          final detail = provider.groupDetail;
          if (detail == null) {
            return EmptyStateWidget(
              icon: Icons.group,
              message: provider.error ?? 'No details available',
            );
          }

          return ListView(
            children: [
              // Group Header
              _buildHeader(detail),

              // Detail Rows
              if (detail.formattedAddress.isNotEmpty)
                _detailTile(Icons.location_on, 'Address',
                    detail.formattedAddress),
              if (detail.email != null && detail.email!.isNotEmpty)
                _detailTile(Icons.email, 'Email', detail.email!),
              if (detail.mobile != null && detail.mobile!.isNotEmpty)
                _detailTile(Icons.phone, 'Mobile', detail.mobile!),
              if (detail.website != null && detail.website!.isNotEmpty)
                _detailTile(Icons.language, 'Website', detail.website!),
              if (detail.grpType != null && detail.grpType!.isNotEmpty)
                _detailTile(Icons.category, 'Type', detail.grpType!),
              if (detail.grpCategory != null &&
                  detail.grpCategory!.isNotEmpty)
                _detailTile(
                    Icons.label, 'Category', detail.grpCategory!),
              if (detail.totalMembers != null &&
                  detail.totalMembers!.isNotEmpty)
                _detailTile(
                    Icons.people, 'Total Members', detail.totalMembers!),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(GroupDetailItem detail) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.border,
            backgroundImage:
                (detail.grpImg != null && detail.grpImg!.isNotEmpty)
                    ? NetworkImage(detail.grpImg!)
                    : null,
            child: (detail.grpImg == null || detail.grpImg!.isEmpty)
                ? const Icon(Icons.group,
                    size: 40, color: AppColors.grayMedium)
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            detail.grpName ?? '',
            style: AppTextStyles.heading5,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _detailTile(IconData icon, String label, String value) {
    return Container(
      color: AppColors.white,
      margin: const EdgeInsets.only(top: 1),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(value, style: AppTextStyles.body3),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
