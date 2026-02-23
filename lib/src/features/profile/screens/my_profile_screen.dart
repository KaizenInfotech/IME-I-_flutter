import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/storage/local_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/common_toast.dart';
import '../../celebrations/providers/celebrations_provider.dart';
import '../providers/profile_provider.dart';

/// Port of iOS DashProfileViewController.
/// Fetches member profile via Member/GetMemberDetails API and displays
/// photo (with camera upload), name, contact actions, Change Request button,
/// detail rows with Hide/Show toggles and Company Name edit.
class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({
    super.key,
    required this.profileId,
    required this.groupId,
    this.memberName,
    this.clubName,
    this.pic,
    this.mobile,
    this.email,
    this.personalDetails,
    this.familyMembers,
    this.addresses,
  });

  final String profileId;
  final String groupId;
  final String? memberName;
  final String? clubName;
  final String? pic;
  final String? mobile;
  final String? email;
  final List<Map<String, String>>? personalDetails;
  final List<Map<String, String>>? familyMembers;
  final List<Map<String, String>>? addresses;

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  // iOS: hidewhatsStatus, hidenumStatus, emailSts
  int _hideWhatsStatus = 1;
  int _hideNumStatus = 1;
  int _emailStatus = 1;
  String _companyName = '';
  String _dob = '';
  String _doa = '';
  bool _statesSynced = false;

  @override
  void initState() {
    super.initState();
    if (widget.personalDetails == null && widget.profileId.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ProfileProvider>().fetchMemberProfile(
              profileId: widget.profileId,
              groupId: widget.groupId,
            );
      });
    }
  }

  /// Sync toggle/edit states from API data — only once per load.
  /// Also persists hide flags to LocalStorage so celebrations can use them
  /// for the current user's events (API doesn't return hide flags per event).
  void _syncStatesIfNeeded(Map<String, dynamic> data) {
    if (_statesSynced) return;
    _statesSynced = true;
    _hideWhatsStatus =
        int.tryParse(data['hide_whatsnum']?.toString() ?? '1') ?? 1;
    _hideNumStatus = int.tryParse(data['hide_num']?.toString() ?? '1') ?? 1;
    _emailStatus = int.tryParse(data['hide_mail']?.toString() ?? '1') ?? 1;
    _companyName = data['Company_name']?.toString().trim() ?? '';
    // Android reads 'birthday' and 'annivarsary' (misspelled) from API response,
    // then sends as 'DOB' and 'DOA' in the update request
    _dob = data['birthday']?.toString().trim() ?? '';
    _doa = data['annivarsary']?.toString().trim() ?? '';
    // Persist hide flags to LocalStorage for celebrations to use
    _saveHideFlagsToStorage();
  }

  /// Save current hide flags to LocalStorage so celebrations provider
  /// can apply them to the current user's events.
  void _saveHideFlagsToStorage() {
    final storage = LocalStorage.instance;
    storage.setString('hide_whatsnum', _hideWhatsStatus.toString());
    storage.setString('hide_num', _hideNumStatus.toString());
    storage.setString('hide_mail', _emailStatus.toString());
  }

  /// Format date from dd/MM/yyyy to d MMM yyyy.
  String? _formatDate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.contains('1753')) return null;
    try {
      final parsed = DateFormat('dd/MM/yyyy').parse(value.trim());
      return DateFormat('d MMM yyyy').format(parsed);
    } catch (_) {
      return value;
    }
  }

  /// iOS: firstName + middleName + lastName
  String _nameFromApi(Map<String, dynamic> data) {
    final parts = <String>[];
    final first = data['First_Name']?.toString().trim() ?? '';
    final middle = data['Middle_Name']?.toString().trim() ?? '';
    final last = data['Last_Name']?.toString().trim() ?? '';
    if (first.isNotEmpty) parts.add(first);
    if (middle.isNotEmpty) parts.add(middle);
    if (last.isNotEmpty) parts.add(last);
    if (parts.isNotEmpty) return parts.join(' ');
    return data['member_name']?.toString().trim() ?? '';
  }

  /// Android: ProfileActivity.updatedProfileWhatsAppNumberHideShow() etc.
  /// Each toggle tap triggers immediate API call, then refreshes profile data.
  /// Android uses `memberprofileid` (from memProfileId pref) for the POST update,
  /// which is different from `MemProfileId` (masteruid) used in the GET call.
  Future<void> _callUpdateMember({
    String? successMessage,
  }) async {
    // Persist hide flags immediately so celebrations uses updated values
    _saveHideFlagsToStorage();
    final provider = context.read<ProfileProvider>();
    // Android: POST uses memberprofileid (from Intent/memProfileId pref)
    final updateProfileId =
        LocalStorage.instance.memberProfileId ?? widget.profileId;
    final success = await provider.updateMemberToggles(
      profileId: updateProfileId,
      mobileNumHide: _hideWhatsStatus,
      secondaryNumHide: _hideNumStatus,
      emailHide: _emailStatus,
      dob: _dob,
      doa: _doa,
      companyName: _companyName,
    );

    if (!mounted) return;

    if (success) {
      // Android: shows toast on success
      if (successMessage != null) {
        CommonToast.success(context, successMessage);
      }
      // Silently refresh profile data in background.
      // Do NOT reset _statesSynced — local toggle state is already correct
      // after setState(), and resetting would cause flicker when API data arrives.
      provider.fetchMemberProfile(
        profileId: widget.profileId,
        groupId: widget.groupId,
      );
      // Android: after any toggle change (hide_mail, hide_num, hide_whatsnum)
      // or DOB/DOA change, refresh celebrations so the server returns updated
      // EmailIds/MobileNo arrays reflecting the member's hide preferences.
      final groupId = widget.groupId;
      final celebProvider = context.read<CelebrationsProvider>();
      celebProvider.fetchBirthdays(groupId: groupId);
      celebProvider.fetchAnniversaries(groupId: groupId);
      celebProvider.fetchEvents(groupId: groupId);
    } else {
      // Android: shows error toast on failure
      CommonToast.error(
        context,
        'Failed to receive data from server. Please try again.',
      );
    }
  }

  /// iOS: pick image from camera or gallery, then upload.
  Future<void> _pickAndUploadPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null || !mounted) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 70);
    if (picked == null || !mounted) return;

    final bytes = await picked.readAsBytes();

    if (!mounted) return;
    final provider = context.read<ProfileProvider>();
    final imagePath = await provider.uploadProfilePhoto(
      profileId: widget.profileId,
      groupId: widget.groupId,
      imageBytes: bytes.toList(),
    );

    if (!mounted) return;
    if (imagePath != null) {
      // Store in local storage for dashboard
      LocalStorage.instance.setString('profileImg', imagePath);
      CommonToast.success(context, 'Image changed successfully');
      // Refresh profile
      provider.fetchMemberProfile(
        profileId: widget.profileId,
        groupId: widget.groupId,
      );
    } else {
      CommonToast.error(context, 'Failed to upload image');
    }
  }

  /// Show edit dialog for company name.
  void _showCompanyNameEditor(Map<String, dynamic> data) {
    final controller = TextEditingController(text: _companyName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Company Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Company Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _companyName = controller.text.trim();
              });
              Navigator.pop(ctx);
              _callUpdateMember();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  /// Show date picker for DOB or Anniversary, update state and call API.
  Future<void> _pickDate({required bool isDob}) async {
    final rawValue = isDob ? _dob : _doa;
    DateTime initial = DateTime.now();
    try {
      if (rawValue.isNotEmpty && !rawValue.contains('1753')) {
        initial = DateFormat('dd/MM/yyyy').parse(rawValue.trim());
      }
    } catch (_) {}

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;

    final formatted = DateFormat('dd/MM/yyyy').format(picked);
    setState(() {
      if (isDob) {
        _dob = formatted;
      } else {
        _doa = formatted;
      }
    });
    _callUpdateMember();
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _launchSms(String phone) async {
    final uri = Uri(scheme: 'sms', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _launchEmail(String emailAddr) async {
    final uri = Uri(scheme: 'mailto', path: emailAddr);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _launchWhatsApp(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('https://wa.me/$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    // If personalDetails were passed directly (from other screens), use them
    if (widget.personalDetails != null) {
      return _buildLegacyScaffold();
    }

    // Otherwise, use provider data from API
    return Consumer<ProfileProvider>(
      builder: (context, provider, _) {
        // Only show full loading spinner on first load (no data yet).
        // During refresh (after toggle update), keep content visible
        // matching Android ProgressDialog overlay behavior.
        if (provider.isLoadingProfile && provider.memberProfile == null) {
          return Scaffold(
            backgroundColor: AppColors.scaffoldBackground,
            appBar: const CommonAppBar(title: 'Profile'),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final data = provider.memberProfile;
        if (data == null) {
          return Scaffold(
            backgroundColor: AppColors.scaffoldBackground,
            appBar: const CommonAppBar(title: 'Profile'),
            body: const Center(child: Text('No profile data available')),
          );
        }

        // Sync toggle states from API data (only once, not on every rebuild)
        _syncStatesIfNeeded(data);

        final name = _nameFromApi(data);
        final pic = data['member_profile_photo_path']?.toString();
        final mobile = data['Whatsapp_num']?.toString().trim() ?? '';
        final secondaryMobile = data['Secondry_num']?.toString().trim() ?? '';
        final email = data['member_email_id']?.toString().trim() ?? '';

        return _buildProfileScaffold(
          data: data,
          name: name,
          pic: pic,
          mobile: mobile,
          secondaryMobile: secondaryMobile,
          email: email,
        );
      },
    );
  }

  /// Main profile scaffold matching iOS DashProfileViewController.
  Widget _buildProfileScaffold({
    required Map<String, dynamic> data,
    required String name,
    String? pic,
    required String mobile,
    required String secondaryMobile,
    required String email,
  }) {
    final hasPic = pic != null && pic.isNotEmpty && pic.startsWith('http');
    final encodedPic = pic?.replaceAll(' ', '%20');

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: const CommonAppBar(title: 'Profile'),
      body: ListView(
        children: [
          // ─── Profile Photo + Name (centered) ──────────────
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                // Photo with camera overlay
                GestureDetector(
                  onTap: _pickAndUploadPhoto,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: AppColors.primary, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.border,
                          backgroundImage: hasPic
                              ? CachedNetworkImageProvider(encodedPic!)
                              : null,
                          child: !hasPic
                              ? const Icon(Icons.person,
                                  size: 50, color: AppColors.grayMedium)
                              : null,
                        ),
                      ),
                      // Camera icon overlay (bottom-right)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: AppColors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: AppColors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: AppTextStyles.heading5,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // ─── Action Buttons (Call, Message, Email, WhatsApp) ─────
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ActionCircle(
                  icon: Icons.call,
                  color: AppColors.primary,
                  enabled: mobile.isNotEmpty,
                  onTap: () => _launchPhone(mobile),
                ),
                const SizedBox(width: 20),
                _ActionCircle(
                  icon: Icons.message,
                  color: Colors.amber.shade700,
                  enabled: mobile.isNotEmpty,
                  onTap: () => _launchSms(mobile),
                ),
                const SizedBox(width: 20),
                _ActionCircle(
                  icon: Icons.email,
                  color: AppColors.primaryBlue,
                  enabled: email.isNotEmpty,
                  onTap: () => _launchEmail(email),
                ),
                const SizedBox(width: 20),
                _WhatsAppCircle(
                  enabled: mobile.isNotEmpty,
                  onTap: () => _launchWhatsApp(mobile),
                ),
              ],
            ),
          ),

          // ─── Change Request Button ──────────────────────
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // iOS: navigates to ChangeRequestViewController
                  // Pass memID from API data
                  final memId =
                      data['memID']?.toString() ?? widget.profileId;
                  context.push('/profile/change-request', extra: {
                    'memberId': memId,
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Change Request',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ─── Detail Rows ───────────────────────────────
          Container(
            color: AppColors.white,
            child: Column(
              children: [
                _buildDetailRow(
                  'Chapter/Branch Name',
                  data['Chaptr_Brnch_Name']?.toString(),
                ),
                _buildDetailRow(
                  'Membership Id',
                  data['IMEI_Membership_Id']?.toString(),
                ),
                _buildDetailRow(
                  'MemberShip Grade',
                  data['Membership_Grade']?.toString(),
                ),

                // Mobile with Hide/Show toggle
                _buildToggleRow(
                  'Mobile No. (Active on WhatsApp)',
                  mobile,
                  isHidden: _hideWhatsStatus == 0,
                  onToggle: (val) {
                    setState(() => _hideWhatsStatus = val ? 1 : 0);
                    _callUpdateMember(
                      successMessage:
                          'This Number status updated successfully',
                    );
                  },
                ),

                // Secondary Mobile with Hide/Show toggle
                _buildToggleRow(
                  'Secondary Mobile No.',
                  secondaryMobile,
                  isHidden: _hideNumStatus == 0,
                  onToggle: (val) {
                    setState(() => _hideNumStatus = val ? 1 : 0);
                    _callUpdateMember(
                      successMessage:
                          'Secondary Number status updated successfully',
                    );
                  },
                ),

                // Email with Hide/Show toggle
                _buildToggleRow(
                  'Email',
                  email,
                  isHidden: _emailStatus == 0,
                  onToggle: (val) {
                    setState(() => _emailStatus = val ? 1 : 0);
                    _callUpdateMember(
                      successMessage:
                          'Email status updated successfully',
                    );
                  },
                ),

                // Date of Birth with calendar icon
                _buildDateRow(
                  'Date of Birth',
                  _formatDate(_dob),
                  onTap: () => _pickDate(isDob: true),
                ),

                // Date of Anniversary with calendar icon
                _buildDateRow(
                  'Date of Anniversary',
                  _formatDate(_doa),
                  onTap: () => _pickDate(isDob: false),
                ),

                // Company Name with edit pencil
                _buildEditableRow(
                  'Company Name',
                  _companyName,
                  onEdit: () => _showCompanyNameEditor(data),
                ),

                _buildDetailRow('Address', data['Address']?.toString()),
                _buildDetailRow('City', data['City']?.toString()),
                _buildDetailRow('State', data['State']?.toString()),
                _buildDetailRow('Pincode', data['pincode']?.toString()),
                _buildDetailRow('Country', data['Country']?.toString()),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Standard detail row: label on top, value below — left-aligned.
  Widget _buildDetailRow(String label, String? value) {
    final str = value?.trim() ?? '';
    if (str.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style:
                AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(str, style: AppTextStyles.body2),
        ],
      ),
    );
  }

  /// Detail row with Hide/Show toggle switch.
  /// iOS: switch toggles hide_whatsnum / hide_num / hide_mail.
  Widget _buildToggleRow(
    String label,
    String value, {
    required bool isHidden,
    required ValueChanged<bool> onToggle,
  }) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(value, style: AppTextStyles.body2),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                isHidden ? 'Hide' : 'Show',
                style: AppTextStyles.captionSmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
              SizedBox(
                height: 28,
                child: Switch(
                  value: !isHidden,
                  onChanged: onToggle,
                  activeTrackColor: AppColors.primary.withAlpha(100),
                  activeThumbColor: AppColors.primary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Detail row with calendar icon (for DOB / Anniversary).
  Widget _buildDateRow(String label, String? displayValue,
      {required VoidCallback onTap}) {
    final str = displayValue?.trim() ?? '';
    if (str.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(str, style: AppTextStyles.body2),
              ],
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: const Icon(
              Icons.calendar_today,
              size: 18,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  /// Detail row with edit pencil icon (for Company Name).
  Widget _buildEditableRow(
    String label,
    String value, {
    required VoidCallback onEdit,
  }) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(value, style: AppTextStyles.body2),
              ],
            ),
          ),
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
    );
  }

  /// Legacy build for when personalDetails are passed directly from other screens.
  Widget _buildLegacyScaffold() {
    final hasPic = widget.pic != null &&
        widget.pic!.isNotEmpty &&
        widget.pic!.startsWith('http');
    final encodedPic = widget.pic?.replaceAll(' ', '%20');

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: const CommonAppBar(title: 'Profile'),
      body: ListView(
        children: [
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.border,
                    backgroundImage:
                        hasPic ? CachedNetworkImageProvider(encodedPic!) : null,
                    child: !hasPic
                        ? const Icon(Icons.person,
                            size: 50, color: AppColors.grayMedium)
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.memberName ?? '',
                  style: AppTextStyles.heading5,
                  textAlign: TextAlign.center,
                ),
                if (widget.clubName != null && widget.clubName!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.clubName!,
                    style: AppTextStyles.body3
                        .copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
          if ((widget.mobile != null && widget.mobile!.isNotEmpty) ||
              (widget.email != null && widget.email!.isNotEmpty))
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.mobile != null && widget.mobile!.isNotEmpty) ...[
                    _ActionCircle(
                      icon: Icons.call,
                      color: AppColors.primary,
                      enabled: true,
                      onTap: () => _launchPhone(widget.mobile!),
                    ),
                    const SizedBox(width: 20),
                    _ActionCircle(
                      icon: Icons.chat,
                      color: Colors.amber.shade700,
                      enabled: true,
                      onTap: () => _launchSms(widget.mobile!),
                    ),
                    const SizedBox(width: 20),
                  ],
                  if (widget.email != null && widget.email!.isNotEmpty) ...[
                    _ActionCircle(
                      icon: Icons.email,
                      color: AppColors.primaryBlue,
                      enabled: true,
                      onTap: () => _launchEmail(widget.email!),
                    ),
                    const SizedBox(width: 20),
                  ],
                  if (widget.mobile != null && widget.mobile!.isNotEmpty)
                    _WhatsAppCircle(
                      enabled: true,
                      onTap: () => _launchWhatsApp(widget.mobile!),
                    ),
                ],
              ),
            ),
          if (widget.personalDetails != null &&
              widget.personalDetails!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              color: AppColors.white,
              child: Column(
                children: widget.personalDetails!.map((detail) {
                  return _buildDetailRow(
                    detail['key'] ?? '',
                    detail['value'],
                  );
                }).toList(),
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// Circular action button matching iOS profile action buttons.
class _WhatsAppCircle extends StatelessWidget {
  const _WhatsAppCircle({
    required this.enabled,
    required this.onTap,
  });

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled ? Colors.green.withAlpha(25) : AppColors.grayLight,
        ),
        child: Center(
          child: enabled
              ? Image.asset('assets/images/whatsapp.png', width: 22, height: 22)
              : Image.asset('assets/images/whats_grey.png', width: 33, height: 33, color: AppColors.grayMedium,),
        ),
      ),
    );
  }
}

class _ActionCircle extends StatelessWidget {
  const _ActionCircle({
    required this.icon,
    required this.color,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled ? color.withAlpha(25) : AppColors.grayLight,
        ),
        child: Icon(
          icon,
          size: 22,
          color: enabled ? color : AppColors.grayMedium,
        ),
      ),
    );
  }
}
