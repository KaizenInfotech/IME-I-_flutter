# Phase 28: Profile & Family Management Feature

## Priority: 28
## Depends On: Phase 10

---

## Command Prompt

```
I am migrating an iOS app to Flutter.

Read these iOS source files CAREFULLY:
1. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/SegmentMemberFamily/FamilySegmentViewController.swift
2. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/SegmentMemberFamily/MemberSegmentClass/ (ALL files)
3. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/ChangeRequestViewController.swift
4. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Classes/CommonClasses/CommonAccessibleHoldVariable.swift

Read WebserviceClass.swift for:
5. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/ServiceManager/WebserviceClass.swift
   Search for: updateProfileDetails, updateAddressDetails, updateFamilyDetails,
   uploadProfilePhoto, getBodList, getPastPresidentsList methods

Read Obj-C models:
6. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/ControllerObjectiveC/ADDFamilyMember/ (ALL files)
7. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/ControllerObjectiveC/UpdateFamilyMember/ (ALL files)

Now create in /Users/ios2/Documents/Mani_mac_folder/touchbase_flutter/:

MODELS:
1. lib/src/features/profile/models/update_family_result.dart
2. lib/src/features/profile/models/update_address_result.dart
3. lib/src/features/profile/models/bod_member_result.dart

PROVIDERS:
4. lib/src/features/profile/providers/profile_provider.dart
   - Replace CommonAccessibleHoldVariable shared mutable state with Provider state
   - State: profileData, familyMembers list, addresses list, bodMembers list,
     pastPresidents list, selectedBodMember, selectedFamilyMember, isLoading, error
   - All the varBodMemberName, varBodMemberProfileId, varFamilyDetails_* etc.
     from CommonAccessibleHoldVariable become Provider state fields
   - Methods: updateProfile(), updateAddress(), updateFamily(), addFamilyMember(),
     uploadProfilePhoto(), fetchBodList(), fetchPastPresidents()
   - EXACT same API calls as iOS

SCREENS:
5. lib/src/features/profile/screens/my_profile_screen.dart
6. lib/src/features/profile/screens/edit_family_screen.dart - add/edit family member
7. lib/src/features/profile/screens/edit_address_screen.dart - address update form
8. lib/src/features/profile/screens/change_request_screen.dart
9. lib/src/features/profile/screens/bod_list_screen.dart - Board of Directors list
10. lib/src/features/profile/screens/past_presidents_screen.dart

WIDGETS:
11. lib/src/features/profile/widgets/family_member_card.dart
12. lib/src/features/profile/widgets/address_card.dart

STRICT RULES:
- EXACT same API endpoints, family/address update logic as iOS
- Replace CommonAccessibleHoldVariable with Provider state - no shared mutable globals
- ALL nullable, NO force unwraps
- Provider + Consumer + FutureBuilder
```

---

## iOS Source Files to Read
- `TouchBase/Controllers/SegmentMemberFamily/` (all files and subfolders)
- `TouchBase/ChangeRequestViewController.swift`
- `TouchBase/Classes/CommonClasses/CommonAccessibleHoldVariable.swift`
- `WebserviceClass.swift` (profile/family methods)
- `ControllerObjectiveC/ADDFamilyMember/` (ALL files)
- `ControllerObjectiveC/UpdateFamilyMember/` (ALL files)

## Expected Output Files
- `lib/src/features/profile/models/update_family_result.dart`
- `lib/src/features/profile/models/update_address_result.dart`
- `lib/src/features/profile/models/bod_member_result.dart`
- `lib/src/features/profile/providers/profile_provider.dart`
- `lib/src/features/profile/screens/my_profile_screen.dart`
- `lib/src/features/profile/screens/edit_family_screen.dart`
- `lib/src/features/profile/screens/edit_address_screen.dart`
- `lib/src/features/profile/screens/change_request_screen.dart`
- `lib/src/features/profile/screens/bod_list_screen.dart`
- `lib/src/features/profile/screens/past_presidents_screen.dart`
- `lib/src/features/profile/widgets/family_member_card.dart`
- `lib/src/features/profile/widgets/address_card.dart`
