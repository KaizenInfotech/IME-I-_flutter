import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../models/district_result.dart';
import '../providers/district_provider.dart';
import '../widgets/call_message_cell.dart';

/// Port of iOS DistrictDirectoryDetailsVC — member profile detail.
/// Shows profile, personal/business details, and contact actions.
class DistrictMemberDetailScreen extends StatefulWidget {
  const DistrictMemberDetailScreen({
    super.key,
    required this.memberProfileId,
    required this.groupId,
  });

  final String memberProfileId;
  final String groupId;

  @override
  State<DistrictMemberDetailScreen> createState() =>
      _DistrictMemberDetailScreenState();
}

class _DistrictMemberDetailScreenState
    extends State<DistrictMemberDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DistrictProvider>().fetchMemberDetail(
          memberProfileId: widget.memberProfileId,
          groupId: widget.groupId,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CommonAppBar(title: 'Member Details'),
      body: Consumer<DistrictProvider>(
        builder: (context, provider, _) {
          if (provider.isLoadingDetail) {
            return const Center(child: CircularProgressIndicator());
          }

          final detail = provider.memberDetail;
          if (detail == null) {
            return const Center(child: Text('No details available'));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Profile header
                _buildProfileHeader(detail),
                const SizedBox(height: 8),

                // Contact actions
                CallMessageCell(
                  phoneNumbers: detail.allPhoneNumbers,
                  emails: detail.allEmails,
                ),
                const SizedBox(height: 8),

                // Personal details
                if (detail.personalDetails != null &&
                    detail.personalDetails!.isNotEmpty)
                  _buildSection('Personal Details', detail.personalDetails!),

                // Business details
                if (detail.businessDetails != null &&
                    detail.businessDetails!.isNotEmpty)
                  _buildSection('Business Details', detail.businessDetails!),

                // Address details
                if (detail.addresses != null && detail.addresses!.isNotEmpty)
                  _buildAddressSection(detail.addresses!),

                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(MemberDetailData detail) {
    return Container(
      width: double.infinity,
      color: AppColors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: ClipOval(
              child: detail.hasValidPic
                  ? Image.network(
                      detail.encodedPicUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.person,
                        size: 45,
                        color: AppColors.grayMedium,
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      size: 45,
                      color: AppColors.grayMedium,
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            detail.memberName ?? 'Unknown',
            style: AppTextStyles.heading5,
            textAlign: TextAlign.center,
          ),
          if (detail.memberMobile != null &&
              detail.memberMobile!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              detail.memberMobile!,
              style: AppTextStyles.body2.copyWith(color: AppColors.primary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<KeyValueField> fields) {
    final visibleFields = fields.where((f) => f.hasValue).toList();
    if (visibleFields.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: AppColors.backgroundGray,
          child: Text(title, style: AppTextStyles.label),
        ),
        ...visibleFields.map((field) {
          final isContact = field.key != null &&
              (field.key!.toLowerCase().contains('email') ||
                  field.key!.toLowerCase().contains('mobile') ||
                  field.key!.toLowerCase().contains('telephone'));

          return Container(
            color: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.divider, width: 0.5),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    field.key ?? '',
                    style: AppTextStyles.caption
                        .copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    field.value ?? '',
                    style: AppTextStyles.body2.copyWith(
                      color: isContact
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildAddressSection(List<AddressDetail> addresses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: AppColors.backgroundGray,
          child: Text('Address', style: AppTextStyles.label),
        ),
        ...addresses.map((addr) {
          if (addr.fullAddress.isEmpty) return const SizedBox.shrink();
          return Container(
            width: double.infinity,
            color: AppColors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(addr.fullAddress, style: AppTextStyles.body2),
                if (addr.phoneNo != null && addr.phoneNo!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () async {
                      final uri = Uri.parse('tel:${addr.phoneNo}');
                      if (await canLaunchUrl(uri)) await launchUrl(uri);
                    },
                    child: Text(
                      'Phone: ${addr.phoneNo}',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.primary),
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
      ],
    );
  }
}
