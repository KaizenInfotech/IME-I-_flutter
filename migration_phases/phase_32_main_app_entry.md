# Phase 32: Main App Entry + MultiProvider + Firebase

## Priority: 32
## Depends On: Phase 31

---

## Command Prompt

```
I am migrating an iOS app to Flutter.

Read the iOS AppDelegate for Firebase and push notification setup:
1. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/AppDelegate/AppDelegate.swift

Read the reference:
2. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/folder_details.md (Section 6: State Management Strategy)

Now create/update these files in /Users/ios2/Documents/Mani_mac_folder/touchbase_flutter/:

1. lib/main.dart
   - void main() async with:
     WidgetsFlutterBinding.ensureInitialized()
     await Firebase.initializeApp()
     ApiClient.instance.init()
     await LocalStorage.instance.init()
     await DatabaseHelper.instance.init()
     runApp(const App())
   - Error handling with FlutterError.onError
   - Import all necessary packages

2. lib/app.dart
   - MultiProvider wrapping MaterialApp.router with ALL 25 providers:
     ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider())
     ChangeNotifierProvider<DashboardProvider>(create: (_) => DashboardProvider())
     ChangeNotifierProvider<GroupProvider>(create: (_) => GroupProvider())
     ChangeNotifierProvider<ModuleProvider>(create: (_) => ModuleProvider())
     ChangeNotifierProvider<DirectoryProvider>(create: (_) => DirectoryProvider())
     ChangeNotifierProvider<EventsProvider>(create: (_) => EventsProvider())
     ChangeNotifierProvider<CelebrationsProvider>(create: (_) => CelebrationsProvider())
     ChangeNotifierProvider<AnnouncementsProvider>(create: (_) => AnnouncementsProvider())
     ChangeNotifierProvider<GalleryProvider>(create: (_) => GalleryProvider())
     ChangeNotifierProvider<DocumentsProvider>(create: (_) => DocumentsProvider())
     ChangeNotifierProvider<EbulletinProvider>(create: (_) => EbulletinProvider())
     ChangeNotifierProvider<AttendanceProvider>(create: (_) => AttendanceProvider())
     ChangeNotifierProvider<FindRotarianProvider>(create: (_) => FindRotarianProvider())
     ChangeNotifierProvider<FindClubProvider>(create: (_) => FindClubProvider())
     ChangeNotifierProvider<ServiceDirectoryProvider>(create: (_) => ServiceDirectoryProvider())
     ChangeNotifierProvider<SubgroupsProvider>(create: (_) => SubgroupsProvider())
     ChangeNotifierProvider<DistrictProvider>(create: (_) => DistrictProvider())
     ChangeNotifierProvider<LeaderboardProvider>(create: (_) => LeaderboardProvider())
     ChangeNotifierProvider<WebLinksProvider>(create: (_) => WebLinksProvider())
     ChangeNotifierProvider<NotificationsProvider>(create: (_) => NotificationsProvider())
     ChangeNotifierProvider<SettingsProvider>(create: (_) => SettingsProvider())
     ChangeNotifierProvider<ProfileProvider>(create: (_) => ProfileProvider())
     ChangeNotifierProvider<GroupsProvider>(create: (_) => GroupsProvider())
     ChangeNotifierProvider<MapProvider>(create: (_) => MapProvider())
     ChangeNotifierProvider<MonthlyReportProvider>(create: (_) => MonthlyReportProvider())
   - MaterialApp.router with GoRouter from app_router.dart
   - ThemeData from app_theme.dart
   - EasyLoading builder initialization
   - debugShowCheckedModeBanner: false
   - title: 'TouchBase'

3. Copy GoogleService-Info.plist from iOS project to Flutter:
   Copy /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/GoogleService-Info.plist
   to /Users/ios2/Documents/Mani_mac_folder/touchbase_flutter/ios/Runner/GoogleService-Info.plist

4. Update ios/Runner/Info.plist with required permissions:
   - Camera usage description
   - Photo library usage description
   - Location when in use description
   - Location always description (if needed)

STRICT RULES:
- ALL providers must be registered in MultiProvider
- EXACT same Firebase initialization as iOS AppDelegate
- App must compile and run without errors
- NO force unwraps
```

---

## iOS Source Files to Read
- `AppDelegate/AppDelegate.swift` (Firebase + push setup)
- `folder_details.md` (Section 6: State Management Strategy)

## Expected Output Files
- `lib/main.dart`
- `lib/app.dart`
- `ios/Runner/GoogleService-Info.plist` (copied)
- `ios/Runner/Info.plist` (updated with permissions)
