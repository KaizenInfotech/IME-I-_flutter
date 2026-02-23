import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/storage/local_storage.dart';

/// Port of iOS RotaryMenuViewController — sidebar drawer menu content.
/// iOS menu items: My Club, Settings, Features, FAQ, JITO Helpline, About Developer.
/// iOS menu images: rt_home, rt_settings, rt_feature, rt_faq, rt_helpline, rt_about.
class SidebarMenu extends StatelessWidget {
  const SidebarMenu({
    super.key,
    this.onItemTap,
    this.profileImageUrl,
    this.userName,
    this.onEditProfile,
  });

  final void Function(SidebarMenuItem item)? onItemTap;
  final String? profileImageUrl;
  final String? userName;
  final VoidCallback? onEditProfile;

  /// iOS: menuTitles array from RotaryMenuViewController
  static const List<SidebarMenuItem> menuItems = [
    SidebarMenuItem(
      title: 'My Club',
      icon: Icons.home,
      id: 'my_club',
    ),
    SidebarMenuItem(
      title: 'Settings',
      icon: Icons.settings,
      id: 'settings',
    ),
    SidebarMenuItem(
      title: 'Features',
      icon: Icons.star,
      id: 'features',
    ),
    SidebarMenuItem(
      title: 'FAQ',
      icon: Icons.help_outline,
      id: 'faq',
    ),
    SidebarMenuItem(
      title: 'Helpline',
      icon: Icons.phone_in_talk,
      id: 'helpline',
    ),
    SidebarMenuItem(
      title: 'About Developer',
      icon: Icons.info_outline,
      id: 'about_developer',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // iOS: Profile header with image, username, edit button
        _buildProfileHeader(context),
        const Divider(height: 1, color: AppColors.divider),
        // iOS: TableView menu items
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: menuItems.length,
            separatorBuilder: (_, index) =>
                const Divider(height: 1, color: AppColors.divider),
            itemBuilder: (context, index) {
              final item = menuItems[index];
              return ListTile(
                leading: Icon(item.icon, color: AppColors.primary, size: 24),
                title: Text(
                  item.title,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onTap: () => onItemTap?.call(item),
              );
            },
          ),
        ),
        // iOS: Version label from MainDashboardWithSideBarViewController
        _buildVersionFooter(),
      ],
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final displayName =
        userName ?? LocalStorage.instance.fullName;

    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile image
          CircleAvatar(
            radius: 35,
            backgroundColor: AppColors.white,
            backgroundImage: profileImageUrl != null &&
                    profileImageUrl!.isNotEmpty
                ? NetworkImage(profileImageUrl!)
                : null,
            child: profileImageUrl == null || profileImageUrl!.isEmpty
                ? const Icon(Icons.person, size: 35, color: AppColors.primary)
                : null,
          ),
          const SizedBox(height: 12),
          // User name
          Text(
            displayName,
            style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textOnPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          // Edit profile button
          GestureDetector(
            onTap: onEditProfile,
            child: const Text(
              'Edit Profile',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.textOnPrimary,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.textOnPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        'Version ${LocalStorage.instance.getString('version_number') ?? '1.0'}',
        style: const TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

/// Sidebar menu item model.
class SidebarMenuItem {
  final String title;
  final IconData icon;
  final String id;

  const SidebarMenuItem({
    required this.title,
    required this.icon,
    required this.id,
  });
}
