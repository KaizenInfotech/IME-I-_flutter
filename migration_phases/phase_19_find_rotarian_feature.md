# Phase 19: Find Rotarian Feature

## Priority: 19
## Depends On: Phase 10

---

## Command Prompt

```
I am migrating an iOS app to Flutter.

Read these iOS source files CAREFULLY:
1. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/FindARotarians/FinddArotarianViewController.swift
2. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/FindARotarians/RotarianProfileBusinessDetailsViewController.swift
3. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/FindARotarians/SearchFindArotarianViewController.swift

Read WebserviceClass.swift for:
4. getZonechapterlist, getRotarianList, getRotarianDetails methods

Also read:
5. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Classes/CommonClasses/CommonAccessibleHoldVariable.swift
   (for varclubName and other shared state used in Find Rotarian)

Now create in /Users/ios2/Documents/Mani_mac_folder/touchbase_flutter/:

MODELS:
1. lib/src/features/find_rotarian/models/rotarian_result.dart
   - All fields nullable
   - Include zone, chapter, rotarian list and detail models
   - fromJson/toJson

PROVIDERS:
2. lib/src/features/find_rotarian/providers/find_rotarian_provider.dart
   - Cascading Zone -> Chapter dropdown logic matching iOS exactly
   - State: zones list, chapters list, rotarians list, selectedZone, selectedChapter,
     selectedRotarian, searchQuery, isLoading, error
   - Methods: fetchZoneChapterList(), fetchRotarianList(), fetchRotarianDetails(),
     searchRotarians()

SCREENS:
3. lib/src/features/find_rotarian/screens/find_rotarian_screen.dart
   - Zone/Chapter cascading dropdowns + search
4. lib/src/features/find_rotarian/screens/rotarian_profile_screen.dart
   - Business details + profile info
5. lib/src/features/find_rotarian/screens/search_rotarian_screen.dart

WIDGETS:
6. lib/src/features/find_rotarian/widgets/zone_chapter_picker.dart - cascading dropdowns
7. lib/src/features/find_rotarian/widgets/rotarian_list_tile.dart

STRICT RULES:
- EXACT same cascading zone/chapter logic as iOS
- EXACT same API endpoints and parameters as iOS
- ALL nullable, NO force unwraps
- Provider + Consumer + FutureBuilder
```

---

## iOS Source Files to Read
- `TouchBase/Controllers/FindARotarians/` (all 3 files)
- `WebserviceClass.swift` (find rotarian methods)
- `TouchBase/Classes/CommonClasses/CommonAccessibleHoldVariable.swift`

## Expected Output Files
- `lib/src/features/find_rotarian/models/rotarian_result.dart`
- `lib/src/features/find_rotarian/providers/find_rotarian_provider.dart`
- `lib/src/features/find_rotarian/screens/find_rotarian_screen.dart`
- `lib/src/features/find_rotarian/screens/rotarian_profile_screen.dart`
- `lib/src/features/find_rotarian/screens/search_rotarian_screen.dart`
- `lib/src/features/find_rotarian/widgets/zone_chapter_picker.dart`
- `lib/src/features/find_rotarian/widgets/rotarian_list_tile.dart`
