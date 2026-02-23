import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../models/bod_member_result.dart';
import '../providers/profile_provider.dart';

/// Port of iOS BOD list screen.
/// Shows Board of Directors members from Member/GetBODList.
class BodListScreen extends StatefulWidget {
  const BodListScreen({
    super.key,
    required this.groupId,
    required this.profileId,
    this.moduleName = 'Board of Directors',
  });

  final String groupId;
  final String profileId;
  final String moduleName;

  @override
  State<BodListScreen> createState() => _BodListScreenState();
}

class _BodListScreenState extends State<BodListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileProvider>().fetchBodList(
          groupId: widget.groupId,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CommonAppBar(title: widget.moduleName),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, _) {
          if (provider.isLoadingBod) {
            return const Center(child: CircularProgressIndicator());
          }

          final list = provider.bodMembers;
          if (list.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.people,
              message: provider.error ?? 'No records found',
            );
          }

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, index) {
              final member = list[index];
              return _BodMemberTile(member: member);
            },
          );
        },
      ),
    );
  }
}

class _BodMemberTile extends StatelessWidget {
  const _BodMemberTile({required this.member});

  final BodMember member;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: AppColors.border,
          backgroundImage: (member.pic != null && member.pic!.isNotEmpty)
              ? NetworkImage(member.pic!)
              : null,
          child: (member.pic == null || member.pic!.isEmpty)
              ? const Icon(Icons.person, color: AppColors.grayMedium)
              : null,
        ),
        title: Text(
          member.memberName ?? '',
          style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (member.designation != null && member.designation!.isNotEmpty)
              Text(
                member.designation!,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                ),
              ),
            if (member.clubName != null && member.clubName!.isNotEmpty)
              Text(
                member.clubName!,
                style: AppTextStyles.caption,
              ),
          ],
        ),
        trailing: (member.mobile != null && member.mobile!.isNotEmpty)
            ? Icon(Icons.phone, color: AppColors.green, size: 20)
            : null,
      ),
    );
  }
}
