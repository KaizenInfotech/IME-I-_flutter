import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_toast.dart';
import '../models/admin_submodules_result.dart';

/// Port of iOS AdminModuleListingViewController — admin sub-modules grid.
/// Displays sub-modules fetched from Group/getAdminSubModules.
/// iOS: 3-column collection view, same layout as main dashboard.
class AdminModulesScreen extends StatelessWidget {
  const AdminModulesScreen({
    super.key,
    required this.adminModules,
    required this.groupId,
    required this.isCategory,
    required this.isAdmin,
    required this.profileId,
    this.moduleName,
  });

  final List<AdminSubmodule> adminModules;
  final String groupId;
  final String isCategory;
  final String isAdmin;
  final String profileId;
  final String? moduleName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textOnPrimary),
        title: Text(
          moduleName ?? 'Admin',
          style: const TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 17,
            fontWeight: FontWeight.w400,
            color: AppColors.textOnPrimary,
          ),
        ),
      ),
      body: adminModules.isEmpty
          ? const Center(
              child: Text(
                'No admin modules available',
                style: AppTextStyles.body2,
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                childAspectRatio: 1.0,
              ),
              itemCount: adminModules.length,
              itemBuilder: (context, index) {
                final module = adminModules[index];
                return _buildModuleCell(context, module);
              },
            ),
    );
  }

  Widget _buildModuleCell(BuildContext context, AdminSubmodule module) {
    return GestureDetector(
      onTap: () => _onModuleTap(context, module),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(module.image),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                module.moduleName ?? '',
                style: const TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onModuleTap(BuildContext context, AdminSubmodule module) {
    // Store session values like main dashboard
    if (module.groupId != null) {
      LocalStorage.instance
          .setString(AppConstants.keySessionGetGroupId, module.groupId!);
    }
    if (module.moduleId != null) {
      LocalStorage.instance
          .setString(AppConstants.keySessionGetModuleId, module.moduleId!);
    }

    // Admin sub-modules navigate to same screens as main modules
    // TODO: Implement navigation to specific feature screens
    CommonToast.info(
        context, '${module.moduleName ?? 'Module'} - Coming Soon');
  }

  Widget _buildIcon(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          width: 48,
          height: 48,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => _placeholderIcon(),
        ),
      );
    }
    return _placeholderIcon();
  }

  Widget _placeholderIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.backgroundGray,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.admin_panel_settings,
          color: AppColors.primary, size: 28),
    );
  }
}
