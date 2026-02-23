# Phase 23: District Feature

## Priority: 23
## Depends On: Phase 10

---

## Command Prompt

```
I am migrating an iOS app to Flutter.

Read these iOS source files CAREFULLY:
1. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/DistrictDirectoryOnline/DistrictDirectoryOnlineViewController.swift
2. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/DistrictDirectoryOnline/DistrictDirectoryDetailsVC.swift
3. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/DistrictDirectoryOnline/ClassificationMemberList/ (ALL files)
4. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/DistrictDirectoryOnline/CallMessageCell/ (ALL files)
5. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/DistrictClub/DistrictClubMemberListViewController.swift
6. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/DistrictClub/DistrictClubTableViewCell.swift

Read WebserviceClass.swift for:
7. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/ServiceManager/WebserviceClass.swift
   Search for: getDistrictMemberListSync, getClubs (district), getDistrictCommittee methods

Now create in /Users/ios2/Documents/Mani_mac_folder/touchbase_flutter/:

MODELS:
1. lib/src/features/district/models/district_result.dart
   - District member, club, committee response models
   - All fields nullable
   - fromJson/toJson

PROVIDERS:
2. lib/src/features/district/providers/district_provider.dart
   - State: districtMembers list, districtClubs list, districtCommittees list,
     selectedMember, selectedClub, isLoading, error
   - Methods: fetchDistrictMembers(), fetchDistrictClubs(), fetchDistrictCommittee()
   - EXACT same district hierarchy as iOS

SCREENS:
3. lib/src/features/district/screens/district_directory_screen.dart
4. lib/src/features/district/screens/district_member_detail_screen.dart
5. lib/src/features/district/screens/district_club_members_screen.dart
6. lib/src/features/district/screens/district_committee_screen.dart

WIDGETS:
7. lib/src/features/district/widgets/district_member_tile.dart
8. lib/src/features/district/widgets/call_message_cell.dart - call/message/email action buttons

STRICT RULES:
- EXACT same API endpoints, district hierarchy, and UI as iOS
- ALL nullable, NO force unwraps
- Provider + Consumer + FutureBuilder
```

---

## iOS Source Files to Read
- `TouchBase/Controllers/DistrictDirectoryOnline/` (all files and subfolders)
- `TouchBase/Controllers/DistrictClub/` (all files)
- `WebserviceClass.swift` (district methods)

## Expected Output Files
- `lib/src/features/district/models/district_result.dart`
- `lib/src/features/district/providers/district_provider.dart`
- `lib/src/features/district/screens/district_directory_screen.dart`
- `lib/src/features/district/screens/district_member_detail_screen.dart`
- `lib/src/features/district/screens/district_club_members_screen.dart`
- `lib/src/features/district/screens/district_committee_screen.dart`
- `lib/src/features/district/widgets/district_member_tile.dart`
- `lib/src/features/district/widgets/call_message_cell.dart`
