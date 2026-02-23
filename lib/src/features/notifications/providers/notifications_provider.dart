import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/database_helper.dart';
import '../models/notification_model.dart';

class NotificationsProvider extends ChangeNotifier {
  // ─── State ──────────────────────────────────────────────
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<NotificationItem> _notifications = [];
  List<NotificationItem> get notifications => _notifications;

  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  // Notification settings state
  bool _isLoadingSettings = false;
  bool get isLoadingSettings => _isLoadingSettings;

  List<NotificationSettingItem> _settings = [];
  List<NotificationSettingItem> get settings => _settings;

  String _isMobileSelf = '';
  String _isMobileOther = '';
  String _isEmailSelf = '';
  String _isEmailOther = '';

  // ─── Fetch Notifications from Local DB ──────────────────
  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final rows = await DatabaseHelper.instance.getAllNotifications();
      if (rows != null) {
        _notifications = rows.map((r) => NotificationItem.fromMap(r)).toList();
      } else {
        _notifications = [];
      }

      final count = await DatabaseHelper.instance.getUnreadNotificationCount();
      _unreadCount = count ?? 0;
    } catch (e) {
      debugPrint('fetchNotifications error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Refresh unread count only.
  Future<void> refreshUnreadCount() async {
    final count = await DatabaseHelper.instance.getUnreadNotificationCount();
    _unreadCount = count ?? 0;
    notifyListeners();
  }

  // ─── Mark as Read ───────────────────────────────────────
  Future<void> markAsRead(String msgId) async {
    await DatabaseHelper.instance.markNotificationAsRead(msgId);
    final index = _notifications.indexWhere((n) => n.msgId == msgId);
    if (index >= 0) {
      final old = _notifications[index];
      _notifications[index] = NotificationItem(
        msgId: old.msgId,
        title: old.title,
        details: old.details,
        type: old.type,
        clubDistrictType: old.clubDistrictType,
        notifyDate: old.notifyDate,
        expiryDate: old.expiryDate,
        sortDate: old.sortDate,
        readStatus: 'Read',
      );
      _unreadCount = _notifications.where((n) => n.isUnread).length;
      notifyListeners();
    }
  }

  // ─── Delete Single Notification ─────────────────────────
  Future<void> deleteNotification(String msgId) async {
    await DatabaseHelper.instance.deleteNotificationByMsgId(msgId);
    _notifications.removeWhere((n) => n.msgId == msgId);
    _unreadCount = _notifications.where((n) => n.isUnread).length;
    notifyListeners();
  }

  // ─── Clear All Notifications ────────────────────────────
  Future<void> clearAllNotifications() async {
    await DatabaseHelper.instance.deleteAllNotifications();
    _notifications = [];
    _unreadCount = 0;
    notifyListeners();
  }

  // ─── Delete Expired (older than 2 days) ─────────────────
  Future<void> deleteExpiredNotifications() async {
    await DatabaseHelper.instance.deleteExpiredNotifications();
    await fetchNotifications();
  }

  // ─── Handle Push Notification ───────────────────────────
  /// Save an incoming push notification to local DB.
  /// Matches Android MyFirebaseMessagingService.inserNotificationInDB.
  Future<void> handlePushNotification(Map<String, dynamic> data) async {
    final db = DatabaseHelper.instance;

    // Android: delete expired notifications first
    await db.deleteExpiredNotifications();

    // Android: limit to 100 records — delete oldest 2 when exceeded
    final totalCount = await db.getTotalNotificationCount() ?? 0;
    if (totalCount >= 100) {
      await db.deleteOldestNotifications(count: 2);
    }

    final now = DateTime.now();
    final df = DateFormat('dd MMM yyyy hh:mm a');
    final notificationDate = df.format(now);

    // Android: setCurrentAndExpiredDate — 3 day expiry
    final expiry = now.add(const Duration(days: 3));
    final dfExpiry = DateFormat('dd/MM/yyyy');
    final expirationDate = dfExpiry.format(expiry);

    final type = data['type']?.toString() ?? '';
    // Backend sends title as 'title', 'eventTitle', or 'entityName' depending on type
    final title = data['title']?.toString() ??
        data['eventTitle']?.toString() ??
        data['entityName']?.toString() ??
        '';
    final msgId = data['gcm.message_id']?.toString() ??
        data['google.message_id']?.toString() ??
        DateTime.now().millisecondsSinceEpoch.toString();

    // Store entire payload as JSON string
    String detailsJson;
    try {
      detailsJson = json.encode(data);
    } catch (_) {
      detailsJson = '';
    }

    // Sanitize single quotes
    final cleanTitle = title.replaceAll("'", '');
    final cleanDetails = detailsJson.replaceAll("'", '');

    final notification = NotificationItem(
      msgId: msgId,
      title: cleanTitle,
      details: cleanDetails,
      type: type,
      clubDistrictType: '',
      notifyDate: notificationDate,
      expiryDate: expirationDate,
      sortDate: now.toIso8601String(),
      readStatus: 'UnRead',
    );

    await db.insertNotification(notification.toMap());
    await fetchNotifications();
  }

  // ─── Notification Settings ──────────────────────────────
  Future<void> fetchSettings({
    required String groupId,
    required String groupProfileId,
  }) async {
    _isLoadingSettings = true;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.settingGetGroupSetting,
        body: {
          'GroupId': groupId,
          'GroupProfileId': groupProfileId,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = TBGroupSettingResult.fromJson(jsonData);

        if (result.status == '0') {
          _settings = result.settings ?? [];
          _isMobileSelf = result.isMobileSelf ?? '';
          _isMobileOther = result.isMobileOther ?? '';
          _isEmailSelf = result.isEmailSelf ?? '';
          _isEmailOther = result.isEmailOther ?? '';
        }
      }
    } catch (e) {
      debugPrint('fetchSettings error: $e');
    }

    _isLoadingSettings = false;
    notifyListeners();
  }

  Future<void> toggleSetting({
    required int index,
    required String groupId,
    required String groupProfileId,
  }) async {
    if (index < 0 || index >= _settings.length) return;

    final item = _settings[index];
    final newVal = item.isEnabled ? '0' : '1';
    item.modVal = newVal;
    notifyListeners();

    try {
      await ApiClient.instance.post(
        ApiConstants.settingGroupSetting,
        body: {
          'GroupId': groupId,
          'ModuleId': item.moduleId ?? '',
          'GroupProfileId': groupProfileId,
          'UpdatedValue': newVal,
          'showMobileSeflfClub': _isMobileSelf,
          'showMobileOutsideClub': _isMobileOther,
          'showEmailSeflfClub': _isEmailSelf,
          'showEmailOutsideClub': _isEmailOther,
        },
      );
    } catch (e) {
      debugPrint('toggleSetting error: $e');
    }
  }
}
