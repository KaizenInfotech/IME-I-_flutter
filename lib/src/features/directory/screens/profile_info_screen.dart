import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/member_detail_result.dart';
import '../widgets/profile_section_card.dart';

/// Port of iOS ProfileInfoController.swift — read-only profile view.
/// Simpler than ProfileDetailScreen, used for quick profile info display.
/// Shows member photo, name, and key details in section cards.
class ProfileInfoScreen extends StatelessWidget {
  const ProfileInfoScreen({
    super.key,
    required this.member,
  });

  final MemberDetail member;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textOnPrimary),
        title: Text(
          member.memberName ?? 'Profile',
          style: const TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 17,
            fontWeight: FontWeight.w400,
            color: AppColors.textOnPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          children: [
            // Profile header
            _buildProfileHeader(),
            const SizedBox(height: 8),
            // Contact info card
            _buildContactCard(),
            const SizedBox(height: 8),
            // Personal details
            if (member.personalMemberDetails != null &&
                member.personalMemberDetails!.isNotEmpty)
              ProfileSectionCard(
                title: 'Personal Details',
                children: member.personalMemberDetails!
                    .where(
                        (d) => d.value != null && d.value!.isNotEmpty)
                    .map((detail) => ProfileDetailRow(
                          label: detail.key ?? '',
                          value: detail.value ?? '',
                        ))
                    .toList(),
              ),
            // Business details
            if (member.businessMemberDetails != null &&
                member.businessMemberDetails!.isNotEmpty)
              ProfileSectionCard(
                title: 'Business Details',
                children: member.businessMemberDetails!
                    .where(
                        (d) => d.value != null && d.value!.isNotEmpty)
                    .map((detail) => ProfileDetailRow(
                          label: detail.key ?? '',
                          value: detail.value ?? '',
                        ))
                    .toList(),
              ),
            // Address details
            if (member.addressDetails != null &&
                member.addressDetails!.isNotEmpty)
              ProfileSectionCard(
                title: 'Address',
                children: member.addressDetails!.map((addr) {
                  return ProfileDetailRow(
                    label: addr.addressType ?? 'Address',
                    value: addr.fullAddress,
                  );
                }).toList(),
              ),
            // Family members
            if (member.familyMemberDetails != null &&
                member.familyMemberDetails!.isNotEmpty)
              ProfileSectionCard(
                title: 'Family Members',
                children: member.familyMemberDetails!.map((family) {
                  final subtitle = <String>[];
                  if (family.relationship != null &&
                      family.relationship!.isNotEmpty) {
                    subtitle.add(family.relationship!);
                  }
                  if (family.dOB != null && family.dOB!.isNotEmpty) {
                    subtitle.add('DOB: ${family.dOB}');
                  }
                  return ProfileDetailRow(
                    label: family.memberName ?? '',
                    value: subtitle.join(' | '),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: AppColors.backgroundGray,
            backgroundImage: member.hasValidProfilePic
                ? NetworkImage(
                    member.profilePic!.replaceAll(' ', '%20'))
                : null,
            child: !member.hasValidProfilePic
                ? const Icon(Icons.person,
                    color: AppColors.textSecondary, size: 45)
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            member.memberName ?? '',
            style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    final hasPhone = member.memberMobile != null &&
        member.memberMobile!.isNotEmpty;
    final hasEmail = member.memberEmail != null &&
        member.memberEmail!.isNotEmpty;

    if (!hasPhone && !hasEmail) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          if (hasPhone)
            ListTile(
              leading:
                  const Icon(Icons.phone, color: AppColors.green, size: 20),
              title: Text(
                member.memberMobile!,
                style: const TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.phone,
                        color: AppColors.green, size: 20),
                    onPressed: () =>
                        _launchUrl('tel:${member.memberMobile}'),
                  ),
                  IconButton(
                    icon: Icon(Icons.chat,
                        color: Colors.amber.shade700, size: 20),
                    onPressed: () =>
                        _launchUrl('sms:${member.memberMobile}'),
                  ),
                ],
              ),
            ),
          if (hasPhone && hasEmail) const Divider(height: 1, indent: 56),
          if (hasEmail)
            ListTile(
              leading: const Icon(Icons.email,
                  color: AppColors.orange, size: 20),
              title: Text(
                member.memberEmail!,
                style: const TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.email,
                    color: AppColors.orange, size: 20),
                onPressed: () =>
                    _launchUrl('mailto:${member.memberEmail}'),
              ),
            ),
        ],
      ),
    );
  }

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
