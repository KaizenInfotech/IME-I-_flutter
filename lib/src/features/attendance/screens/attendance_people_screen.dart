import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../providers/attendance_provider.dart';

/// Port of Android AttendanceMembersDetailsActivity / AttendanceVisitorsDetailsActivity.
/// Shows list of members or visitors for a given attendance event.
/// [isMembers] true = members (type=1), false = visitors (type=2).
class AttendancePeopleScreen extends StatefulWidget {
  const AttendancePeopleScreen({
    super.key,
    required this.attendanceId,
    required this.isMembers,
    required this.title,
  });

  final String attendanceId;
  final bool isMembers;
  final String title;

  @override
  State<AttendancePeopleScreen> createState() => _AttendancePeopleScreenState();
}

class _AttendancePeopleScreenState extends State<AttendancePeopleScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final provider = context.read<AttendanceProvider>();
    if (widget.isMembers) {
      provider.fetchAttendanceMembers(attendanceId: widget.attendanceId);
    } else {
      provider.fetchAttendanceVisitors(attendanceId: widget.attendanceId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CommonAppBar(title: widget.title),
      body: Consumer<AttendanceProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return EmptyStateWidget(
              icon: Icons.error_outline,
              message: provider.error!,
              onRetry: _loadData,
              retryLabel: 'Retry',
            );
          }

          if (widget.isMembers) {
            return _buildMembersList(provider);
          } else {
            return _buildVisitorsList(provider);
          }
        },
      ),
    );
  }

  Widget _buildMembersList(AttendanceProvider provider) {
    final members = provider.membersList;
    if (members.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.people_outline,
        message: 'No members found',
      );
    }

    return ListView.builder(
      itemCount: members.length,
      itemBuilder: (_, index) {
        final member = members[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: AppColors.white,
            border: Border(
              bottom: BorderSide(color: AppColors.divider, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              // Profile image — Android: circular ImageView with Picasso
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: ClipOval(
                  child: member.hasValidImage
                      ? Image.network(
                          member.encodedImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _personPlaceholder(),
                        )
                      : _personPlaceholder(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.memberName ?? '',
                      style: AppTextStyles.body2
                          .copyWith(fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (member.designation != null &&
                        member.designation!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        member.designation!,
                        style: AppTextStyles.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVisitorsList(AttendanceProvider provider) {
    final visitors = provider.visitorsList;
    if (visitors.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.person_add_disabled,
        message: 'No visitors found',
      );
    }

    return ListView.builder(
      itemCount: visitors.length,
      itemBuilder: (_, index) {
        final visitor = visitors[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: const BoxDecoration(
            color: AppColors.white,
            border: Border(
              bottom: BorderSide(color: AppColors.divider, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: ClipOval(child: _personPlaceholder()),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  visitor.visitorName ?? '',
                  style:
                      AppTextStyles.body2.copyWith(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _personPlaceholder() {
    return const Icon(Icons.person, color: AppColors.primary, size: 24);
  }
}
