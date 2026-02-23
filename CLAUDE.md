# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

TouchBase is a Rotary International organization management app, migrated from native iOS (Swift/Obj-C) to Flutter. It manages clubs, districts, members, events, galleries, documents, and more across the Rotary hierarchy (Organization > Districts > Clubs > Members > Family).

**SDK:** Dart ^3.10.1 | **Platforms:** iOS 14.0+, Android, Web, macOS, Windows, Linux

## Build & Development Commands

```bash
# Run the app
flutter run

# Build
flutter build apk          # Android
flutter build ios           # iOS
flutter build web           # Web

# Analysis & linting (uses package:flutter_lints/flutter.yaml)
flutter analyze

# Tests
flutter test                # Run all tests
flutter test test/widget_test.dart  # Run single test

# Code generation (for json_serializable models)
dart run build_runner build --delete-conflicting-outputs

# Dependencies
flutter pub get

# iOS pods
cd ios && pod install && cd ..
```

## Architecture

### Core Pattern: Feature-First with Provider

```
lib/
├── main.dart              # Firebase init, singleton initialization (ApiClient, LocalStorage, SecureStorage, DatabaseHelper)
├── app.dart               # MultiProvider setup (25 ChangeNotifierProviders) wrapping MaterialApp.router
└── src/
    ├── core/              # Shared infrastructure
    │   ├── constants/     # api_constants.dart (100+ endpoints), app_constants.dart (SharedPref keys), toast_constants.dart
    │   ├── network/       # api_client.dart (http package singleton), api_interceptor.dart, connectivity_service.dart
    │   ├── navigation/    # app_router.dart (GoRouter, ~940 lines, 50+ routes)
    │   ├── storage/       # local_storage.dart (SharedPreferences), secure_storage.dart, database_helper.dart (SQLite)
    │   ├── theme/         # app_colors.dart (purple #673AB7 primary), app_text_styles.dart, app_theme.dart
    │   ├── extensions/    # string, date, context, widget extensions
    │   ├── utils/         # validators, date_utils, file_downloader, image_loader
    │   └── widgets/       # 13 reusable widgets (CommonAppBar, CommonButton, CommonTextField, etc.)
    └── features/          # 24 feature modules
```

### Feature Module Structure (consistent across all 24 features)

```
features/<feature_name>/
├── models/      # JSON-serializable result models (all fields nullable)
├── providers/   # ChangeNotifier with isLoading/error/data pattern
├── screens/     # UI pages using Consumer<Provider>
└── widgets/     # Feature-specific UI components
```

### State Management: Provider + ChangeNotifier

All 25 providers are registered as `ChangeNotifierProvider` in `app.dart`. Each provider follows this pattern:
- Private state fields (`_isLoading`, `_error`, `_data`)
- Public getters
- Async methods that set loading state, call ApiClient, parse response, and `notifyListeners()`
- Screens consume state via `Consumer<ProviderType>` or `context.read<ProviderType>()`

### Navigation: GoRouter

Defined in `app_router.dart`. Auth guard redirects unauthenticated users. Route flow:
- Auth: `/splash` → `/login` → `/otp` → `/welcome`
- Main: `/dashboard` with 50+ nested routes for all features
- Data passed via `GoRouter state.extra` as `Map<String, dynamic>`

### Networking

- **HTTP client:** `package:http` (NOT Dio), singleton `ApiClient.instance`
- **Base URL:** `https://api.imeiconnect.com/api/`
- **Auth header:** `Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==`
- **All requests are POST** (even data fetches), matching the original iOS API
- **User identity** sent in request body (`masterUID`, `grpID`, `profileId`), not headers
- **Timeouts:** 30s default, 120s for Celebrations endpoints
- **401 responses** trigger session expiry and re-login

### Storage Layer (all singletons)

- **LocalStorage:** SharedPreferences wrapper with 100+ keys mapped from iOS UserDefaults
- **SecureStorage:** flutter_secure_storage for auth/device/session tokens
- **DatabaseHelper:** SQLite (`NewTouchbase.db`) with tables: GROUPMASTER, MODULE_DATA_MASTER, Notification_Table, DIRECTORY_DATA_MASTER, SERVICE_DIRECTORY_DATA_MASTER, GALLERY_MASTER, ALBUM_PHOTO_MASTER, ReplicaInfo

### Data Models

- All model fields are nullable (`String?`, `int?`) — no force unwrapping
- JSON parsing uses `json_serializable` with `build_runner` code generation
- API responses follow: `{ isSuccess, message, data, serverError, errorName }`

## Key Conventions

- **Singletons** for infrastructure: `ApiClient.instance`, `LocalStorage.instance`, `SecureStorage.instance`, `DatabaseHelper.instance`
- **iOS migration origin:** Code maps directly from iOS ViewControllers/delegates to Flutter screens/providers. See `folder_details.md` for the complete VC-to-Widget mapping table and `api_details.md` for endpoint documentation
- **Loading/error UI:** `flutter_easyloading` for progress dialogs, `fluttertoast` for toasts, provider-based loading states in screens
- **Images:** `cached_network_image` for network images, `image_picker` for camera/gallery
- **Constants naming:** SharedPreferences keys in `app_constants.dart` mirror iOS UserDefaults keys (e.g., `masterUID`, `grpId0`, `ClubName`)
