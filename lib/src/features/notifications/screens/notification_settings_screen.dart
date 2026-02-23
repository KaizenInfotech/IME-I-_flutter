import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../providers/notifications_provider.dart';

/// Port of iOS SideBarNotificationViewController.
/// Shows notification toggle switches per module matching iOS layout.
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({
    super.key,
    required this.groupId,
    required this.groupProfileId,
    this.moduleName = 'Notification Settings',
  });

  final String groupId;
  final String groupProfileId;
  final String moduleName;

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _settingsChanged = false;

  @override
  void initState() {
    super.initState();
    context.read<NotificationsProvider>().fetchSettings(
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
        body: Consumer<NotificationsProvider>(
          builder: (context, provider, _) {
            if (provider.isLoadingSettings) {
              return const Center(child: CircularProgressIndicator());
            }

            final list = provider.settings;
            if (list.isEmpty) {
              return const Center(
                child: Text('No settings available'),
              );
            }

            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (_, index) {
                final item = list[index];
                return Container(
                  color: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                          color: AppColors.divider, width: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.modName ?? '',
                          style: AppTextStyles.body2.copyWith(
                            color: item.isEnabled
                                ? AppColors.textPrimary
                                : AppColors.grayMedium,
                          ),
                        ),
                      ),
                      Switch(
                        value: item.isEnabled,
                        activeTrackColor: AppColors.primary,
                        onChanged: (val) {
                          provider.toggleSetting(
                            index: index,
                            groupId: widget.groupId,
                            groupProfileId: widget.groupProfileId,
                          );
                          _settingsChanged = true;
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
