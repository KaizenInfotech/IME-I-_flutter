import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/attendance_result.dart';

/// Port of iOS ChartClasses — pie chart showing attendance breakdown.
/// Uses fl_chart to display Members, Anns, Annets, Visitors, Rotarians,
/// District Delegates as pie sections.
class AttendanceChart extends StatelessWidget {
  const AttendanceChart({
    super.key,
    required this.detail,
  });

  final AttendanceDetail detail;

  static const List<Color> _sectionColors = [
    AppColors.primary, // Members
    AppColors.green, // Anns
    AppColors.orange, // Annets
    AppColors.primaryBlue, // Visitors
    AppColors.teal, // Rotarians
    AppColors.coralRed, // District Delegates
  ];

  @override
  Widget build(BuildContext context) {
    final chartData = detail.chartData;
    final total = detail.totalCount;

    if (total == 0) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text('No attendance data', style: TextStyle(
            color: AppColors.textSecondary,
          )),
        ),
      );
    }

    final sections = <PieChartSectionData>[];
    int colorIndex = 0;
    chartData.forEach((label, count) {
      if (count > 0) {
        final percentage = (count / total * 100).toStringAsFixed(1);
        sections.add(PieChartSectionData(
          value: count.toDouble(),
          color: _sectionColors[colorIndex % _sectionColors.length],
          title: '$percentage%',
          titleStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
          radius: 80,
        ));
      }
      colorIndex++;
    });

    return Column(
      children: [
        // Chart
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 30,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Legend
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: _buildLegend(chartData),
        ),
      ],
    );
  }

  List<Widget> _buildLegend(Map<String, int> data) {
    final widgets = <Widget>[];
    int colorIndex = 0;
    data.forEach((label, count) {
      if (count > 0) {
        widgets.add(Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _sectionColors[colorIndex % _sectionColors.length],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '$label ($count)',
              style: AppTextStyles.captionSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ));
      }
      colorIndex++;
    });
    return widgets;
  }
}
