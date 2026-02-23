# Phase 13: Celebrations Feature

## Priority: 13
## Depends On: Phase 10

---

## Command Prompt

```
I am migrating an iOS app to Flutter.

Read these iOS source files CAREFULLY:
1. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Celebration/CelebrationViewController.swift
2. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Celebration/BannerListViewController.swift
3. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Celebration/BirthdayListViewController.swift
4. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Celebration/DistrictEventDetailsShowViewController.swift
5. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Celebration/ (ALL remaining files)

Read WebserviceClass.swift for these methods:
6. getMonthEventList, getEventMinDetails, getMonthEventListTypeWise,
   getMonthEventListDetails, getTodaysBirthday

Also read:
7. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/folder_details.md (Section 4.5)

Now create in /Users/ios2/Documents/Mani_mac_folder/touchbase_flutter/:

MODELS:
1. lib/src/features/celebrations/models/celebration_result.dart
2. lib/src/features/celebrations/models/birthday_result.dart

PROVIDERS:
3. lib/src/features/celebrations/providers/celebrations_provider.dart
   - EXACT same API calls with 120s timeout for celebrations (matching iOS ServiceManager)
   - State: monthEvents, birthdays, anniversaries, selectedMonth, isLoading, error
   - Methods: fetchMonthEvents(), fetchBirthdays(), fetchAnniversaries(), fetchEventDetails()

SCREENS:
4. lib/src/features/celebrations/screens/celebrations_screen.dart
   - EXACT same tabbed layout as iOS (Events/Anniversary/Birthday tabs)
   - Calendar grid for month view
   - Use table_calendar package

5. lib/src/features/celebrations/screens/banner_list_screen.dart
6. lib/src/features/celebrations/screens/birthday_list_screen.dart
7. lib/src/features/celebrations/screens/district_event_detail_screen.dart

WIDGETS:
8. lib/src/features/celebrations/widgets/calendar_grid.dart
9. lib/src/features/celebrations/widgets/celebration_tab_bar.dart
10. lib/src/features/celebrations/widgets/celebration_list_tile.dart - with call/email actions

STRICT RULES:
- Use 120s timeout for celebration APIs (matching iOS)
- EXACT same tab structure and calendar logic as iOS
- ALL nullable, NO force unwraps
- Provider + Consumer + FutureBuilder
```

---

## iOS Source Files to Read
- `TouchBase/Celebration/` (ALL files)
- `WebserviceClass.swift` (celebration methods)
- `folder_details.md` (Section 4.5)

## Expected Output Files
- `lib/src/features/celebrations/models/celebration_result.dart`
- `lib/src/features/celebrations/models/birthday_result.dart`
- `lib/src/features/celebrations/providers/celebrations_provider.dart`
- `lib/src/features/celebrations/screens/celebrations_screen.dart`
- `lib/src/features/celebrations/screens/banner_list_screen.dart`
- `lib/src/features/celebrations/screens/birthday_list_screen.dart`
- `lib/src/features/celebrations/screens/district_event_detail_screen.dart`
- `lib/src/features/celebrations/widgets/calendar_grid.dart`
- `lib/src/features/celebrations/widgets/celebration_tab_bar.dart`
- `lib/src/features/celebrations/widgets/celebration_list_tile.dart`
