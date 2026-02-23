import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../models/club_result.dart';
import '../providers/find_club_provider.dart';

/// Port of iOS InfoSegmentFindAClubViewController — club detail screen.
/// Shows club info, address, map link, officer contacts, and members.
class ClubDetailScreen extends StatefulWidget {
  const ClubDetailScreen({
    super.key,
    required this.groupId,
    this.clubName = 'Club Details',
  });

  final String groupId;
  final String clubName;

  @override
  State<ClubDetailScreen> createState() => _ClubDetailScreenState();
}

class _ClubDetailScreenState extends State<ClubDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final provider = context.read<FindClubProvider>();
    provider.fetchClubDetails(grpId: widget.groupId);
    provider.fetchClubMembers(grpId: widget.groupId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _makeCall(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _sendSms(String number) async {
    final uri = Uri.parse('sms:$number');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _sendEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _openWhatsApp(String number) async {
    final cleaned = number.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.length < 7) return;
    final uri = Uri.parse('https://wa.me/$cleaned');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// iOS: openMapForPlace() — open map for club location
  Future<void> _openMap(ClubDetail detail) async {
    if (!detail.hasCoordinates) return;
    final lat = detail.lat!;
    final lng = detail.longi!;

    // Try Google Maps first, then fallback to Apple Maps
    final googleUri = Uri.parse(
        'comgooglemaps://?saddr=&daddr=$lat,$lng&directionsmode=driving');
    if (await canLaunchUrl(googleUri)) {
      await launchUrl(googleUri);
      return;
    }

    final appleUri = Uri.parse(
        'https://maps.apple.com/?daddr=$lat,$lng&dirflg=d');
    if (await canLaunchUrl(appleUri)) {
      await launchUrl(appleUri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openWebsite(String url) async {
    var normalized = url.trim();
    if (!normalized.startsWith('http')) {
      normalized = 'https://$normalized';
    }
    final uri = Uri.tryParse(normalized);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CommonAppBar(
        title: widget.clubName,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.white,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withValues(alpha: 0.7),
          tabs: const [
            Tab(text: 'INFO'),
            Tab(text: 'MEMBERS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInfoTab(),
          _buildMembersTab(),
        ],
      ),
    );
  }

  /// iOS: InfoSegmentFindAClubViewController — club info tab
  Widget _buildInfoTab() {
    return Consumer<FindClubProvider>(
      builder: (context, provider, _) {
        if (provider.isLoadingDetail) {
          return const Center(child: CircularProgressIndicator());
        }

        final detail = provider.selectedDetail;
        if (detail == null) {
          return const Center(child: Text('No details available'));
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Club name and meeting info
              Container(
                width: double.infinity,
                color: AppColors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detail.clubName ?? 'Unknown Club',
                      style: AppTextStyles.heading5,
                    ),
                    if (detail.districtId != null &&
                        detail.districtId!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'District: ${detail.districtId}',
                        style: AppTextStyles.caption,
                      ),
                    ],
                    if (detail.displayMeetingInfo.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.schedule,
                              size: 16, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            detail.displayMeetingInfo,
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Address + map
              if (detail.fullAddress.isNotEmpty)
                Container(
                  width: double.infinity,
                  color: AppColors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Address', style: AppTextStyles.label),
                      const SizedBox(height: 8),
                      Text(detail.fullAddress, style: AppTextStyles.body2),
                      if (detail.hasCoordinates) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _openMap(detail),
                            icon: const Icon(Icons.map, size: 18),
                            label: const Text('Open in Maps'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              const SizedBox(height: 8),

              // Website
              if (detail.clubWebsite != null &&
                  detail.clubWebsite!.isNotEmpty)
                Container(
                  width: double.infinity,
                  color: AppColors.white,
                  child: ListTile(
                    leading: const Icon(Icons.language,
                        color: AppColors.primary),
                    title: Text(
                      detail.clubWebsite!,
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    onTap: () => _openWebsite(detail.clubWebsite!),
                  ),
                ),
              const SizedBox(height: 8),

              // Officers
              _buildOfficerSection(
                title: 'President',
                name: detail.presidentName,
                mobile: detail.presidentMobile,
                email: detail.presidentEmail,
              ),
              _buildOfficerSection(
                title: 'Secretary',
                name: detail.secretaryName,
                mobile: detail.secretaryMobile,
                email: detail.secretaryEmail,
              ),
              _buildOfficerSection(
                title: 'District Governor',
                name: detail.governorName,
                mobile: detail.governorMobile,
                email: detail.governorEmail,
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  /// iOS: ClubDetailsTableViewCell — officer contact card
  Widget _buildOfficerSection({
    required String title,
    String? name,
    String? mobile,
    String? email,
  }) {
    if (name == null || name.isEmpty) return const SizedBox.shrink();

    final hasMobile = mobile != null && mobile.trim().isNotEmpty;
    final hasEmail = email != null && email.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      color: AppColors.white,
      margin: const EdgeInsets.only(bottom: 1),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.label),
          const SizedBox(height: 4),
          Text(name, style: AppTextStyles.body2.copyWith(
            fontWeight: FontWeight.w500,
          )),
          const SizedBox(height: 8),
          Row(
            children: [
              // Call
              _buildContactIcon(
                icon: Icons.call,
                color: hasMobile ? AppColors.primary : AppColors.grayMedium,
                onTap: hasMobile ? () => _makeCall(mobile) : null,
              ),
              const SizedBox(width: 16),
              // SMS
              _buildContactIcon(
                icon: Icons.message,
                color: hasMobile ? Colors.amber.shade700 : AppColors.grayMedium,
                onTap: hasMobile ? () => _sendSms(mobile) : null,
              ),
              const SizedBox(width: 16),
              // Email
              _buildContactIcon(
                icon: Icons.email,
                color: hasEmail ? AppColors.primaryBlue : AppColors.grayMedium,
                onTap: hasEmail ? () => _sendEmail(email) : null,
              ),
              const SizedBox(width: 16),
              // WhatsApp
              InkWell(
                onTap: hasMobile ? () => _openWhatsApp(mobile) : null,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: hasMobile
                        ? AppColors.green.withValues(alpha: 0.1)
                        : AppColors.grayMedium.withValues(alpha: 0.1),
                  ),
                  child: Center(
                    child: hasMobile
                        ? Image.asset('assets/images/whatsapp.png', width: 18, height: 18)
                        : Image.asset('assets/images/whats_grey.png', width: 22, height: 22, color: AppColors.grayMedium),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactIcon({
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.1),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  /// iOS: MemberSegmentViewController — club members tab
  Widget _buildMembersTab() {
    return Consumer<FindClubProvider>(
      builder: (context, provider, _) {
        if (provider.isLoadingMembers) {
          return const Center(child: CircularProgressIndicator());
        }

        final members = provider.clubMembers;
        if (members.isEmpty) {
          return const Center(
            child: Text('No members available',
                style: TextStyle(color: AppColors.textSecondary)),
          );
        }

        return ListView.builder(
          itemCount: members.length,
          itemBuilder: (_, index) {
            final member = members[index];
            return Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(
                  bottom:
                      BorderSide(color: AppColors.divider, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  // Profile pic
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.border, width: 1),
                    ),
                    child: ClipOval(
                      child: member.hasValidPic
                          ? Image.network(
                              member.encodedPicUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.person,
                                size: 24,
                                color: AppColors.grayMedium,
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              size: 24,
                              color: AppColors.grayMedium,
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member.memberName ?? 'Unknown',
                          style: AppTextStyles.body2.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (member.designation != null &&
                            member.designation!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            member.designation!,
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
