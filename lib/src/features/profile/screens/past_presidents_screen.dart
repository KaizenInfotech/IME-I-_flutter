import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../models/bod_member_result.dart';
import '../providers/profile_provider.dart';

/// Port of iOS Past Presidents list screen.
/// Shows past presidents from PastPresidents/getPastPresidentsList.
class PastPresidentsScreen extends StatefulWidget {
  const PastPresidentsScreen({
    super.key,
    required this.groupId,
    this.moduleName = 'Past Presidents',
  });

  final String groupId;
  final String moduleName;

  @override
  State<PastPresidentsScreen> createState() => _PastPresidentsScreenState();
}

class _PastPresidentsScreenState extends State<PastPresidentsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileProvider>().fetchPastPresidents(
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
          if (provider.isLoadingPastPresidents) {
            return const Center(child: CircularProgressIndicator());
          }

          final list = provider.pastPresidents;
          if (list.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.history,
              message: provider.error ?? 'No records found',
            );
          }

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, index) {
              final president = list[index];
              return _PastPresidentTile(president: president);
            },
          );
        },
      ),
    );
  }
}

class _PastPresidentTile extends StatelessWidget {
  const _PastPresidentTile({required this.president});

  final PastPresident president;

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
          backgroundImage:
              (president.pic != null && president.pic!.isNotEmpty)
                  ? NetworkImage(president.pic!)
                  : null,
          child: (president.pic == null || president.pic!.isEmpty)
              ? const Icon(Icons.person, color: AppColors.grayMedium)
              : null,
        ),
        title: Text(
          president.memberName ?? '',
          style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (president.year != null && president.year!.isNotEmpty)
              Text(
                president.year!,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            if (president.designation != null &&
                president.designation!.isNotEmpty)
              Text(
                president.designation!,
                style: AppTextStyles.caption,
              ),
          ],
        ),
      ),
    );
  }
}
