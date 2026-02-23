import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../announcements/models/announcement_list_result.dart';
import '../models/notification_model.dart';
import '../providers/notifications_provider.dart';
import '../widgets/notification_tile.dart';

/// Port of iOS AllNotificationViewController.
/// Shows list of notifications from local SQLite DB with swipe-to-delete.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationsProvider>().fetchNotifications();
  }

  /// Android: ShowNotificationAdapter.onBindViewHolder click handler.
  /// Routes to the appropriate screen based on notification type.
  void _onNotificationTap(NotificationItem item) {
    final provider = context.read<NotificationsProvider>();

    // Android: databaseHelpers.updateData(messageId) — mark as read
    if (item.msgId != null && item.isUnread) {
      provider.markAsRead(item.msgId!);
    }

    final details = item.detailsJson;
    if (details == null) return;

    final type = item.type ?? details['type'] as String? ?? '';

    switch (type) {
      // Android: UpcomingEventDetails.class
      // Shows event data directly from notification payload (no API call)
      case 'Event':
        context.push('/notifications/event-detail', extra: {
          'eventTitle':
              details['eventTitle']?.toString() ?? item.title ?? '',
          'eventDate': details['eventDate']?.toString() ?? '',
          'eventDesc': details['eventDesc']?.toString() ?? '',
          'eventImg': details['eventImg']?.toString() ?? '',
          'regLink': details['reglink']?.toString() ?? '',
          'venue': details['venue']?.toString() ?? '',
        });
        break;

      // Android: AnnouncementsDetailActivity.class
      // Keys: ann_title, Ann_date, ann_desc, ann_lnk, ann_img
      case 'ann':
        final announcement = AnnounceList(
          announTitle: details['ann_title']?.toString() ??
              details['Message']?.toString() ??
              item.title ??
              '',
          publishDateTime: details['Ann_date']?.toString() ?? '',
          announceDEsc: details['ann_desc']?.toString() ?? '',
          link: details['ann_lnk']?.toString() ?? '',
          announImg: details['ann_img']?.toString() ?? '',
        );
        context.push('/announcements/detail', extra: {
          'announcement': announcement,
        });
        break;

      // Android: CalendarActivity.class — celebrations
      // Keys: grpID, CelebrationType, Todays, GroupType
      case 'Calender':
        context.push('/celebrations', extra: {
          'groupId': details['grpID']?.toString() ?? '',
          'profileId': details['memID']?.toString() ?? '',
        });
        break;

      // Android: EventActivity.class — gallery/activity with album data
      // Keys: typeID (album ID), grpID, Message (event title)
      case 'Activity':
        final albumId = details['typeID']?.toString() ?? '';
        final groupId = details['grpID']?.toString() ?? '';
        final eventTitle = details['Message']?.toString() ?? item.title ?? '';
        if (albumId.isNotEmpty) {
          context.push('/gallery/album/$albumId', extra: {
            'albumTitle': eventTitle,
            'groupId': groupId,
          });
        } else {
          context.push('/gallery', extra: {
            'groupId': groupId,
          });
        }
        break;

      // Android: Gallery for district — currently commented out in Android
      case 'Gallery':
        context.push('/gallery', extra: {
          'groupId': details['grpID']?.toString() ?? '',
        });
        break;

      // Android: DocumentsBrChAdapter — documents
      // Keys: grpID, memID, typeID, isAdmin
      case 'Doc':
        context.push('/documents', extra: {
          'groupId': details['grpID']?.toString() ?? '',
          'profileId': details['memID']?.toString() ?? '',
        });
        break;

      // Android: Sets module preference for E-Newsletters
      // Keys: grpID, memID, Message
      case 'Ebulle':
      case 'Ebulletin':
        context.push('/ebulletin', extra: {
          'groupId': details['grpID']?.toString() ?? '',
          'profileId': details['memID']?.toString() ?? '',
        });
        break;

      // Android: DashboardActivity with greeting popup
      // Keys: title, Message, BAType (1=birthday, 2=anniversary)
      case 'PopupNoti':
        final popupTitle = details['title']?.toString() ??
            item.title ??
            '';
        final message = (details['Message'] as String? ?? '')
            .replaceAll('. ', '.\n\n')
            .replaceAll('<br />', '\n')
            .replaceAll('<br>', '')
            .replaceAll('<p>', '')
            .replaceAll('</p>', '');

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(popupTitle),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        break;

      // Android: SplashScreenActivity — member removal, force re-login
      case 'RemoveMember':
        context.go('/splash');
        break;

      default:
        debugPrint('Unhandled notification type: $type');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CommonAppBar(
        title: 'Notification',
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.delete_sweep, color: AppColors.textPrimary),
          //   onPressed: () => _confirmClearAll(),
          // ),
        ],
      ),
      body: Consumer<NotificationsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final list = provider.notifications;
          if (list.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.notifications_off,
              message: 'No notifications',
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchNotifications(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: list.length,
              itemBuilder: (_, index) {
                final item = list[index];
                return NotificationTile(
                  item: item,
                  onTap: () => _onNotificationTap(item),
                  onDismissed: () {
                    if (item.msgId != null) {
                      provider.deleteNotification(item.msgId!);
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _confirmClearAll() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear All'),
        content:
            const Text('Are you sure you want to clear all notifications?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<NotificationsProvider>().clearAllNotifications();
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
