import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_loader.dart';
import '../../../core/widgets/common_toast.dart';
import '../models/member_detail_result.dart';
import '../providers/directory_provider.dart';

/// Port of iOS JitoProfileViewController.swift — simplified member profile.
/// Shows: profile photo, name/designation, key-value table (personal details),
/// and contact action buttons (call, SMS, WhatsApp, email).
class JitoProfileScreen extends StatefulWidget {
  const JitoProfileScreen({
    super.key,
    required this.memberProfileId,
    required this.groupId,
    this.memberName,
  });

  final String memberProfileId;
  final String groupId;
  final String? memberName;

  @override
  State<JitoProfileScreen> createState() => _JitoProfileScreenState();
}

class _JitoProfileScreenState extends State<JitoProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  /// iOS: GetUserdetails → POST Member/GetMember
  Future<void> _loadProfile() async {
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

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// iOS: whatsAppBtnClickedd — open WhatsApp with phone number
  void _openWhatsApp(String phone) {
    _launchUrl('https://wa.me/$phone');
  }

  /// iOS: PhoneCallBtnClickedd
  void _makeCall(String phone) {
    _launchUrl('tel:$phone');
  }

  /// iOS: smsBtnClickedd
  void _sendSms(String phone) {
    _launchUrl('sms:$phone');
  }

  /// iOS: mailBtnClickedd
  void _sendEmail(String email) {
    _launchUrl('mailto:$email');
  }

  /// Build key-value pairs from member details — iOS: muarrayKey/muarrayValue
  List<MapEntry<String, String>> _buildKeyValuePairs(MemberDetail member) {
    final pairs = <MapEntry<String, String>>[];

    // Personal details
    if (member.personalMemberDetails != null) {
      for (final detail in member.personalMemberDetails!) {
        if (detail.key != null &&
            detail.value != null &&
            detail.value!.isNotEmpty) {
          pairs.add(MapEntry(detail.key!, detail.value!));
        }
      }
    }

    // Business details
    if (member.businessMemberDetails != null) {
      for (final detail in member.businessMemberDetails!) {
        if (detail.key != null &&
            detail.value != null &&
            detail.value!.isNotEmpty) {
          pairs.add(MapEntry(detail.key!, detail.value!));
        }
      }
    }

    return pairs;
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
          widget.memberName ?? 'Profile',
          style: const TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 17,
            fontWeight: FontWeight.w400,
            color: AppColors.textOnPrimary,
          ),
        ),
      ),
      body: Consumer<DirectoryProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final member = provider.selectedMember;
          if (member == null) {
            return const Center(child: Text('No profile data available'));
          }

          final keyValuePairs = _buildKeyValuePairs(member);

          return Column(
            children: [
              // iOS: profile header — userImgVieww, UserNameLbll, clubNameee
              Container(
                color: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
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
              ),
              // iOS: contact actions (phone, sms, whatsapp, email)
              Container(
                color: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (member.memberMobile != null &&
                        member.memberMobile!.isNotEmpty) ...[
                      _contactButton(Icons.phone, 'Call', AppColors.green,
                          () => _makeCall(member.memberMobile!)),
                      _contactButton(Icons.message, 'SMS', Colors.amber.shade700,
                          () => _sendSms(member.memberMobile!)),
                      _whatsAppContactButton(
                          () => _openWhatsApp(member.memberMobile!)),
                    ],
                    if (member.memberEmail != null &&
                        member.memberEmail!.isNotEmpty)
                      _contactButton(Icons.email, 'Email', AppColors.orange,
                          () => _sendEmail(member.memberEmail!)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // iOS: TbleViewww — key-value pairs table
              Expanded(
                child: keyValuePairs.isEmpty
                    ? const Center(
                        child: Text(
                          'No details available',
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: keyValuePairs.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final entry = keyValuePairs[index];
                          return Container(
                            color: AppColors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 120,
                                  child: Text(
                                    entry.key,
                                    style: const TextStyle(
                                      fontFamily: AppTextStyles.fontFamily,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    entry.value,
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
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _whatsAppContactButton(VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Image.asset('assets/images/whatsapp.png', width: 24, height: 24),
            const SizedBox(height: 4),
            Text(
              'WhatsApp',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 11,
                color: const Color(0xFF25D366),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactButton(
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
}
