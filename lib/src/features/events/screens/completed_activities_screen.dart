import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Port of iOS CompletedActivitiesViewController.swift — past event detail view.
/// Shows: activity image, title, category, associated club, date, address, description.
/// Used for viewing completed/past activities from profile.
class CompletedActivitiesScreen extends StatelessWidget {
  const CompletedActivitiesScreen({
    super.key,
    required this.activityData,
  });

  /// iOS: userProfileDict — contains title, description, clubname, image, etc.
  final Map<String, dynamic> activityData;

  @override
  Widget build(BuildContext context) {
    final title = activityData['title']?.toString() ?? '';
    final description = activityData['description']?.toString() ?? '';
    final clubName = activityData['clubname']?.toString() ?? '';
    final imageUrl = activityData['image']?.toString() ?? '';
    final date = activityData['date']?.toString() ?? '';
    final address = activityData['address']?.toString() ?? '';
    final category = activityData['category']?.toString() ?? '';

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textOnPrimary),
        title: const Text(
          'Activity Details',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 17,
            fontWeight: FontWeight.w400,
            color: AppColors.textOnPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Activity image — iOS: userImg
            if (imageUrl.isNotEmpty)
              Image.network(
                imageUrl.replaceAll(' ', '%20'),
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  height: 200,
                  color: AppColors.backgroundGray,
                  child: const Center(
                    child: Icon(Icons.image_not_supported,
                        color: AppColors.grayMedium, size: 48),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title — iOS: titleLbl
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Category badge — iOS: categoryLbl
                  if (category.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),

                  // Club name — iOS: associtedLblll
                  if (clubName.isNotEmpty)
                    _buildInfoRow(Icons.groups, clubName),

                  // Date — iOS: dateLblll
                  if (date.isNotEmpty)
                    _buildInfoRow(Icons.calendar_today, date),

                  // Address — iOS: addresssLblll
                  if (address.isNotEmpty)
                    _buildInfoRow(Icons.location_on, address),

                  const SizedBox(height: 16),

                  // Description — iOS: ActivityLbl
                  if (description.isNotEmpty) ...[
                    const Text(
                      'About Activity',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
