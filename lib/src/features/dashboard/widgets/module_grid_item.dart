import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/module_result.dart';

/// Port of iOS CustomCollectionViewCell — module grid cell.
/// Displays module icon (from URL), module name, and optional notification badge.
/// iOS: cellForItemAt sets grpName, moduleIcon (sd_setImage), moduleStaticRef, moduleId.
class ModuleGridItem extends StatelessWidget {
  const ModuleGridItem({
    super.key,
    required this.module,
    required this.onTap,
  });

  final GroupModule module;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.white),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Module icon — iOS: cell.moduleIcon.sd_setImage(with: url)
            Stack(
              clipBehavior: Clip.none,
              children: [
                _buildIcon(),
                // Notification badge
                if (module.notificationCountInt > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.systemRed,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Text(
                        module.notificationCountInt > 99
                            ? '99+'
                            : module.notificationCountInt.toString(),
                        style: const TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Module name — iOS: cell.grpName.text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                module.moduleName ?? '',
                style: const TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    final imageUrl = module.image;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          width: 48,
          height: 48,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => _placeholderIcon(),
        ),
      );
    }
    return _placeholderIcon();
  }

  Widget _placeholderIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.backgroundGray,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.grid_view,
        color: AppColors.primary,
        size: 28,
      ),
    );
  }
}
