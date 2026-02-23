import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Reusable settings toggle tile matching iOS SettingCell / grpSettingsCell.
/// Shows a label with a Switch toggle.
class SettingToggleTile extends StatelessWidget {
  const SettingToggleTile({
    super.key,
    required this.label,
    required this.isEnabled,
    required this.onChanged,
  });

  final String label;
  final bool isEnabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.body2.copyWith(
                color: isEnabled
                    ? AppColors.textPrimary
                    : AppColors.grayMedium,
              ),
            ),
          ),
          Switch(
            value: isEnabled,
            activeTrackColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
