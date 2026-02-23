import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/common_toast.dart';
import '../models/attendance_result.dart';
import '../providers/attendance_provider.dart';
import 'attendance_people_screen.dart';

/// Port of Android EventAttendanceDetailsActivity.
/// Receives all data via AttendanceItem (Intent extras in Android) — no detail API call.
/// Displays: name, date, time, memberCount, visitorCount, description.
/// Android also has Members and Visitors drilldown buttons.
class AttendanceDetailScreen extends StatelessWidget {
  const AttendanceDetailScreen({
    super.key,
    required this.attendanceItem,
    this.isAdmin = false,
  });

  final AttendanceItem attendanceItem;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CommonAppBar(
        title: 'Attendance Detail',
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.textOnPrimary),
              onPressed: () => _deleteAttendance(context),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name and date card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0D000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attendanceItem.attendanceName ?? 'Untitled',
                    style: AppTextStyles.heading5,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        attendanceItem.attendanceDate ?? '',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  if (attendanceItem.attendanceTime != null &&
                      attendanceItem.attendanceTime!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          attendanceItem.attendanceTime!,
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Member & Visitor counts — tappable (Android: img_memberView / img_visitorsView)
            Row(
              children: [
                Expanded(
                  child: _buildCountCard(
                    context,
                    'Members',
                    attendanceItem.memberCount ?? '0',
                    Icons.people,
                    onTap: () => _navigateToPeople(context, isMembers: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCountCard(
                    context,
                    'Visitors',
                    attendanceItem.visitorCount ?? '0',
                    Icons.person_add,
                    onTap: () => _navigateToPeople(context, isMembers: false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            if (attendanceItem.description != null &&
                attendanceItem.description!.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Description', style: AppTextStyles.label),
                    const SizedBox(height: 8),
                    Text(
                      attendanceItem.description!,
                      style: AppTextStyles.body2,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  void _navigateToPeople(BuildContext context, {required bool isMembers}) {
    final id = attendanceItem.attendanceID;
    if (id == null || id.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AttendancePeopleScreen(
          attendanceId: id,
          isMembers: isMembers,
          title: isMembers ? 'Members' : 'Visitors',
        ),
      ),
    );
  }

  Widget _buildCountCard(
    BuildContext context,
    String label,
    String count,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: 8),
            Text(
              count,
              style: AppTextStyles.heading5.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: AppTextStyles.caption),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right,
                    color: AppColors.primary, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteAttendance(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Attendance'),
        content:
            const Text('Are you sure you want to delete this attendance?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.systemRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    final success = await context.read<AttendanceProvider>().deleteAttendance(
          attendanceId: attendanceItem.attendanceID ?? '',
          createdBy: '',
        );

    if (!context.mounted) return;
    if (success) {
      CommonToast.success(context, 'Attendance deleted');
      Navigator.pop(context);
    } else {
      CommonToast.error(context, 'Failed to delete attendance');
    }
  }
}
