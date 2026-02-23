import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_loader.dart';
import '../../../core/widgets/common_toast.dart';
import '../providers/module_provider.dart';

/// Port of iOS CustumiseMyModuleViewController — drag-reorderable module list.
/// Fetches all group modules via Group/GetGroupModulesList,
/// allows user to reorder, then saves via Group/UpdateModuleDashboard.
class CustomizeModulesScreen extends StatefulWidget {
  const CustomizeModulesScreen({
    super.key,
    required this.groupId,
    required this.memberProfileId,
    required this.groupName,
  });

  final String groupId;
  final String memberProfileId;
  final String groupName;

  @override
  State<CustomizeModulesScreen> createState() => _CustomizeModulesScreenState();
}

class _CustomizeModulesScreenState extends State<CustomizeModulesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadModules());
  }

  Future<void> _loadModules() async {
    final moduleProvider = context.read<ModuleProvider>();
    CommonLoader.show(context);

    await moduleProvider.fetchModules(
      groupId: widget.groupId,
      memberProfileId: widget.memberProfileId,
    );

    if (!mounted) return;
    CommonLoader.dismiss(context);
  }

  /// iOS: Save reordered modules via Group/UpdateModuleDashboard
  Future<void> _saveOrder() async {
    final moduleProvider = context.read<ModuleProvider>();
    CommonLoader.show(context);

    final success = await moduleProvider.saveModuleOrder(
      memberProfileId: widget.memberProfileId,
    );

    if (!mounted) return;
    CommonLoader.dismiss(context);

    if (success) {
      CommonToast.success(context, 'Module order saved');
      Navigator.of(context).pop(true);
    } else {
      CommonToast.error(context, 'Failed to save module order');
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
          widget.groupName,
          style: const TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 17,
            fontWeight: FontWeight.w400,
            color: AppColors.textOnPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveOrder,
            child: const Text(
              'Save',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textOnPrimary,
              ),
            ),
          ),
        ],
      ),
      body: Consumer<ModuleProvider>(
        builder: (context, moduleProvider, child) {
          if (moduleProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (moduleProvider.error != null &&
              moduleProvider.customizedModules.isEmpty) {
            return Center(
              child: Text(
                moduleProvider.error!,
                style: AppTextStyles.body2,
              ),
            );
          }

          return ReorderableListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: moduleProvider.customizedModules.length,
            onReorder: moduleProvider.reorderModules,
            itemBuilder: (context, index) {
              final module = moduleProvider.customizedModules[index];
              return Card(
                key: ValueKey(module.moduleId ?? index.toString()),
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: ListTile(
                  leading: _buildModuleIcon(module.image),
                  title: Text(
                    module.moduleName ?? '',
                    style: AppTextStyles.body2,
                  ),
                  trailing: const Icon(
                    Icons.drag_handle,
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildModuleIcon(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          imageUrl,
          width: 36,
          height: 36,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => _placeholderIcon(),
        ),
      );
    }
    return _placeholderIcon();
  }

  Widget _placeholderIcon() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.backgroundGray,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Icon(Icons.grid_view, color: AppColors.primary, size: 20),
    );
  }
}
