import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Port of iOS CelebrationViewController tab segments — Birthday/Anniversary/Event tabs.
/// Flat text tabs with blue underline indicator matching Android calendar screenshot.
class CelebrationTabBar extends StatelessWidget {
  const CelebrationTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  /// 0=Birthday, 1=Anniversary, 2=Event
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundGray,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _buildTab(0, 'BIRTHDAY'),
          _buildTab(1, 'ANNIVERSARY'),
          _buildTab(2, 'EVENTS'),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String label) {
    final isSelected = selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTabSelected(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
