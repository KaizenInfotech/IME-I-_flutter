import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

import 'src/core/navigation/app_router.dart';
import 'src/core/theme/app_theme.dart';
import 'src/core/utils/local_notification_service.dart';

// ─── Providers ─────────────────────────────────────────────────────
import 'src/features/announcements/providers/announcements_provider.dart';
import 'src/features/attendance/providers/attendance_provider.dart';
import 'src/features/auth/providers/auth_provider.dart';
import 'src/features/celebrations/providers/celebrations_provider.dart';
import 'src/features/dashboard/providers/dashboard_provider.dart';
import 'src/features/dashboard/providers/group_provider.dart';
import 'src/features/dashboard/providers/module_provider.dart';
import 'src/features/directory/providers/directory_provider.dart';
import 'src/features/district/providers/district_provider.dart';
import 'src/features/documents/providers/documents_provider.dart';
import 'src/features/ebulletin/providers/ebulletin_provider.dart';
import 'src/features/events/providers/events_provider.dart';
import 'src/features/find_club/providers/find_club_provider.dart';
import 'src/features/find_rotarian/providers/find_rotarian_provider.dart';
import 'src/features/gallery/providers/gallery_provider.dart';
import 'src/features/groups/providers/groups_provider.dart';
import 'src/features/leaderboard/providers/leaderboard_provider.dart';
import 'src/features/maps/providers/map_provider.dart';
import 'src/features/monthly_report/providers/monthly_report_provider.dart';
import 'src/features/notifications/providers/notifications_provider.dart';
import 'src/features/profile/providers/profile_provider.dart';
import 'src/features/service_directory/providers/service_directory_provider.dart';
import 'src/features/settings/providers/settings_provider.dart';
import 'src/features/subgroups/providers/subgroups_provider.dart';
import 'src/features/branch_chapter/providers/branch_chapter_provider.dart';
import 'src/features/governing_council/providers/governing_council_provider.dart';
import 'src/features/mer/providers/mer_provider.dart';
import 'src/features/sub_committee/providers/sub_committee_provider.dart';
import 'src/features/web_links/providers/web_links_provider.dart';

/// Root widget — mirrors iOS AppDelegate + Main.storyboard setup.
/// Wraps MaterialApp.router with all ChangeNotifierProviders.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => GroupProvider()),
        ChangeNotifierProvider(create: (_) => ModuleProvider()),
        ChangeNotifierProvider(create: (_) => DirectoryProvider()),
        ChangeNotifierProvider(create: (_) => EventsProvider()),
        ChangeNotifierProvider(create: (_) => CelebrationsProvider()),
        ChangeNotifierProvider(create: (_) => AnnouncementsProvider()),
        ChangeNotifierProvider(create: (_) => GalleryProvider()),
        ChangeNotifierProvider(create: (_) => DocumentsProvider()),
        ChangeNotifierProvider(create: (_) => EbulletinProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => FindRotarianProvider()),
        ChangeNotifierProvider(create: (_) => FindClubProvider()),
        ChangeNotifierProvider(create: (_) => ServiceDirectoryProvider()),
        ChangeNotifierProvider(create: (_) => SubgroupsProvider()),
        ChangeNotifierProvider(create: (_) => DistrictProvider()),
        ChangeNotifierProvider(create: (_) => LeaderboardProvider()),
        ChangeNotifierProvider(create: (_) => WebLinksProvider()),
        ChangeNotifierProvider(create: (_) => NotificationsProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => GroupsProvider()),
        ChangeNotifierProvider(create: (_) => MapProvider()),
        ChangeNotifierProvider(create: (_) => MonthlyReportProvider()),
        ChangeNotifierProvider(create: (_) => BranchChapterProvider()),
        ChangeNotifierProvider(create: (_) => GoverningCouncilProvider()),
        ChangeNotifierProvider(create: (_) => SubCommitteeProvider()),
        ChangeNotifierProvider(create: (_) => MerProvider()),
      ],
      // _FCMListenerWrapper sits BELOW MultiProvider so it can access providers
      child: const _FCMListenerWrapper(),
    );
  }
}

/// Inner StatefulWidget that registers FCM foreground/tap message handlers.
/// Placed below MultiProvider so provider context access works.
class _FCMListenerWrapper extends StatefulWidget {
  const _FCMListenerWrapper();

  @override
  State<_FCMListenerWrapper> createState() => _FCMListenerWrapperState();
}

class _FCMListenerWrapperState extends State<_FCMListenerWrapper> {
  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _onMessageOpenedSub;

  @override
  void initState() {
    super.initState();
    _setupFCMListeners();
  }

  @override
  void dispose() {
    _onMessageSub?.cancel();
    _onMessageOpenedSub?.cancel();
    super.dispose();
  }

  /// Android: MyFirebaseMessagingService.onMessageReceived (foreground)
  /// + notification tap when app is in background.
  void _setupFCMListeners() {
    try {
      // Foreground messages — show banner, save to local DB and refresh UI
      _onMessageSub =
          FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('FCM foreground message: ${message.messageId}');
        debugPrint('FCM data: ${message.data}');
        debugPrint(
            'FCM notification: title=${message.notification?.title}, body=${message.notification?.body}');

        // Build payload from data fields (server push) or notification fields (Firebase Console test)
        Map<String, dynamic> payload = {};
        if (message.data.isNotEmpty) {
          payload = Map<String, dynamic>.from(message.data);
        }

        // If data payload is missing title/type, fill from notification field
        // (Firebase Console sends via notification, not data)
        final notification = message.notification;
        if (notification != null) {
          payload['title'] ??= notification.title ?? '';
          payload['Message'] ??= notification.body ?? '';
          payload['type'] ??= 'PopupNoti';
        }

        // Ensure we have a message ID
        payload['gcm.message_id'] ??= message.messageId ??
            DateTime.now().millisecondsSinceEpoch.toString();

        if (payload.isNotEmpty) {
          // Show local notification banner (Android: createNotification)
          final notiTitle = payload['title']?.toString() ??
              payload['eventTitle']?.toString() ??
              payload['entityName']?.toString() ??
              'TouchBase';
          final notiBody = payload['Message']?.toString() ??
              payload['eventDesc']?.toString() ??
              '';
          if (notiBody.isNotEmpty) {
            LocalNotificationService.instance.showNotification(
              title: notiTitle,
              body: notiBody,
              data: payload,
            );
          }

          // Save to local DB and refresh UI + badge count
          // Called directly (not deferred) so Consumer3 on dashboard rebuilds immediately
          if (mounted) {
            debugPrint('FCM: Saving notification to local DB...');
            context
                .read<NotificationsProvider>()
                .handlePushNotification(payload)
                .then((_) => debugPrint('FCM: Notification saved to DB'))
                .catchError(
                    (e) => debugPrint('FCM: DB save error: $e'));
          }
        }
      });

      // Background tap — when user taps notification from system tray
      _onMessageOpenedSub = FirebaseMessaging.onMessageOpenedApp
          .listen((RemoteMessage message) {
        debugPrint('FCM onMessageOpenedApp: ${message.messageId}');
        // Navigate to notifications screen when user taps a push notification
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AppRouter.router.push('/notifications');
        });
      });

      // Check if app was opened from a terminated state via notification
      FirebaseMessaging.instance
          .getInitialMessage()
          .then((RemoteMessage? message) {
        if (message != null) {
          debugPrint('FCM getInitialMessage: ${message.messageId}');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            AppRouter.router.push('/notifications');
          });
        }
      });
    } catch (e) {
      debugPrint('FCM listener setup failed (non-fatal): $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TouchBase',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: AppRouter.router,
      builder: EasyLoading.init(),
    );
  }
}
