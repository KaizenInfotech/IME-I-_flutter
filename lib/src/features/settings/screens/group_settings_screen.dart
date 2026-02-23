import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../providers/settings_provider.dart';
import '../widgets/setting_toggle_tile.dart';

/// Port of iOS GroupSettingsController.
/// Shows module-level toggle switches from setting/GetGroupSetting.
class GroupSettingsScreen extends StatefulWidget {
  const GroupSettingsScreen({
    super.key,
    required this.groupId,
    required this.groupProfileId,
    this.moduleName = 'Group Settings',
  });

  final String groupId;
  final String groupProfileId;
  final String moduleName;

  @override
  State<GroupSettingsScreen> createState() => _GroupSettingsScreenState();
}

class _GroupSettingsScreenState extends State<GroupSettingsScreen> {
  bool _settingsChanged = false;

  @override
  void initState() {
    super.initState();
    context.read<SettingsProvider>().fetchGroupSettings(
          groupId: widget.groupId,
          groupProfileId: widget.groupProfileId,
        );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop && _settingsChanged) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Updated successfully.')),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: CommonAppBar(title: widget.moduleName),
        body: Consumer<SettingsProvider>(
          builder: (context, provider, _) {
            if (provider.isLoadingGroup) {
              return const Center(child: CircularProgressIndicator());
            }

            final list = provider.groupSettings;
            if (list.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.settings,
                message: 'No settings available',
              );
            }

            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (_, index) {
                final item = list[index];
                return SettingToggleTile(
                  label: item.modName ?? '',
                  isEnabled: item.isEnabled,
                  onChanged: (_) {
                    provider.updateGroupSetting(
                      index: index,
                      groupId: widget.groupId,
                      groupProfileId: widget.groupProfileId,
                    );
                    _settingsChanged = true;
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
