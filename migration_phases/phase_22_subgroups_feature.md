# Phase 22: Sub-Groups / Committees Feature

## Priority: 22
## Depends On: Phase 10

---

## Command Prompt

```
I am migrating an iOS app to Flutter.

Read these iOS source files CAREFULLY:
1. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/SubGroupDetailViewController/SubGroupDetailViewController.swift
2. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/SubGroupDetailViewController/ChildSubgrpViewController.swift
3. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/ADDViewControllers/Sub_GroupController/ (ALL files)

Read WebserviceClass.swift for:
4. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/ServiceManager/WebserviceClass.swift
   Search for: getSubGroupList, getSubGroupDetail, createSubGroup methods

Read Obj-C models:
5. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/ControllerObjectiveC/TBGetSubGroupDetailListResult/ (ALL files)
6. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/ControllerObjectiveC/Sub_Group_List/ (ALL files)

Now create in /Users/ios2/Documents/Mani_mac_folder/touchbase_flutter/:

MODELS:
1. lib/src/features/subgroups/models/subgroup_list_result.dart
2. lib/src/features/subgroups/models/subgroup_detail_result.dart

PROVIDERS:
3. lib/src/features/subgroups/providers/subgroups_provider.dart
   - State: subgroups list, selectedSubgroup, subgroupMembers, childSubgroups, isLoading, error
   - Methods: fetchSubGroupList(), fetchSubGroupDetail(), createSubGroup()
   - EXACT same hierarchy logic as iOS (parent -> child subgroups)

SCREENS:
4. lib/src/features/subgroups/screens/subgroup_list_screen.dart
5. lib/src/features/subgroups/screens/subgroup_detail_screen.dart
6. lib/src/features/subgroups/screens/child_subgroup_screen.dart
7. lib/src/features/subgroups/screens/add_subgroup_screen.dart

WIDGETS:
8. lib/src/features/subgroups/widgets/subgroup_member_tile.dart

STRICT RULES:
- EXACT same API endpoints, hierarchy logic, and UI as iOS
- ALL nullable, NO force unwraps
- Provider + Consumer + FutureBuilder
```

---

## iOS Source Files to Read
- `TouchBase/Controllers/SubGroupDetailViewController/` (all files)
- `TouchBase/Controllers/ADDViewControllers/Sub_GroupController/` (ALL files)
- `WebserviceClass.swift` (subgroup methods)
- `ControllerObjectiveC/TBGetSubGroupDetailListResult/`
- `ControllerObjectiveC/Sub_Group_List/`

## Expected Output Files
- `lib/src/features/subgroups/models/subgroup_list_result.dart`
- `lib/src/features/subgroups/models/subgroup_detail_result.dart`
- `lib/src/features/subgroups/providers/subgroups_provider.dart`
- `lib/src/features/subgroups/screens/subgroup_list_screen.dart`
- `lib/src/features/subgroups/screens/subgroup_detail_screen.dart`
- `lib/src/features/subgroups/screens/child_subgroup_screen.dart`
- `lib/src/features/subgroups/screens/add_subgroup_screen.dart`
- `lib/src/features/subgroups/widgets/subgroup_member_tile.dart`
