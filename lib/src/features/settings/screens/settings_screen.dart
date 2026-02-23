import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../providers/settings_provider.dart';
import '../widgets/setting_toggle_tile.dart';

/// Port of iOS SettingsViewController.
/// Shows list of group/entity toggles from setting/GetTouchbaseSetting.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.mainMasterId,
  });

  final String mainMasterId;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<SettingsProvider>()
        .fetchSettings(mainMasterId: widget.mainMasterId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CommonAppBar(title: 'Settings'),
      body: Consumer<SettingsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final list = provider.settings;
          if (list.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.settings,
              message: provider.error ?? 'No settings available',
            );
          }

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, index) {
              final item = list[index];
              return SettingToggleTile(
                label: item.grpName ?? '',
                isEnabled: item.isEnabled,
                onChanged: (_) {
                  provider.updateSetting(
                    index: index,
                    mainMasterId: widget.mainMasterId,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
