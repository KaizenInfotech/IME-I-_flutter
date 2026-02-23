import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_toast.dart';
import '../providers/group_provider.dart';
import '../widgets/sidebar_menu.dart';

/// Port of iOS MainDashboardWithSideBarViewController — drawer sidebar.
/// iOS sidebar buttons: About Developer, Privacy, Notifications, FAQ, Help Desk.
/// iOS RotaryMenuViewController: My Club, Settings, Features, FAQ, JITO Helpline, About Developer.
class SidebarScreen extends StatelessWidget {
  const SidebarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final groupProvider = context.watch<GroupProvider>();
    final profileImg = LocalStorage.instance.getString('profile_image');
    final userName = LocalStorage.instance.fullName;

    return Drawer(
      child: SidebarMenu(
        profileImageUrl: profileImg,
        userName: userName,
        onEditProfile: () {
          Navigator.of(context).pop(); // Close drawer
          // TODO: Navigate to edit profile screen
          CommonToast.info(context, 'Edit Profile - Coming Soon');
        },
        onItemTap: (item) => _onMenuItemTap(context, item, groupProvider),
      ),
    );
  }

  void _onMenuItemTap(
    BuildContext context,
    SidebarMenuItem item,
    GroupProvider groupProvider,
  ) {
    Navigator.of(context).pop(); // Close drawer

    switch (item.id) {
      case 'my_club':
        // iOS: Navigate to group selection
        // TODO: Navigate to ModuleClubInfoViewController equivalent
        CommonToast.info(context, 'My Club - Coming Soon');

      case 'settings':
        // iOS: Navigate to ModuleSettingViewController
        // TODO: Navigate to SettingsScreen
        CommonToast.info(context, 'Settings - Coming Soon');

      case 'features':
        // iOS: Navigate to features list
        // TODO: Navigate to FeaturesScreen
        CommonToast.info(context, 'Features - Coming Soon');

      case 'faq':
        // iOS: Navigate to FAQ
        // TODO: Navigate to FAQScreen
        CommonToast.info(context, 'FAQ - Coming Soon');

      case 'helpline':
        // iOS: JITO Helpline
        // TODO: Navigate to HelplineScreen
        CommonToast.info(context, 'Helpline - Coming Soon');

      case 'about_developer':
        // iOS: Calls Group/GetEntityInfo with moduleID:"101", grpID:"11111"
        _fetchAboutDeveloper(context);
    }
  }

  /// iOS: MainDashboardWithSideBarViewController calls
  /// getEntityInfoList("11111", moduleID: "101") for About Developer.
  void _fetchAboutDeveloper(BuildContext context) async {
    try {
      final response = await ApiClient.instance.post(
        ApiConstants.groupGetEntityInfo,
        body: {
          'grpID': '11111',
          'moduleID': '101',
        },
      );

      if (response.statusCode == 200) {
        final data = _parseResponseBody(response.body);
        if (data != null) {
          final status = data['status']?.toString();
          if (status == '0') {
            if (!context.mounted) return;
            _showAboutDeveloper(context, data);
            return;
          }
        }
      }

      if (!context.mounted) return;
      CommonToast.error(context, 'Failed to load about info');
    } catch (e) {
      debugPrint('SidebarScreen.fetchAboutDeveloper error: $e');
      if (!context.mounted) return;
      CommonToast.error(context, 'Network error');
    }
  }

  void _showAboutDeveloper(BuildContext context, Map<String, dynamic> data) {
    final groupName = data['groupName']?.toString() ?? '';
    final entityInfoList = data['EntityInfoResult'] as List<dynamic>?;
    String description = '';
    if (entityInfoList != null && entityInfoList.isNotEmpty) {
      final first = entityInfoList.first;
      if (first is Map<String, dynamic>) {
        description = first['descptn']?.toString() ?? '';
      }
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          groupName,
          style: const TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            description,
            style: AppTextStyles.body2,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic>? _parseResponseBody(String body) {
    try {
      final decoded = json.decode(body);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    return null;
  }
}
