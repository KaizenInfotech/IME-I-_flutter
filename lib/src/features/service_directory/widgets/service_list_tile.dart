import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/service_directory_result.dart';

/// Port of iOS ServiceDirectoryListViewController cell — service provider tile.
/// Shows profile image, name, description, and action buttons.
class ServiceListTile extends StatelessWidget {
  const ServiceListTile({
    super.key,
    required this.item,
    this.onCall,
    this.onEmail,
    this.onWebsite,
    this.onMap,
  });

  final ServiceDirectoryItem item;
  final VoidCallback? onCall;
  final VoidCallback? onEmail;
  final VoidCallback? onWebsite;
  final VoidCallback? onMap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      margin: const EdgeInsets.only(bottom: 1),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile image (iOS: 120pt row height with image)
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: item.hasValidImage
                      ? Image.network(
                          item.encodedImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.business_center,
                            size: 28,
                            color: AppColors.grayMedium,
                          ),
                        )
                      : const Icon(
                          Icons.business_center,
                          size: 28,
                          color: AppColors.grayMedium,
                        ),
                ),
              ),
              const SizedBox(width: 12),

              // Name + description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.memberName ?? 'Unknown',
                      style: AppTextStyles.body2.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.description != null &&
                        item.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.description!,
                        style: AppTextStyles.caption,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (item.fullAddress.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.fullAddress,
                              style: AppTextStyles.captionSmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Action buttons row
          Row(
            children: [
              if (onCall != null)
                _buildActionChip(
                  icon: Icons.call,
                  label: 'Call',
                  color: AppColors.primary,
                  onTap: onCall!,
                ),
              if (onEmail != null) ...[
                const SizedBox(width: 8),
                _buildActionChip(
                  icon: Icons.email,
                  label: 'Email',
                  color: AppColors.primaryBlue,
                  onTap: onEmail!,
                ),
              ],
              if (onWebsite != null) ...[
                const SizedBox(width: 8),
                _buildActionChip(
                  icon: Icons.language,
                  label: 'Website',
                  color: AppColors.primaryBlue,
                  onTap: onWebsite!,
                ),
              ],
              if (onMap != null) ...[
                const SizedBox(width: 8),
                _buildActionChip(
                  icon: Icons.map,
                  label: 'Map',
                  color: AppColors.primary,
                  onTap: onMap!,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.captionSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
