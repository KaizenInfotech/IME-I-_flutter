# Phase 24: Leaderboard Feature

## Priority: 24
## Depends On: Phase 10

---

## Command Prompt

```
I am migrating an iOS app to Flutter.

Read these iOS source files CAREFULLY:
1. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/LeaderBoard/LeaderBoardViewController.swift
2. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/LeaderBoard/TableViewCustomeCell.swift
3. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/LeaderBoard/LeaderBoardCollectionViewCell.swift

Read WebserviceClass.swift for:
4. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/ServiceManager/WebserviceClass.swift
   Search for: getZonelist, and any leaderboard-related API methods

Now create in /Users/ios2/Documents/Mani_mac_folder/touchbase_flutter/:

MODELS:
1. lib/src/features/leaderboard/models/leaderboard_result.dart
   - Zone list + leaderboard data models
   - All fields nullable
   - fromJson/toJson

PROVIDERS:
2. lib/src/features/leaderboard/providers/leaderboard_provider.dart
   - Zone/year filter logic matching iOS exactly
   - State: zones list, leaderboardData, selectedZone, selectedYear, isLoading, error
   - Methods: fetchZoneList(), fetchLeaderboard()

SCREENS:
3. lib/src/features/leaderboard/screens/leaderboard_screen.dart
   - Zone and year filter dropdowns
   - Leaderboard list/grid matching iOS layout
   - Consumer<LeaderboardProvider> + FutureBuilder

WIDGETS:
4. lib/src/features/leaderboard/widgets/leaderboard_collection_cell.dart
5. lib/src/features/leaderboard/widgets/leaderboard_table_cell.dart

STRICT RULES:
- EXACT same zone/year filter logic, API endpoints, and UI as iOS
- ALL nullable, NO force unwraps
- Provider + Consumer + FutureBuilder
```

---

## iOS Source Files to Read
- `TouchBase/Controllers/LeaderBoard/` (all 3 files)
- `WebserviceClass.swift` (leaderboard/zone methods)

## Expected Output Files
- `lib/src/features/leaderboard/models/leaderboard_result.dart`
- `lib/src/features/leaderboard/providers/leaderboard_provider.dart`
- `lib/src/features/leaderboard/screens/leaderboard_screen.dart`
- `lib/src/features/leaderboard/widgets/leaderboard_collection_cell.dart`
- `lib/src/features/leaderboard/widgets/leaderboard_table_cell.dart`
