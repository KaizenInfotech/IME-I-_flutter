import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Port of iOS DirectoryViewController picker — filter type dropdown.
/// iOS: pickerSelectSettingMyProfileAboutPicker with options:
/// ["Rotarian", "Classification", "Family"].
/// Default: "Rotarian" (Members).
enum DirectoryFilterType {
  rotarian,
  classification,
  family,
}

class ClassificationFilter extends StatelessWidget {
  const ClassificationFilter({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  final DirectoryFilterType selectedFilter;
  final void Function(DirectoryFilterType) onFilterChanged;

  String _filterLabel(DirectoryFilterType type) {
    switch (type) {
      case DirectoryFilterType.rotarian:
        return 'Members';
      case DirectoryFilterType.classification:
        return 'Classification';
      case DirectoryFilterType.family:
        return 'Family';
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<DirectoryFilterType>(
      onSelected: onFilterChanged,
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _filterLabel(selectedFilter),
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down,
                color: AppColors.primary, size: 20),
          ],
        ),
      ),
      itemBuilder: (context) => DirectoryFilterType.values.map((type) {
        return PopupMenuItem<DirectoryFilterType>(
          value: type,
          child: Row(
            children: [
              if (type == selectedFilter)
                const Icon(Icons.check, color: AppColors.primary, size: 18)
              else
                const SizedBox(width: 18),
              const SizedBox(width: 8),
              Text(
                _filterLabel(type),
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14,
                  fontWeight: type == selectedFilter
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
