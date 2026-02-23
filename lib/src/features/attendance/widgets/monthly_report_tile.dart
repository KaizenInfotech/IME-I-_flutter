import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/attendance_result.dart';

/// Port of iOS MonthlyReportDetailTableViewCell — attendance list cell.
/// Shows attendance name and date-time.
class MonthlyReportTile extends StatelessWidget {
  const MonthlyReportTile({
    super.key,
    required this.item,
    this.onTap,
  });

  final AttendanceItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        // iOS: row height 74pt
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(
            bottom: BorderSide(color: AppColors.divider, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            // Calendar icon
            // Container(
            //   width: 44,
            //   height: 44,
            //   decoration: BoxDecoration(
            //     color: AppColors.primary.withValues(alpha: 0.1),
            //     borderRadius: BorderRadius.circular(8),
            //   ),
            //   child: const Icon(
            //     Icons.event_note,
            //     color: AppColors.primary,
            //     size: 24,
            //   ),
            // ),
            const SizedBox(width: 12),

            // Name and date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.attendanceName ?? 'Untitled Event',
                    style: AppTextStyles.body2.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (item.attendanceDate != null &&
                          item.attendanceDate!.isNotEmpty)
                        Text(
                          item.attendanceDate!,
                          style: AppTextStyles.caption,
                        ),
                      if (item.attendanceDate != null &&
                          item.attendanceDate!.isNotEmpty &&
                          item.attendanceTime != null &&
                          item.attendanceTime!.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        Container(
                          width: 1,
                          height: 12,
                          color: AppColors.grayDark,
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (item.attendanceTime != null &&
                          item.attendanceTime!.isNotEmpty)
                        Text(
                          item.attendanceTime!,
                          style: AppTextStyles.caption,
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right,
              color: AppColors.primary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
