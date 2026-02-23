import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Card displaying a family member's details.
/// iOS: family details cells in FamilySegmentViewController.
class FamilyMemberCard extends StatelessWidget {
  const FamilyMemberCard({
    super.key,
    required this.name,
    this.relationship = '',
    this.dob = '',
    this.contact = '',
    this.email = '',
    this.bloodGroup = '',
    this.onEdit,
  });

  final String name;
  final String relationship;
  final String dob;
  final String contact;
  final String email;
  final String bloodGroup;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: AppTextStyles.body2
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                if (onEdit != null)
                  GestureDetector(
                    onTap: onEdit,
                    child: const Icon(
                      Icons.edit,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
              ],
            ),
            if (relationship.isNotEmpty) ...[
              const SizedBox(height: 4),
              _infoRow(Icons.people, relationship),
            ],
            if (dob.isNotEmpty) ...[
              const SizedBox(height: 4),
              _infoRow(Icons.cake, dob),
            ],
            if (contact.isNotEmpty) ...[
              const SizedBox(height: 4),
              _infoRow(Icons.phone, contact),
            ],
            if (email.isNotEmpty) ...[
              const SizedBox(height: 4),
              _infoRow(Icons.email, email),
            ],
            if (bloodGroup.isNotEmpty) ...[
              const SizedBox(height: 4),
              _infoRow(Icons.bloodtype, bloodGroup),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.caption,
          ),
        ),
      ],
    );
  }
}
