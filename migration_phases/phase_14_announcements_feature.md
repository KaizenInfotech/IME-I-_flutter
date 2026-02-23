# Phase 14: Announcements Feature

## Priority: 14
## Depends On: Phase 10

---

## Command Prompt

```
I am migrating an iOS app to Flutter.

Read these iOS source files CAREFULLY:
1. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/ADDViewControllers/Add_Announcement/ (ALL files)
2. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/AnnouncementDetailNotiViewController.swift

Read WebserviceClass.swift for:
3. getAnnouncementDetails, addAnnouncement methods

Read Obj-C models:
4. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/ControllerObjectiveC/ (find TBAnnounceListResult, TBAddAnnouncementResult folders)

Also read:
5. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/folder_details.md (announcements section from feature mapping)

Now create in /Users/ios2/Documents/Mani_mac_folder/touchbase_flutter/:

MODELS:
1. lib/src/features/announcements/models/announcement_list_result.dart
2. lib/src/features/announcements/models/add_announcement_result.dart

PROVIDERS:
3. lib/src/features/announcements/providers/announcements_provider.dart
   - EXACT same API calls as iOS
   - State: announcements list, selectedAnnouncement, isLoading, error
   - Methods: fetchAnnouncements(), fetchAnnouncementDetail(), addAnnouncement()

SCREENS:
4. lib/src/features/announcements/screens/announcements_list_screen.dart
5. lib/src/features/announcements/screens/announcement_detail_screen.dart
6. lib/src/features/announcements/screens/add_announcement_screen.dart

WIDGETS:
7. lib/src/features/announcements/widgets/announcement_card.dart

STRICT RULES:
- EXACT same API endpoints, parameters, and logic as iOS
- ALL nullable, NO force unwraps
- Provider + Consumer + FutureBuilder
```

---

## iOS Source Files to Read
- `TouchBase/Controllers/ADDViewControllers/Add_Announcement/` (ALL files)
- `TouchBase/AnnouncementDetailNotiViewController.swift`
- `WebserviceClass.swift` (announcement methods)
- `ControllerObjectiveC/` (TBAnnounceListResult, TBAddAnnouncementResult)
- `folder_details.md`

## Expected Output Files
- `lib/src/features/announcements/models/announcement_list_result.dart`
- `lib/src/features/announcements/models/add_announcement_result.dart`
- `lib/src/features/announcements/providers/announcements_provider.dart`
- `lib/src/features/announcements/screens/announcements_list_screen.dart`
- `lib/src/features/announcements/screens/announcement_detail_screen.dart`
- `lib/src/features/announcements/screens/add_announcement_screen.dart`
- `lib/src/features/announcements/widgets/announcement_card.dart`
