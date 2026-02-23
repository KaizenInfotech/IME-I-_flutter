import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../providers/subgroups_provider.dart';
import '../widgets/subgroup_member_tile.dart';

/// Port of iOS SubGroupDetailViewController — sub-group member list.
/// Shows members of a specific sub-group.
class SubgroupDetailScreen extends StatefulWidget {
  const SubgroupDetailScreen({
    super.key,
    required this.subgrpId,
    required this.title,
  });

  final String subgrpId;
  final String title;

  @override
  State<SubgroupDetailScreen> createState() => _SubgroupDetailScreenState();
}

class _SubgroupDetailScreenState extends State<SubgroupDetailScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<SubgroupsProvider>()
        .fetchSubGroupDetail(subgrpId: widget.subgrpId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CommonAppBar(title: widget.title),
      body: Consumer<SubgroupsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoadingDetail) {
            return const Center(child: CircularProgressIndicator());
          }

          final membersList = provider.members;
          if (membersList.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.people_outline,
              message: 'No members in this sub-group',
            );
          }

          return ListView.builder(
            itemCount: membersList.length,
            itemBuilder: (_, index) {
              final member = membersList[index];
              return SubgroupMemberTile(member: member);
            },
          );
        },
      ),
    );
  }
}
