import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../navigation/app_router.dart';

/// Singleton service for showing local notification banners.
/// Mirrors Android MyFirebaseMessagingService.createNotification().
class LocalNotificationService {
  LocalNotificationService._();
  static final LocalNotificationService instance = LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Android channel matching IME(I) App channel configuration.
  static const String _channelId = 'IME(I)-iConnect';
  static const String _channelName = 'IME(I)-iConnect';
  static const String _channelDescription = 'IME(I)-iConnect push notifications';

  /// App name shown as notification title — matches Android R.string.app_name
  static const String _appName = 'IME(I)-iConnect';

  /// Set when a notification tap fires before the router is ready (iOS cold start).
  /// Checked in app.dart after the widget tree is built.
  static String? pendingNavigationRoute;

  bool _initialized = false;

  /// Initialize the local notifications plugin.
  /// Must be called once in main() before runApp().
  Future<void> init() async {
    if (_initialized) return;

    // Android initialization — use app icon (ic_launcher_big in drawable)
    // Matches IME(I) App: setSmallIcon(R.mipmap.ic_launcher_big)
    const androidSettings = AndroidInitializationSettings('ic_launcher_big');

    // iOS initialization — request permissions through plugin
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Android-specific setup
    final androidPlatform =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlatform != null) {
      // Create notification channel FIRST — this works in background isolate
      // and must exist before any notification can be shown (Android 8+).
      await androidPlatform.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDescription,
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );

      // Request Android 13+ (API 33) notification permission at runtime.
      // This needs an Activity context — will fail in background isolate
      // when app is killed. Wrap in try-catch so it doesn't block init.
      try {
        final granted = await androidPlatform.requestNotificationsPermission();
        debugPrint('Android notification permission granted: $granted');
      } catch (e) {
        debugPrint('Android notification permission request skipped (background isolate): $e');
      }
    }

    // Request iOS notification permissions explicitly
    final iosPlatform =
        _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (iosPlatform != null) {
      try {
        final granted = await iosPlatform.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        debugPrint('iOS local notification permission granted: $granted');
      } catch (e) {
        debugPrint('iOS notification permission request skipped: $e');
      }
    }

    _initialized = true;
    debugPrint('LocalNotificationService initialized');
  }

  /// Show a notification banner matching Android's createNotification().
  /// [payload] is the FCM data map serialized as JSON for tap handling.
  Future<void> showNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    if (!_initialized) {
      debugPrint('LocalNotificationService not initialized');
      return;
    }

    // Android notification details matching IME(I) App:
    // - Color: #00AEEF
    // - Priority: HIGH
    // - Vibration: [1000, 0, 1000, 0, 1000]
    // - BigTextStyle for long messages
    // - Auto cancel
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      color: const Color(0xFF00AEEF),
      vibrationPattern: Int64List.fromList([1000, 0, 1000, 0, 1000]),
      enableVibration: true,
      playSound: true,
      autoCancel: true,
      styleInformation: BigTextStyleInformation(body),
      icon: 'ic_launcher_big',
      largeIcon: const DrawableResourceAndroidBitmap('ic_launcher_big'),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Random notification ID (1-99) matching Android implementation
    final notificationId = Random().nextInt(99) + 1;

    // Encode data as JSON payload for tap handling
    String? payload;
    if (data != null) {
      try {
        payload = json.encode(data);
      } catch (_) {
        payload = null;
      }
    }

    try {
      // Android: setContentTitle(R.string.app_name) — always show app name as title
      await _plugin.show(
        notificationId,
        _appName,
        body,
        details,
        payload: payload,
      );
      debugPrint('Local notification shown: id=$notificationId, title=$_appName, body=$body');
    } catch (e) {
      debugPrint('Local notification show ERROR: $e');
    }
  }

  /// Handle notification tap — navigate to notifications screen.
  /// If the router isn't ready yet (iOS cold start from notification),
  /// save the route for app.dart to pick up after the widget tree builds.
  static void _onNotificationTap(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    try {
      AppRouter.router.push('/notifications');
    } catch (e) {
      // Router not ready (cold start) — save for app.dart to handle
      pendingNavigationRoute = '/notifications';
      debugPrint('Notification tap deferred (router not ready): $e');
    }
  }
}
