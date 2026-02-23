# Phase 29: Groups Management Feature

## Priority: 29
## Depends On: Phase 10

---

## Command Prompt

```
I am migrating an iOS app to Flutter.

Read WebserviceClass.swift for:
1. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/ServiceManager/WebserviceClass.swift
   Search for these methods: getAllCountriesAndCategories, getAllGroupsList, createGroup,
   getGroupDetail, addMemberToGroup, addMultipleMemberToGroup, globalSearchGroup,
   deleteByModuleName, removeGroupCategory, updateMemberGroupCategory,
   getEntityInfo, getAllGroupListSync, getClubDetails, getClubHistory, feedback

Read Obj-C models:
2. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/ControllerObjectiveC/ (find CreateGRpResult, TBCountryResult, TBGlobalSearchGroupResult, TBEntityInfoResult folders)

Also read:
3. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Branch&ChapterModule.swift

Now create in /Users/ios2/Documents/Mani_mac_folder/touchbase_flutter/:

MODELS:
1. lib/src/features/groups/models/create_group_result.dart
2. lib/src/features/groups/models/country_result.dart
3. lib/src/features/groups/models/global_search_result.dart
4. lib/src/features/groups/models/entity_info_result.dart

PROVIDERS:
5. lib/src/features/groups/providers/groups_provider.dart
   - State: countries list, categories list, groups list, selectedGroup,
     searchResults, entityInfo, isLoading, error
   - Methods: fetchCountriesAndCategories(), createGroup(), fetchGroupDetail(),
     addMemberToGroup(), addMultipleMembers(), globalSearchGroup(),
     deleteByModuleName(), removeGroupCategory(), updateMemberGroupCategory(),
     fetchEntityInfo(), fetchClubDetails(), fetchClubHistory(), submitFeedback()
   - EXACT same API calls and parameters as iOS

SCREENS:
6. lib/src/features/groups/screens/create_group_screen.dart - group creation form
7. lib/src/features/groups/screens/group_detail_screen.dart - group info detail
8. lib/src/features/groups/screens/add_members_screen.dart - add member(s) to group
9. lib/src/features/groups/screens/global_search_screen.dart - global group search

WIDGETS:
10. lib/src/features/groups/widgets/group_card.dart

STRICT RULES:
- EXACT same API endpoints, group CRUD logic, member add logic as iOS
- ALL nullable, NO force unwraps
- Provider + Consumer + FutureBuilder
```

---

## iOS Source Files to Read
- `WebserviceClass.swift` (group management methods)
- `ControllerObjectiveC/` (CreateGRpResult, TBCountryResult, TBGlobalSearchGroupResult, TBEntityInfoResult)
- `TouchBase/Branch&ChapterModule.swift`

## Expected Output Files
- `lib/src/features/groups/models/create_group_result.dart`
- `lib/src/features/groups/models/country_result.dart`
- `lib/src/features/groups/models/global_search_result.dart`
- `lib/src/features/groups/models/entity_info_result.dart`
- `lib/src/features/groups/providers/groups_provider.dart`
- `lib/src/features/groups/screens/create_group_screen.dart`
- `lib/src/features/groups/screens/group_detail_screen.dart`
- `lib/src/features/groups/screens/add_members_screen.dart`
- `lib/src/features/groups/screens/global_search_screen.dart`
- `lib/src/features/groups/widgets/group_card.dart`
