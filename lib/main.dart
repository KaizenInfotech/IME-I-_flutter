import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'src/core/network/api_client.dart';
import 'src/core/storage/database_helper.dart';
import 'src/core/storage/local_storage.dart';
import 'src/core/storage/secure_storage.dart';
import 'src/core/utils/local_notification_service.dart';
import 'src/features/notifications/providers/notifications_provider.dart';

/// Background handler for FCM messages.
/// Must be a top-level function (not a class method).
/// IMPORTANT: On Android this runs in a SEPARATE Dart isolate — Flutter
/// binding and all plugins must be initialized from scratch.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Critical: initialize Flutter binding FIRST — without this, all plugin
  // platform channel calls (sqflite, flutter_local_notifications, etc.)
  // fail silently on Android's background isolate. iOS runs on main isolate
  // so it works without this, but Android does NOT.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  debugPrint('FCM background message: ${message.messageId}');
  debugPrint('FCM background data: ${message.data}');
  debugPrint('FCM background notification: ${message.notification?.title} / ${message.notification?.body}');

  // Build payload from data fields (server push) or notification fields (Firebase Console test)
  Map<String, dynamic> payload = {};
  if (message.data.isNotEmpty) {
    payload = Map<String, dynamic>.from(message.data);
  }

  final notification = message.notification;
  if (notification != null) {
    payload['title'] ??= notification.title ?? '';
    payload['Message'] ??= notification.body ?? '';
    payload['type'] ??= 'PopupNoti';
  }

  payload['gcm.message_id'] ??=
      message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString();

  if (payload.isEmpty) return;

  // Extract and clean notification text
  final title = payload['title']?.toString() ??
      payload['eventTitle']?.toString() ??
      payload['entityName']?.toString() ??
      'TouchBase';
  final body = (payload['Message']?.toString() ??
          payload['eventDesc']?.toString() ??
          '')
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .trim();

  // Show notification banner — on Android the native MyFirebaseMessagingService
  // already shows notifications, so only show here for iOS to avoid duplicates.
  // On iOS the background handler runs in the MAIN isolate, so use the
  // LocalNotificationService singleton which has the tap callback registered
  // (navigates to /notifications). Using a standalone plugin instance would
  // override the tap callback and break tap-to-navigate.
  if (body.isNotEmpty && Platform.isIOS) {
    try {
      await LocalNotificationService.instance.init(); // no-op if already initialized
      await LocalNotificationService.instance.showNotification(
        title: title,
        body: body,
        data: payload,
      );
    } catch (e) {
      debugPrint('FCM background: show notification failed: $e');
    }
  }

  // Save notification to local DB (non-critical — don't let DB failure block)
  try {
    await DatabaseHelper.instance.init();
    final provider = NotificationsProvider();
    await provider.handlePushNotification(payload);
  } catch (e) {
    debugPrint('FCM background: DB save failed (non-fatal): $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize singletons FIRST — needed before FCM token can be saved to LocalStorage.
  ApiClient.instance.init();
  await LocalStorage.instance.init();
  await DatabaseHelper.instance.init();

  // iOS AppDelegate: Firebase configuration
  // Note: Firebase is used for push notifications & analytics only.
  // The app works without it — core features use the REST API.
  try {
    await Firebase.initializeApp();

    // Android: Register background message handler
    FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler);

    // Explicitly enable FCM auto-init
    final messaging = FirebaseMessaging.instance;
    await messaging.setAutoInitEnabled(true);

    // iOS AppDelegate: didRegisterForRemoteNotificationsWithDeviceToken
    // Request notification permissions and get FCM token for login API.
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,  
    );

    // iOS: show notification banners even when app is in foreground
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // On iOS, FCM needs the APNs token before it can generate an FCM token.
    // In debug (sandbox) this is fast, but in TestFlight/production it can be
    // delayed. Wait for the APNs token to be available first.
    if (Platform.isIOS) {
      String? apnsToken = await messaging.getAPNSToken();
      if (apnsToken == null) {
        // APNs token not yet available — wait briefly and retry
        await Future.delayed(const Duration(seconds: 2));
        apnsToken = await messaging.getAPNSToken();
      }
      debugPrint('APNs Token: $apnsToken');
    }

    final fcmToken = await messaging.getToken();
    if (fcmToken != null) {
      // Save to BOTH SecureStorage (for login API) and LocalStorage
      // (for dashboard's Group/UpdateDeviceTokenNumber API).
      await SecureStorage.instance.saveDeviceToken(fcmToken);
      await LocalStorage.instance.setDeviceToken(fcmToken);
      debugPrint('FCM Token: $fcmToken');
    }

    // Listen for token refresh — save to both stores so all API calls use current token
    messaging.onTokenRefresh.listen((newToken) async {
      await SecureStorage.instance.saveDeviceToken(newToken);
      await LocalStorage.instance.setDeviceToken(newToken);
      debugPrint('FCM Token refreshed: $newToken');
    });
  } catch (e) {
    debugPrint('Firebase init failed (non-fatal): $e');
  }

  // Initialize local notification service (Android: createNotification channel)
  await LocalNotificationService.instance.init();

  // Global error handler — mirrors iOS uncaught exception tracking
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exception}');
  };

  runApp(const App());
}
