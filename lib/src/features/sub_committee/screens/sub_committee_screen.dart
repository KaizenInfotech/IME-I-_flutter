import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../providers/sub_committee_provider.dart';

/// Port of iOS SubCommitteeViewController.
/// Shows list of sub committees — tap drills into member list.
class SubCommitteeScreen extends StatefulWidget {
  const SubCommitteeScreen({super.key});

  @override
  State<SubCommitteeScreen> createState() => _SubCommitteeScreenState();
}

class _SubCommitteeScreenState extends State<SubCommitteeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SubCommitteeProvider>().fetchCommittees();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: const CommonAppBar(title: 'Sub Committees'),
      body: Consumer<SubCommitteeProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.committees.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.groups,
              message: provider.error ?? 'No committees found',
              onRetry: () => provider.fetchCommittees(),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: provider.committees.length,
            itemBuilder: (_, index) {
              final committee = provider.committees[index];
              return Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                  title: Text(
                    committee.committeName ?? '',
                    style: AppTextStyles.body2
                        .copyWith(fontWeight: FontWeight.w500),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  onTap: () {
                    context.push('/sub-committee/members', extra: {
                      'committeeId': committee.pkSubcommitteeId,
                      'committeeName': committee.committeName ?? 'Committee',
                    });
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
