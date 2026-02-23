import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/storage/local_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../models/attendance_result.dart';
import '../providers/attendance_provider.dart';
import '../widgets/monthly_report_tile.dart';
import 'attendance_detail_screen.dart';

/// Port of Android EventAttendanceActivity — attendance list.
/// API: POST Attendance/GetAttendanceListNew with GroupId only.
/// Android passes all data via Intent extras to detail screen (no detail API).
class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({
    super.key,
    this.groupId,
    this.isAdmin = false,
  });

  final String? groupId;
  final bool isAdmin;

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String _groupId = '';

  @override
  void initState() {
    super.initState();
    final localStorage = LocalStorage.instance;
    // Android: PreferenceManager.GROUP_ID stores grpid0 value
    _groupId = widget.groupId ?? localStorage.groupIdPrimary ?? '';
    _fetchAttendance();
  }

  void _fetchAttendance() {
    context.read<AttendanceProvider>().fetchAttendanceList(
          groupId: _groupId,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CommonAppBar(title: 'Attendance'),
      body: Consumer<AttendanceProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return EmptyStateWidget(
              icon: Icons.error_outline,
              message: provider.error!,
              onRetry: _fetchAttendance,
              retryLabel: 'Retry',
            );
          }

          if (provider.attendanceList.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.event_note,
              message: 'No attendance records found',
              onRetry: _fetchAttendance,
              retryLabel: 'Refresh',
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _fetchAttendance(),
            child: ListView.builder(
              itemCount: provider.attendanceList.length,
              itemBuilder: (_, index) {
                final item = provider.attendanceList[index];
                return MonthlyReportTile(
                  item: item,
                  onTap: () => _navigateToDetail(item),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _navigateToDetail(AttendanceItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AttendanceDetailScreen(
          attendanceItem: item,
          isAdmin: widget.isAdmin,
        ),
      ),
    ).then((_) => _fetchAttendance());
  }
}
