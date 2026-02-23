# Phase 11: Directory Feature (Member Directory)

## Priority: 11
## Depends On: Phase 10

---

## Command Prompt

```
I am migrating an iOS app to Flutter.

Read these iOS source files CAREFULLY:
1. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/DirectoryViewController/DirectoryViewController.swift
2. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/DirectoryViewController/ProfileInfoController.swift
3. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/DirectoryViewController/EditDirectoryController.swift
4. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/DirectoryViewController/ProfileDynamicNewViewController.swift
5. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/DirectoryViewController/JitoProfileViewController.swift

Read WebserviceClass.swift for these methods:
6. getDirectoryListGroupsOFUSer, getMember, updateProfileDetails, updateAddressDetails,
   updateFamilyDetails, uploadProfilePhoto, getUpdatedmemberProfileDetails, getBodList,
   getMemberListSync

Read Obj-C models:
7. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/ControllerObjectiveC/ (find TBMemberResult, MemberListDetailResult, UserResult folders)

Also read:
8. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/folder_details.md (Section 4.3)

Now create in /Users/ios2/Documents/Mani_mac_folder/touchbase_flutter/:

MODELS:
1. lib/src/features/directory/models/member_result.dart - TBMemberResult with all member fields (nullable)
2. lib/src/features/directory/models/member_detail_result.dart - MemberListDetailResult (nullable)
3. lib/src/features/directory/models/user_result.dart - UserResult for profile update (nullable)

PROVIDERS:
4. lib/src/features/directory/providers/directory_provider.dart
   - State: members list, selectedMember, isLoading, error, searchText, currentPage
   - Methods matching EXACT iOS logic:
     fetchDirectory(masterUID, grpID, searchText, page)
     getMemberDetail(masterUID, grpID, profileId)
     searchMembers(query)
     loadMoreMembers() - pagination matching iOS
     generateDirectoryPdf() - PDF export matching iOS pdfDataWithTableView()
   - Pagination logic must match iOS exactly

SCREENS:
5. lib/src/features/directory/screens/directory_screen.dart
   - EXACT same layout as iOS DirectoryViewController
   - Search bar at top, member list below
   - Pull to refresh, pagination on scroll
   - PDF export button in nav bar
   - Call/SMS/Email action buttons on each member
   - Consumer<DirectoryProvider> + FutureBuilder

6. lib/src/features/directory/screens/profile_detail_screen.dart
   - EXACT same layout as iOS ProfileDynamicNewViewController
   - Dynamic profile sections (personal, address, family, business)
   - Profile photo, call/message/email actions

7. lib/src/features/directory/screens/edit_profile_screen.dart
   - EXACT same layout as iOS EditDirectoryController
   - Editable form fields for profile update
   - Photo upload capability

8. lib/src/features/directory/screens/profile_info_screen.dart
   - Read-only profile view matching iOS ProfileInfoController

WIDGETS:
9. lib/src/features/directory/widgets/member_list_tile.dart - Member row with photo, name, call/message
10. lib/src/features/directory/widgets/classification_filter.dart - Classification picker dropdown
11. lib/src/features/directory/widgets/profile_section_card.dart - Expandable profile section

STRICT RULES:
- EXACT same API calls and parameters as iOS
- EXACT same search and pagination logic
- EXACT same profile section layout
- EXACT same call/SMS/email action handling (use url_launcher)
- ALL nullable, NO force unwraps
- Provider + Consumer + FutureBuilder
```

---

## iOS Source Files to Read
- `TouchBase/Controllers/DirectoryViewController/` (all 5 files)
- `WebserviceClass.swift` (directory methods)
- `ControllerObjectiveC/` (TBMemberResult, MemberListDetailResult, UserResult)
- `folder_details.md` (Section 4.3)

## Expected Output Files
- `lib/src/features/directory/models/member_result.dart`
- `lib/src/features/directory/models/member_detail_result.dart`
- `lib/src/features/directory/models/user_result.dart`
- `lib/src/features/directory/providers/directory_provider.dart`
- `lib/src/features/directory/screens/directory_screen.dart`
- `lib/src/features/directory/screens/profile_detail_screen.dart`
- `lib/src/features/directory/screens/edit_profile_screen.dart`
- `lib/src/features/directory/screens/profile_info_screen.dart`
- `lib/src/features/directory/widgets/member_list_tile.dart`
- `lib/src/features/directory/widgets/classification_filter.dart`
- `lib/src/features/directory/widgets/profile_section_card.dart`
