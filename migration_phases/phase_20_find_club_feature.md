# Phase 20: Find Club Feature

## Priority: 20
## Depends On: Phase 10

---

## Command Prompt

```
I am migrating an iOS app to Flutter.

Read WebserviceClass.swift for:
1. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/ServiceManager/WebserviceClass.swift
   Search for these methods: getClubList, getClubDetails, getClubsNearMe, getPublicAlbumsList,
   getPublicEventsList, getPublicNewsletterList, getClubMembers

Also read:
2. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/folder_details.md (find_club section)

Now create in /Users/ios2/Documents/Mani_mac_folder/touchbase_flutter/:

MODELS:
1. lib/src/features/find_club/models/club_result.dart
   - All fields nullable
   - Include club list, club detail, club members models
   - fromJson/toJson

PROVIDERS:
2. lib/src/features/find_club/providers/find_club_provider.dart
   - Club search, near me (with location), public albums/events/newsletters
   - State: clubs list, selectedClub, clubMembers, publicAlbums, publicEvents,
     publicNewsletters, searchQuery, isLoading, error
   - Methods: fetchClubList(), fetchClubDetails(), fetchClubsNearMe(),
     fetchPublicAlbums(), fetchPublicEvents(), fetchPublicNewsletters(), fetchClubMembers()
   - Near me requires device location permission

SCREENS:
3. lib/src/features/find_club/screens/find_club_screen.dart
   - Search + near me toggle
   - Club list with search
4. lib/src/features/find_club/screens/club_detail_screen.dart
   - Club details with map (google_maps_flutter)
   - Public albums, events, newsletters sections

WIDGETS:
5. lib/src/features/find_club/widgets/club_card.dart

STRICT RULES:
- EXACT same API endpoints, near-me logic, and UI as iOS
- ALL nullable, NO force unwraps
- Provider + Consumer + FutureBuilder
```

---

## iOS Source Files to Read
- `WebserviceClass.swift` (find club methods)
- `folder_details.md` (find_club section)

## Expected Output Files
- `lib/src/features/find_club/models/club_result.dart`
- `lib/src/features/find_club/providers/find_club_provider.dart`
- `lib/src/features/find_club/screens/find_club_screen.dart`
- `lib/src/features/find_club/screens/club_detail_screen.dart`
- `lib/src/features/find_club/widgets/club_card.dart`
