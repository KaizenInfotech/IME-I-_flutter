# Phase 26: Notifications Feature

## Priority: 26
## Depends On: Phase 10

---

## Command Prompt

```
I am migrating an iOS app to Flutter.

Read these iOS source files CAREFULLY:
1. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/AllNotificationViewController.swift
2. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/NotificaionModel.swift
3. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/NotificationModel.swift
4. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/MainDashBoardWithSidebar/NotificationSetting/ (ALL files)
5. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/AppDelegate/AppDelegate.swift
   (Read push notification handling: didReceiveRemoteNotification, registration, token handling)

Now create in /Users/ios2/Documents/Mani_mac_folder/touchbase_flutter/:

MODELS:
1. lib/src/features/notifications/models/notification_model.dart
   - Merge both iOS NotificaionModel and NotificationModel into one clean model
   - All fields nullable
   - fromJson/toJson
   - Match the exact fields stored in iOS SQLite Notification_Table

PROVIDERS:
2. lib/src/features/notifications/providers/notifications_provider.dart
   - Local SQLite CRUD for notifications (using database_helper from core)
   - Push notification handling via firebase_messaging
   - Match EXACT same notification storage and display logic as iOS
   - State: notifications list, unreadCount, isLoading, error
   - Methods: fetchNotifications(), markAsRead(), deleteNotification(),
     clearAllNotifications(), handlePushNotification(), setupFirebaseMessaging()

SCREENS:
3. lib/src/features/notifications/screens/notifications_screen.dart
   - List of notifications from local SQLite DB
   - Swipe to delete, tap to navigate to relevant screen
   - Match iOS AllNotificationViewController layout

4. lib/src/features/notifications/screens/notification_settings_screen.dart
   - Push notification toggle settings
   - Match iOS NotificationSetting UI

WIDGETS:
5. lib/src/features/notifications/widgets/notification_tile.dart

STRICT RULES:
- EXACT same notification storage in SQLite as iOS
- EXACT same push notification handling logic as iOS AppDelegate
- EXACT same UI as iOS
- ALL nullable, NO force unwraps
- Provider + Consumer + FutureBuilder
```

---

## iOS Source Files to Read
- `TouchBase/AllNotificationViewController.swift`
- `TouchBase/NotificaionModel.swift`
- `TouchBase/NotificationModel.swift`
- `TouchBase/Controllers/MainDashBoardWithSidebar/NotificationSetting/` (ALL files)
- `AppDelegate/AppDelegate.swift` (push notification sections)

## Expected Output Files
- `lib/src/features/notifications/models/notification_model.dart`
- `lib/src/features/notifications/providers/notifications_provider.dart`
- `lib/src/features/notifications/screens/notifications_screen.dart`
- `lib/src/features/notifications/screens/notification_settings_screen.dart`
- `lib/src/features/notifications/widgets/notification_tile.dart`
