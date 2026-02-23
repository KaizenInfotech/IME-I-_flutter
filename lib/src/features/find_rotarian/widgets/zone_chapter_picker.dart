import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/rotarian_result.dart';

/// Port of iOS zone/chapter UIPickerView — cascading dropdowns.
/// Selecting a zone filters the chapter list by ZoneID.
class ZoneChapterPicker extends StatelessWidget {
  const ZoneChapterPicker({
    super.key,
    required this.zones,
    required this.chapters,
    this.selectedZone,
    this.selectedChapter,
    required this.onZoneChanged,
    required this.onChapterChanged,
  });

  final List<ZoneItem> zones;
  final List<ChapterItem> chapters;
  final ZoneItem? selectedZone;
  final ChapterItem? selectedChapter;
  final ValueChanged<ZoneItem?> onZoneChanged;
  final ValueChanged<ChapterItem?> onChapterChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Zone dropdown
        Text('Zone', style: AppTextStyles.label),
        const SizedBox(height: 6),
        _buildZoneDropdown(context),
        const SizedBox(height: 12),

        // Chapter dropdown (filtered by selected zone)
        Text('Chapter', style: AppTextStyles.label),
        const SizedBox(height: 6),
        _buildChapterDropdown(context),
      ],
    );
  }

  Widget _buildZoneDropdown(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundGray,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedZone?.zoneID,
          hint: Text(
            'Select Zone',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          isExpanded: true,
          items: zones.map((zone) {
            return DropdownMenuItem<String>(
              value: zone.zoneID,
              child: Text(
                zone.zoneName ?? '',
                style: AppTextStyles.body2,
              ),
            );
          }).toList(),
          onChanged: (zoneId) {
            if (zoneId == null) {
              onZoneChanged(null);
            } else {
              final zone = zones.firstWhere(
                (z) => z.zoneID == zoneId,
              );
              onZoneChanged(zone);
            }
          },
        ),
      ),
    );
  }

  Widget _buildChapterDropdown(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundGray,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedChapter?.chapterID,
          hint: Text(
            selectedZone == null
                ? 'Select a zone first'
                : 'Select Chapter',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          isExpanded: true,
          items: chapters.map((chapter) {
            return DropdownMenuItem<String>(
              value: chapter.chapterID,
              child: Text(
                chapter.chapterName ?? '',
                style: AppTextStyles.body2,
              ),
            );
          }).toList(),
          onChanged: selectedZone == null
              ? null
              : (chapterId) {
                  if (chapterId == null) {
                    onChapterChanged(null);
                  } else {
                    final chapter = chapters.firstWhere(
                      (c) => c.chapterID == chapterId,
                    );
                    onChapterChanged(chapter);
                  }
                },
        ),
      ),
    );
  }
}
