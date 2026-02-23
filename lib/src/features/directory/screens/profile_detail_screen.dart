import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_loader.dart';
import '../../../core/widgets/common_toast.dart';
import '../models/member_detail_result.dart';
import '../providers/directory_provider.dart';
import '../widgets/profile_section_card.dart';

/// Port of iOS ProfileDynamicNewViewController.swift — dynamic member profile view.
/// Shows: profile photo, name, contact actions (phone/sms/whatsapp/email),
/// personal details, business details, address details, family details.
/// iOS: 4,057 lines → simplified Flutter equivalent.
class ProfileDetailScreen extends StatefulWidget {
  const ProfileDetailScreen({
    super.key,
    required this.memberProfileId,
    required this.groupId,
    required this.memberName,
    this.isCategory = '',
    this.groupUniqueName = '',
    this.adminProfileId = '',
  });

  final String memberProfileId;
  final String groupId;
  final String memberName;
  final String isCategory;
  final String groupUniqueName;
  final String adminProfileId;

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMemberDetail());
  }

  /// iOS: getMemberDetail(memberProfID, grpID) → POST Member/GetMember
  Future<void> _loadMemberDetail() async {
    final provider = context.read<DirectoryProvider>();
    CommonLoader.show(context);

    final success = await provider.getMemberDetail(
      memberProfileId: widget.memberProfileId,
      groupId: widget.groupId,
    );

    if (!mounted) return;
    CommonLoader.dismiss(context);

    if (!success && provider.error != null) {
      CommonToast.error(context, provider.error!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textOnPrimary),
        title: Text(
          widget.memberName,
          style: const TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 17,
            fontWeight: FontWeight.w400,
            color: AppColors.textOnPrimary,
          ),
        ),
      ),
      body: Consumer<DirectoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final member = provider.selectedMember;
          if (member == null) {
            return const Center(
              child: Text('No member details available'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              children: [
                // Profile header — iOS: profile image + name + contact actions
                _buildProfileHeader(member),
                const SizedBox(height: 8),
                // Contact action buttons — iOS: buttonPhoness, buttonMessagess, buttonEmailss
                _buildContactActions(member),
                const SizedBox(height: 8),
                // Personal Details — iOS: muarrayKeyFirst/muarrayValueFirst
                if (member.personalMemberDetails != null &&
                    member.personalMemberDetails!.isNotEmpty)
                  ProfileSectionCard(
                    title: 'Personal Details',
                    children: member.personalMemberDetails!
                        .where((d) =>
                            d.value != null && d.value!.isNotEmpty)
                        .map((detail) => ProfileDetailRow(
                              label: detail.key ?? '',
                              value: detail.value ?? '',
                            ))
                        .toList(),
                  ),
                // Business Details — iOS: BusinessMemberDetails array
                if (member.businessMemberDetails != null &&
                    member.businessMemberDetails!.isNotEmpty)
                  ProfileSectionCard(
                    title: 'Business Details',
                    children: member.businessMemberDetails!
                        .where((d) =>
                            d.value != null && d.value!.isNotEmpty)
                        .map((detail) => ProfileDetailRow(
                              label: detail.key ?? '',
                              value: detail.value ?? '',
                            ))
                        .toList(),
                  ),
                // Address Details — iOS: muarrayAddressSecond
                if (member.addressDetails != null &&
                    member.addressDetails!.isNotEmpty)
                  ProfileSectionCard(
                    title: 'Address Details',
                    children: member.addressDetails!.map((addr) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (addr.addressType != null &&
                                addr.addressType!.isNotEmpty)
                              Text(
                                addr.addressType!,
                                style: const TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            const SizedBox(height: 4),
                            Text(
                              addr.fullAddress,
                              style: const TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (addr.phoneNo != null &&
                                addr.phoneNo!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              GestureDetector(
                                onTap: () =>
                                    _launchUrl('tel:${addr.phoneNo}'),
                                child: Text(
                                  'Phone: ${addr.phoneNo}',
                                  style: const TextStyle(
                                    fontFamily: AppTextStyles.fontFamily,
                                    fontSize: 13,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                // Family Members — iOS: muarrayNameThree
                if (member.familyMemberDetails != null &&
                    member.familyMemberDetails!.isNotEmpty)
                  ProfileSectionCard(
                    title: 'Family Members',
                    children:
                        member.familyMemberDetails!.map((family) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    family.memberName ?? '',
                                    style: const TextStyle(
                                      fontFamily: AppTextStyles.fontFamily,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                if (family.relationship != null &&
                                    family.relationship!.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color:
                                          AppColors.primary.withAlpha(25),
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      family.relationship!,
                                      style: const TextStyle(
                                        fontFamily:
                                            AppTextStyles.fontFamily,
                                        fontSize: 11,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            if (family.contactNo != null &&
                                family.contactNo!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              GestureDetector(
                                onTap: () => _launchUrl(
                                    'tel:${family.contactNo}'),
                                child: Text(
                                  family.contactNo!,
                                  style: const TextStyle(
                                    fontFamily: AppTextStyles.fontFamily,
                                    fontSize: 13,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              ),
                            ],
                            if (family.dOB != null &&
                                family.dOB!.isNotEmpty)
                              Text(
                                'DOB: ${family.dOB}',
                                style: const TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// iOS: Profile image + name at top
  Widget _buildProfileHeader(MemberDetail member) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          // Profile picture — iOS: sd_setImage
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.backgroundGray,
            backgroundImage: member.hasValidProfilePic
                ? NetworkImage(
                    member.profilePic!.replaceAll(' ', '%20'))
                : null,
            child: !member.hasValidProfilePic
                ? const Icon(Icons.person,
                    color: AppColors.textSecondary, size: 50)
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
          if (member.memberEmail != null &&
              member.memberEmail!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              member.memberEmail!,
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// iOS: buttonPhoness, buttonMessagess, buttonEmailss — contact actions row
  Widget _buildContactActions(MemberDetail member) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (member.memberMobile != null &&
              member.memberMobile!.isNotEmpty) ...[
            _contactActionButton(
              Icons.phone,
              'Call',
              AppColors.green,
              () => _launchUrl('tel:${member.memberMobile}'),
            ),
            _contactActionButton(
              Icons.message,
              'SMS',
              Colors.amber.shade700,
              () => _launchUrl('sms:${member.memberMobile}'),
            ),
            // iOS: WhatsApp action
            InkWell(
              onTap: () => _launchUrl(
                  'https://wa.me/${member.memberMobile}'),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    Image.asset('assets/images/whatsapp.png', width: 24, height: 24),
                    const SizedBox(height: 4),
                    const Text(
                      'WhatsApp',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 11,
                        color: Color(0xFF25D366),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (member.memberEmail != null &&
              member.memberEmail!.isNotEmpty)
            _contactActionButton(
              Icons.email,
              'Email',
              AppColors.orange,
              () => _launchUrl('mailto:${member.memberEmail}'),
            ),
        ],
      ),
    );
  }

  Widget _contactActionButton(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 11,
                color: color,
              ),
            ),
          ],
        ),
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
