# Phase 1: Flutter Project Creation & pubspec.yaml

## Priority: 1 (START HERE)
## Depends On: Nothing

---

## Command Prompt

```
Create a new Flutter project named "touchbase_flutter" in /Users/ios2/Documents/Mani_mac_folder/ with org "com.imeiconnect".

After creating, set up pubspec.yaml with ALL these dependencies:

dependencies:
  http, provider, go_router, shared_preferences, flutter_secure_storage,
  sqflite, path, path_provider, connectivity_plus, cached_network_image,
  firebase_core, firebase_analytics, firebase_messaging, google_maps_flutter,
  image_picker, share_plus, url_launcher, webview_flutter, photo_view,
  carousel_slider, table_calendar, fl_chart, percent_indicator, fluttertoast,
  flutter_easyloading, intl, json_annotation, permission_handler,
  flutter_pdfview, pdf, archive, device_calendar

dev_dependencies:
  json_serializable, build_runner

Then create the full folder scaffold (empty folders only, no files yet):
lib/
├── main.dart
├── app.dart
└── src/
    ├── core/
    │   ├── constants/
    │   ├── network/
    │   ├── storage/
    │   ├── models/
    │   ├── extensions/
    │   ├── utils/
    │   ├── theme/
    │   └── widgets/
    └── features/
        ├── auth/
        │   ├── models/
        │   ├── providers/
        │   ├── screens/
        │   └── widgets/
        ├── dashboard/
        │   ├── models/
        │   ├── providers/
        │   ├── screens/
        │   └── widgets/
        ├── directory/
        │   ├── models/
        │   ├── providers/
        │   ├── screens/
        │   └── widgets/
        ├── events/
        │   ├── models/
        │   ├── providers/
        │   ├── screens/
        │   └── widgets/
        ├── celebrations/
        │   ├── models/
        │   ├── providers/
        │   ├── screens/
        │   └── widgets/
        ├── announcements/
        │   ├── models/
        │   ├── providers/
        │   ├── screens/
        │   └── widgets/
        ├── gallery/
        │   ├── models/
        │   ├── providers/
        │   ├── screens/
        │   └── widgets/
        ├── documents/
        │   ├── models/
        │   ├── providers/
        │   ├── screens/
        │   └── widgets/
        ├── ebulletin/
        │   ├── models/
        │   ├── providers/
        │   ├── screens/
        │   └── widgets/
        ├── attendance/
        │   ├── models/
        │   ├── providers/
        │   ├── screens/
        │   └── widgets/
        ├── find_rotarian/
        │   ├── models/
        │   ├── providers/
        │   ├── screens/
        │   └── widgets/
        ├── find_club/
        │   ├── models/
        │   ├── providers/
        │   ├── screens/
        │   └── widgets/
        ├── service_directory/
        │   ├── models/
        │   ├── providers/
        │   ├── screens/
        │   └── widgets/
        ├── subgroups/
        │   ├── models/
        │   ├── providers/
        │   ├── screens/
        │   └── widgets/
        ├── district/
        │   ├── models/
        │   ├── providers/
        │   ├── screens/
        │   └── widgets/
        ├── leaderboard/
        │   ├── models/
        │   ├── providers/
        │   ├── screens/
        │   └── widgets/
        ├── web_links/
        │   ├── models/
        │   ├── providers/
        │   ├── screens/
        │   └── widgets/
        ├── notifications/
        │   ├── models/
        │   ├── providers/
        │   ├── screens/
        │   └── widgets/
        ├── settings/
        │   ├── models/
        │   ├── providers/
        │   ├── screens/
        │   └── widgets/
        ├── profile/
        │   ├── models/
        │   ├── providers/
        │   ├── screens/
        │   └── widgets/
        ├── groups/
        │   ├── models/
        │   ├── providers/
        │   ├── screens/
        │   └── widgets/
        ├── monthly_report/
        │   ├── providers/
        │   └── screens/
        └── maps/
            ├── providers/
            ├── screens/
            └── widgets/

Run flutter pub get after setting up pubspec.yaml. Ensure no errors.
```

---

## Expected Output Files
- `/touchbase_flutter/pubspec.yaml` (with all dependencies)
- Full folder scaffold under `lib/`

## Verification
- `flutter pub get` completes without errors
- All folders exist under `lib/src/`
