# Phase 21: Service Directory Feature

## Priority: 21
## Depends On: Phase 10

---

## Command Prompt

```
I am migrating an iOS app to Flutter.

Read these iOS source files CAREFULLY:
1. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/ServiceDirectoryListViewController/ServiceDirectoryListViewController.swift
2. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/ServiceDirectoryListViewController/CategoryServiceDirectoryViewController.swift
3. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/ServiceDirectoryListViewController/WebSiteViewController.swift
4. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/ServiceDirectoryListViewController/WebSiteNewViewController.swift

Read WebserviceClass.swift for:
5. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/ServiceManager/WebserviceClass.swift
   Search for: getServiceCategoriesData, getServiceDirectoryCategories methods

Read Obj-C models:
6. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/ControllerObjectiveC/ (find TBServiceDirectoryResult, TBServiceDirectoryListResult, TBAddServiceResult folders)

Now create in /Users/ios2/Documents/Mani_mac_folder/touchbase_flutter/:

MODELS:
1. lib/src/features/service_directory/models/service_directory_result.dart
2. lib/src/features/service_directory/models/service_list_result.dart
3. lib/src/features/service_directory/models/add_service_result.dart

PROVIDERS:
4. lib/src/features/service_directory/providers/service_directory_provider.dart
   - State: categories list, services list, selectedCategory, selectedService, isLoading, error
   - Methods: fetchCategories(), fetchServicesByCategory(), addService()
   - EXACT same category-based filtering logic as iOS

SCREENS:
5. lib/src/features/service_directory/screens/service_directory_screen.dart
6. lib/src/features/service_directory/screens/service_category_screen.dart
7. lib/src/features/service_directory/screens/service_website_screen.dart - WebView for service website

WIDGETS:
8. lib/src/features/service_directory/widgets/service_list_tile.dart

STRICT RULES:
- EXACT same API endpoints, category logic, and UI as iOS
- ALL nullable, NO force unwraps
- Provider + Consumer + FutureBuilder
```

---

## iOS Source Files to Read
- `TouchBase/Controllers/ServiceDirectoryListViewController/` (all 4 files)
- `WebserviceClass.swift` (service directory methods)
- `ControllerObjectiveC/` (TBServiceDirectoryResult, etc.)

## Expected Output Files
- `lib/src/features/service_directory/models/service_directory_result.dart`
- `lib/src/features/service_directory/models/service_list_result.dart`
- `lib/src/features/service_directory/models/add_service_result.dart`
- `lib/src/features/service_directory/providers/service_directory_provider.dart`
- `lib/src/features/service_directory/screens/service_directory_screen.dart`
- `lib/src/features/service_directory/screens/service_category_screen.dart`
- `lib/src/features/service_directory/screens/service_website_screen.dart`
- `lib/src/features/service_directory/widgets/service_list_tile.dart`
