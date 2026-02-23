# Phase 17: E-Bulletin Feature

## Priority: 17
## Depends On: Phase 10

---

## Command Prompt

```
I am migrating an iOS app to Flutter.

Read these iOS source files CAREFULLY:
1. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/E-BulletinListingController/EBulletinListingController.swift
2. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/E-BulletinListingController/EbulletinDetailViewController.swift
3. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/E-BulletinListingController/EbulletineCell.swift
4. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/ADDViewControllers/Add_Eulletine/ (ALL files)

Read WebserviceClass.swift for:
5. addEbulletin, getYearWiseEbulletinList methods

Read Obj-C models:
6. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/ControllerObjectiveC/ (find TBEbulletinListResult, TBAddEbulletinResult folders)

Now create in /Users/ios2/Documents/Mani_mac_folder/touchbase_flutter/:

MODELS:
1. lib/src/features/ebulletin/models/ebulletin_list_result.dart
2. lib/src/features/ebulletin/models/add_ebulletin_result.dart

PROVIDERS:
3. lib/src/features/ebulletin/providers/ebulletin_provider.dart
   - Year-wise listing + CRUD
   - State: ebulletins list, selectedYear, selectedEbulletin, isLoading, error
   - Methods: fetchYearWiseList(), addEbulletin(), fetchEbulletinDetail()

SCREENS:
4. lib/src/features/ebulletin/screens/ebulletin_list_screen.dart - year-wise list
5. lib/src/features/ebulletin/screens/ebulletin_detail_screen.dart
6. lib/src/features/ebulletin/screens/add_ebulletin_screen.dart

WIDGETS:
7. lib/src/features/ebulletin/widgets/ebulletin_card.dart

STRICT RULES:
- EXACT same API endpoints, year-wise logic, and UI as iOS
- ALL nullable, NO force unwraps
- Provider + Consumer + FutureBuilder
```

---

## iOS Source Files to Read
- `TouchBase/Controllers/E-BulletinListingController/` (all 3 files)
- `TouchBase/Controllers/ADDViewControllers/Add_Eulletine/` (ALL files)
- `WebserviceClass.swift` (ebulletin methods)
- `ControllerObjectiveC/` (TBEbulletinListResult, TBAddEbulletinResult)

## Expected Output Files
- `lib/src/features/ebulletin/models/ebulletin_list_result.dart`
- `lib/src/features/ebulletin/models/add_ebulletin_result.dart`
- `lib/src/features/ebulletin/providers/ebulletin_provider.dart`
- `lib/src/features/ebulletin/screens/ebulletin_list_screen.dart`
- `lib/src/features/ebulletin/screens/ebulletin_detail_screen.dart`
- `lib/src/features/ebulletin/screens/add_ebulletin_screen.dart`
- `lib/src/features/ebulletin/widgets/ebulletin_card.dart`
