import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_loader.dart';
import '../../../core/widgets/common_toast.dart';
import '../../notifications/providers/notifications_provider.dart';
import '../models/group_result.dart';
import '../providers/dashboard_provider.dart';
import '../providers/group_provider.dart';
import '../widgets/group_switcher.dart';
import 'sidebar_screen.dart';

// ═════════════════════════════════════════════════════════════════
// Hardcoded IMEI dashboard module definitions
// iOS: arrarrNewGroupList + arrarrNewNameList (Row 1)
//      arrarrNewGroupList1 + arrarrNewNameList1 (Row 2)
// ═════════════════════════════════════════════════════════════════

class _DashboardModule {
  final String name;
  final String assetPath;
  final String id;

  const _DashboardModule({
    required this.name,
    required this.assetPath,
    required this.id,
  });
}

/// Row 1: Governing Council Members, Sub Committees, Branch & Chapter Committees, Find Member
const _imeiModulesRow1 = [
  _DashboardModule(
    name: 'Governing\nCouncil\nMembers',
    assetPath: 'assets/images/counceling_imei.png',
    id: 'councelingImei',
  ),
  _DashboardModule(
    name: 'Sub\nCommittees',
    assetPath: 'assets/images/sub_committee.png',
    id: 'subcommittee',
  ),
  _DashboardModule(
    name: 'Branch &\nChapter\nCommittees',
    assetPath: 'assets/images/chapter_branch.png',
    id: 'chapterbranch',
  ),
  _DashboardModule(
    name: 'Find\nMember',
    assetPath: 'assets/images/imei_mem.png',
    id: 'ImeiMem',
  ),
];

/// Row 2: Past Presidents, MER(I), iMelange, HO
const _imeiModulesRow2 = [
  _DashboardModule(
    name: 'Past\nPresidents',
    assetPath: 'assets/images/past_pre.png',
    id: 'pastPre',
  ),
  _DashboardModule(
    name: 'MER(I)',
    assetPath: 'assets/images/imei_mer.png',
    id: 'imeiMer',
  ),
  _DashboardModule(
    name: 'iMelange',
    assetPath: 'assets/images/imelange.png',
    id: 'imilenga',
  ),
  _DashboardModule(
    name: 'HO',
    assetPath: 'assets/images/feedback.png',
    id: 'feedback2',
  ),
];

// ═════════════════════════════════════════════════════════════════
// DashboardScreen — Port of iOS RootDashViewController
// ═════════════════════════════════════════════════════════════════

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver {
  bool _isInitialized = false;
  String _appVersion = '';

  /// iOS: member[0].memberProfilePhotoPath from GetMemberDetails API
  String? _memberProfilePhotoUrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initDashboard());
    _loadVersion();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Android: onResume — refresh notification badge when app comes to foreground.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshNotificationCount();
      // Android: displayNotificationCount — also refresh local unread count
      context.read<NotificationsProvider>().refreshUnreadCount();
    }
  }

  /// iOS: PackageInfo → versionTxt.text = "Version: \(verSion)"
  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() => _appVersion = info.version);
    }
  }

  // ─── INITIALIZATION ───────────────────────────────────────────

  /// iOS: viewDidLoad
  /// 1. Fetch groups (GetAllGroupListSync)
  /// 2. Fetch member details for profile photo (getRequest / GetMemberDetails)
  /// 3. Fetch dashboard data (modules, banners, notification count, assistance gov)
  /// 4. Set device token
  /// 5. Fetch birthday/anniversary/event data
  Future<void> _initDashboard() async {
    if (_isInitialized) return;
    _isInitialized = true;

    final groupProvider = context.read<GroupProvider>();
    final dashProvider = context.read<DashboardProvider>();

    CommonLoader.show(context);

    // iOS: GetAllGroupListSync — fetch user's groups
    await groupProvider.fetchGroups();

    if (!mounted) return;

    // Use selectedGroup if available, otherwise fall back to LocalStorage
    final selectedGroup = groupProvider.selectedGroup;
    final groupId = selectedGroup?.grpId ??
        LocalStorage.instance.groupId ??
        '';
    final profileId = selectedGroup?.grpProfileId ??
        LocalStorage.instance.grpProfileId ??
        '';

    debugPrint('_initDashboard: groupId=$groupId, profileId=$profileId, '
        'selectedGroup=${selectedGroup?.grpId}');

    // Fetch dashboard data (if groupId available) and profile photo in parallel
    await Future.wait([
      if (groupId.isNotEmpty)
        _fetchDashboardData(
          dashProvider: dashProvider,
          groupId: groupId,
          profileId: profileId,
        ),
      _fetchMemberProfilePhoto(
        masterUid: LocalStorage.instance.masterUid ?? '',
        grpId: LocalStorage.instance.groupIdPrimary ?? '',
      ),
    ]);

    // iOS: functionForSetDeviceToken — update device token on server
    _updateDeviceToken();

    if (!mounted) return;

    // Android: displayNotificationCount — refresh local unread count + cleanup expired
    final notiProvider = context.read<NotificationsProvider>();
    notiProvider.deleteExpiredNotifications();
    notiProvider.refreshUnreadCount();

    CommonLoader.dismiss(context);
  }

  /// iOS: fetchDashboardData — parallel API calls for modules, banners, notifications, assistance.
  Future<void> _fetchDashboardData({
    required DashboardProvider dashProvider,
    required String groupId,
    required String profileId,
  }) async {
    await Future.wait([
      dashProvider.fetchModules(
        groupId: groupId,
        memberProfileId: profileId,
      ),
      dashProvider.fetchBanners(
        groupId: groupId,
        memberProfileId: profileId,
      ),
      dashProvider.fetchNotificationCount(
        groupId: groupId,
        memberProfileId: profileId,
      ),
      dashProvider.fetchAssistanceGovDetails(
        groupId: groupId,
        profileId: profileId,
      ),
    ]);
  }

  // ─── API: GET MEMBER DETAILS FOR PROFILE PHOTO ────────────────

  /// iOS: getRequest(api_key: masterUID, trailerPlayListId: grpid)
  /// GET Member/GetMemberDetails?MemProfileId=...&GrpID=...
  /// Sets userProfileImage from member[0].member_profile_photo_path
  Future<void> _fetchMemberProfilePhoto({
    required String masterUid,
    required String grpId,
  }) async {
    try {
      // iOS sends MemProfileId & GrpID as both query params AND headers
      final response = await ApiClient.instance.get(
        ApiConstants.memberGetMemberDetails,
        queryParams: {
          'MemProfileId': masterUid,
          'GrpID': grpId,
        },
        additionalHeaders: {
          'MemProfileId': masterUid,
          'GrpID': grpId,
        },
      );

      debugPrint('_fetchMemberProfilePhoto: status=${response.statusCode}, '
          'masterUid=$masterUid, grpId=$grpId');

      if (response.statusCode == 200) {
        final data = _parseJson(response.body);
        if (data != null) {
          debugPrint('_fetchMemberProfilePhoto: response keys=${data.keys}');
          // iOS: response.tbGetSponsorReferredResult?.result?.table
          final result = data['TBGetSponsorReferredResult'] ??
              data['tbGetSponsorReferredResult'];
          if (result is Map<String, dynamic>) {
            final resultData = result['Result'] ?? result['result'];
            if (resultData is Map<String, dynamic>) {
              final table = resultData['Table'] ?? resultData['table'];
              if (table is List && table.isNotEmpty) {
                debugPrint('_fetchMemberProfilePhoto: table[0] keys=${table[0].keys}');
                // iOS CodingKey: memberProfilePhotoPath → "member_profile_photo_path"
                final photoPath =
                    table[0]['member_profile_photo_path']?.toString() ?? '';
                debugPrint('_fetchMemberProfilePhoto: photoPath=$photoPath');
                if (photoPath.isNotEmpty && mounted) {
                  setState(() {
                    _memberProfilePhotoUrl = photoPath;
                  });
                }
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('DashboardScreen._fetchMemberProfilePhoto error: $e');
    }
  }

  // ─── API: UPDATE DEVICE TOKEN ─────────────────────────────────

  /// iOS: functionForSetDeviceToken — POST Group/UpdateDeviceTokenNumber
  /// iOS RootDashViewController.swift:3135 — params: MobileNumber, DeviceToken
  Future<void> _updateDeviceToken() async {
    try {
      final mobileNumber =
          LocalStorage.instance.mobileNo ?? '';
      // Read from LocalStorage first, fallback to SecureStorage
      var deviceToken =
          LocalStorage.instance.getString(AppConstants.keyDeviceToken) ?? '';
      if (deviceToken.isEmpty) {
        deviceToken = await SecureStorage.instance.getDeviceToken() ?? '';
      }

      // Don't send empty token — it would overwrite a valid token on the server
      if (mobileNumber.isEmpty || deviceToken.isEmpty) return;

      await ApiClient.instance.post(
        ApiConstants.groupUpdateDeviceTokenNumber,
        body: {
          'MobileNumber': mobileNumber,
          'DeviceToken': deviceToken,
        },
      );
    } catch (e) {
      debugPrint('DashboardScreen._updateDeviceToken error: $e');
    }
  }

  // ─── REFRESH NOTIFICATION COUNT ───────────────────────────────

  /// iOS: getNotifyCount / viewWillAppear — refresh notification badge.
  Future<void> _refreshNotificationCount() async {
    final groupProvider = context.read<GroupProvider>();
    final dashProvider = context.read<DashboardProvider>();
    final selectedGroup = groupProvider.selectedGroup;

    if (selectedGroup != null) {
      await dashProvider.fetchNotificationCount(
        groupId: selectedGroup.grpId ?? '',
        memberProfileId: selectedGroup.grpProfileId ?? '',
      );
    }
  }

  // ─── PULL TO REFRESH ──────────────────────────────────────────

  /// iOS: @objc func refresh(_ sender:AnyObject)
  Future<void> _onRefresh() async {
    if (!mounted) return;
    CommonLoader.show(context);

    final groupProvider = context.read<GroupProvider>();
    final dashProvider = context.read<DashboardProvider>();

    // Re-fetch groups to restore selectedGroup if lost
    await groupProvider.fetchGroups();

    // Use selectedGroup if available, otherwise fall back to LocalStorage
    final selectedGroup = groupProvider.selectedGroup;
    final groupId = selectedGroup?.grpId ??
        LocalStorage.instance.groupId ??
        '';
    final profileId = selectedGroup?.grpProfileId ??
        LocalStorage.instance.grpProfileId ??
        '';

    debugPrint('Dashboard refresh: groupId=$groupId, profileId=$profileId');

    if (groupId.isNotEmpty) {
      await Future.wait([
        _fetchDashboardData(
          dashProvider: dashProvider,
          groupId: groupId,
          profileId: profileId,
        ),
        _fetchMemberProfilePhoto(
          masterUid: LocalStorage.instance.masterUid ?? '',
          grpId: LocalStorage.instance.groupIdPrimary ?? '',
        ),
      ]);
    }

    if (mounted) CommonLoader.dismiss(context);
  }

  // ─── GROUP SWITCHING ──────────────────────────────────────────

  /// iOS: ExitGroupAction / collectionView didSelectItemAt (section 0)
  /// Saves group details to UserDefaults, navigates to MainDashboardViewController.
  Future<void> _onGroupSwitch(GroupResult newGroup) async {
    final groupProvider = context.read<GroupProvider>();
    final dashProvider = context.read<DashboardProvider>();

    await groupProvider.switchGroup(newGroup);

    if (!mounted) return;
    CommonLoader.show(context);

    await _fetchDashboardData(
      dashProvider: dashProvider,
      groupId: newGroup.grpId ?? '',
      profileId: newGroup.grpProfileId ?? '',
    );

    if (!mounted) return;
    CommonLoader.dismiss(context);
  }

  // ─── MODULE TAP NAVIGATION ────────────────────────────────────

  /// iOS: collectionView didSelectItemAt for imeiCollView (row 1)
  void _onRow1ModuleTap(int index, _DashboardModule module) {
    switch (index) {
      case 0:
        // iOS: GoverningCouncilViewController — Member/GetGoverningCouncl
        context.push('/governing-council');
        break;
      case 1:
        // iOS: SubCommitteeViewController — FindClub/GetCommitteelist
        context.push('/sub-committee');
        break;
      case 2:
        // iOS: Branch_ChaptViewController — FindClub/GetClubList
        context.push('/branch-chapter');
        break;
      case 3:
        // iOS: FinddArotarianViewControllerers — FindRotarian/GetRotarianList
        LocalStorage.instance
            .setString(AppConstants.keySessionGetModuleId, '27');
        context.push('/find-member');
        break;
    }
  }

  /// iOS: collectionView didSelectItemAt for imei2CollView (row 2)
  void _onRow2ModuleTap(int index, _DashboardModule module) {
    switch (index) {
      case 0:
        // iOS: PastPresidentListViewController — PastPresidents/getPastPresidentsList
        context.push('/past-presidents', extra: {
          'groupId': LocalStorage.instance.groupId ?? '',
        });
        break;
      case 1:
        // iOS: MERDashViewController — Gallery/GetYear + Gallery/GetMER_List (Type/TransType "1")
        context.push('/mer', extra: {
          'type': '1',
          'title': 'MER(I)',
        });
        break;
      case 2:
        // iOS: iMelengaViewController — Gallery/GetYear + Gallery/GetMER_List (Type/TransType "2")
        context.push('/mer', extra: {
          'type': '2',
          'title': 'iMelange',
        });
        break;
      case 3:
        // iOS: MFMailComposeViewController to hgs@imare.in
        _sendHoFeedbackEmail();
        break;
    }
  }

  /// iOS: row 2 index 3 — HO feedback email to hgs@imare.in
  Future<void> _sendHoFeedbackEmail() async {
    final emailUri = Uri(
      scheme: 'mailto',
      path: 'hgs@imare.in',
      queryParameters: {'subject': 'HO/App feedback:'},
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      if (mounted) {
        CommonToast.error(context,
            'Please check whether you have logged in to your mail account.');
      }
    }
  }

  /// iOS: eventBtnActn / bannerEventCalendarBtn — Events & Celebrations tap.
  void _onEventsCelebrationsTap() {
    context.push('/celebrations');
  }

  /// Android: belliconimg click → ShowNotification.class
  /// Refreshes local unread count when returning from notifications screen.
  void _onNotificationTap() async {
    await context.push('/notifications');
    if (mounted) {
      context.read<NotificationsProvider>().refreshUnreadCount();
    }
  }

  /// iOS: userdetailProfileBtnClicked — navigate to DashProfileViewController
  /// Passes masterUID and grpId0 from UserDefaults.
  /// Re-fetches profile photo on return in case user changed it.
  void _onProfileTap() async {
    final storage = LocalStorage.instance;
    await context.push('/profile', extra: {
      'profileId': storage.masterUid ?? '',
      'groupId': storage.groupIdPrimary ?? '',
    });
    // Refresh profile photo after returning from profile screen
    if (mounted) {
      _fetchMemberProfilePhoto(
        masterUid: storage.masterUid ?? '',
        grpId: storage.groupIdPrimary ?? '',
      );
    }
  }

  // ─── HELPERS ──────────────────────────────────────────────────

  Map<String, dynamic>? _parseJson(String body) {
    if (body.isEmpty) return null;
    try {
      final toParse = body.startsWith('{') ? body : Uri.decodeFull(body);
      final decoded = json.decode(toParse);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    return null;
  }

  // ═══════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SidebarScreen(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/imei_bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Consumer3<DashboardProvider, GroupProvider,
              NotificationsProvider>(
            builder:
                (context, dashProvider, groupProvider, notiProvider, child) {
              return Column(
                children: [
                  // ── Top bar: logo + bell icon + profile avatar
                  _buildTopBar(dashProvider, groupProvider, notiProvider),
                  // ── Member info section: profile pic + name + member ID
                  _buildMemberInfo(),
                  // ── Scrollable content
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _onRefresh,
                      color: AppColors.primary,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            // ── Banner image (iOS: imeiBannerVieww)
                            _buildBanner(),
                            const SizedBox(height: 12),
                            // ── "EVENTS & CELEBRATIONS" pill button
                            _buildEventsCelebrationsButton(),
                            const SizedBox(height: 26),
                            // ── Row 1: 4-column circular module grid
                            _buildModuleRow(_imeiModulesRow1, _onRow1ModuleTap),
                            const SizedBox(height: 26),
                            // ── Row 2: 4-column circular module grid
                            _buildModuleRow(_imeiModulesRow2, _onRow2ModuleTap),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // ── Bottom bar with menu/testing/arrow + version
                  _buildBottomBar(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ─── TOP BAR ──────────────────────────────────────────────────
  // iOS: topImeiVieww — group name label, notification bell, profile image

  Widget _buildTopBar(DashboardProvider dashProvider,
      GroupProvider groupProvider, NotificationsProvider notiProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Logo — tappable for group switching
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final result = await GroupSwitcher.show(
                  context,
                  groups: groupProvider.allGroups,
                  selectedGroup: groupProvider.selectedGroup,
                );
                if (result != null) {
                  _onGroupSwitch(result);
                }
              },
              child: Image.asset(
                'assets/images/headline-logo copy.png',
                height: 32,
                alignment: Alignment.centerLeft,
                fit: BoxFit.contain,
              ),
            ),
          ),
          // iOS: refresh button — pull-to-refresh equivalent
          GestureDetector(
            onTap: () {
              debugPrint('Sync button tapped');
              _onRefresh();
            },
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.sync, color: AppColors.white, size: 30),
            ),
          ),
          // Android: belliconimg + bellcounttxt — notification bell with badge.
          // Uses the higher of API count vs local DB unread count.
          Builder(builder: (context) {
            final badgeCount = dashProvider.notificationCount >
                    notiProvider.unreadCount
                ? dashProvider.notificationCount
                : notiProvider.unreadCount;
            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications),
                  color: AppColors.white,
                  iconSize: 30,
                  onPressed: _onNotificationTap,
                ),
                if (badgeCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppColors.systemRed,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        badgeCount > 99 ? '99+' : badgeCount.toString(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ─── MEMBER INFO SECTION ──────────────────────────────────────
  // iOS: userNameLbl = "\(firstName) \(middleName) \(lastName)"
  //      userMemberIdLbl = "Member ID: \(imeiMemID)"

  Widget _buildMemberInfo() {
    final storage = LocalStorage.instance;
    final memberName = storage.fullName;
    final memberId = storage.imeiMemberId ?? '';

    return GestureDetector(
      onTap: _onProfileTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            // Profile pic on LEFT
            _buildCircleAvatar(
              imageUrl: _memberProfilePhotoUrl ?? "",
              radius: 22,
            ),
            const SizedBox(width: 10),
            // Name + Member ID
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (memberName.isNotEmpty)
                    Text(
                      memberName,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (memberId.isNotEmpty)
                    Text(
                      'Member ID: $memberId',
                      style: const TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.white,
                      ),
                    ),
                ],
              ),
            ),
            // iOS: arrowright button — navigate to DashProfileViewController
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.white,
                  width: 1.5,
                ),
                color: AppColors.white,
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── BANNER ───────────────────────────────────────────────────
  // iOS: imeiBannerVieww with rounded corners, tappable to open events

  Widget _buildBanner() {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 12, right: 12),
      child: GestureDetector(
        onTap: _onEventsCelebrationsTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            'assets/images/banner.png',
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  // ─── EVENTS & CELEBRATIONS BUTTON ─────────────────────────────
  // iOS: eventBtn / fourthViewww — pill-shaped white button

  Widget _buildEventsCelebrationsButton() {
    return GestureDetector(
      onTap: _onEventsCelebrationsTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'EVENTS & CELEBRATIONS',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 19, 2, 71),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── MODULE GRID ROW ──────────────────────────────────────────
  // iOS: imeiCollView / imei2CollView — 4-column circular icons

  Widget _buildModuleRow(
    List<_DashboardModule> modules,
    void Function(int index, _DashboardModule module) onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(modules.length, (index) {
          return Expanded(
            child: _buildModuleItem(
              modules[index],
              () => onTap(index, modules[index]),
            ),
          );
        }),
      ),
    );
  }

  /// Individual module item — circular white icon with shadow, label below.
  /// iOS: bottomCollecctionView cell — ImeiImgView (circular) + Lbl1 (centered, multiline)
  Widget _buildModuleItem(_DashboardModule module, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Circular icon container with white bg and shadow
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Image.asset(
                    module.assetPath,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            // Module name — centered, multiline, white text
            Text(
              module.name,
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ─── BOTTOM BAR ───────────────────────────────────────────────
  // iOS: bottomImeiView — editCompany icon (menu), "Testing" label,
  //      circled right arrow, "Version:" text

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // iOS: editCompany icon — opens sidebar drawer
                GestureDetector(
                  onTap: () {
                    Scaffold.of(context).openDrawer();
                  },
                  child: Image.asset(
                    'assets/images/edit_company.png',
                    width: 36,
                    height: 36,
                  ),
                ),
                // iOS: clubClickedAction — navigate to BranchDashboardViewController
                Flexible(
                  child: GestureDetector(
                    onTap: () {
                      final storage = LocalStorage.instance;
                      context.push('/branch-dashboard', extra: {
                        'branchName': storage.clubName ?? '',
                        'clubName': storage.clubName ?? '',
                      });
                    },
                    child: Text(
                      LocalStorage.instance.clubName ?? '',
                      style: const TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 19, 2, 71),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                // iOS: circled right arrow — navigate to about/info
                GestureDetector(
                  onTap: () {
                      final storage = LocalStorage.instance;
                      context.push('/branch-dashboard', extra: {
                        'branchName': storage.clubName ?? '',
                        'clubName': storage.clubName ?? '',
                      });
                    },
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryBlue,
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Version text — outside the button bar
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 4),
            child: Text(
              'Version: $_appVersion',
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── SHARED CIRCLE AVATAR ─────────────────────────────────────

  Widget _buildCircleAvatar({
    String? imageUrl,
    required double radius,
  }) {
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.white,
      child: hasImage
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                placeholder: (context, url) => Icon(
                  Icons.person,
                  color: AppColors.primary,
                  size: radius * 1.2,
                ),
                errorWidget: (context, url, error) => Icon(
                  Icons.person,
                  color: AppColors.primary,
                  size: radius * 1.2,
                ),
              ),
            )
          : Icon(
              Icons.person,
              color: AppColors.primary,
              size: radius * 1.2,
            ),
    );
  }
}
