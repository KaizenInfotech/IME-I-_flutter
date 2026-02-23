# Phase 10: Dashboard Feature

## Priority: 10
## Depends On: Phase 9

---

## Command Prompt

```
I am migrating an iOS app to Flutter.

Read these iOS source files CAREFULLY:
1. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/MainDashboardViewController/MainDashboardViewController.swift
2. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/MainDashboardViewController/CustomisedDashViewController.swift
3. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/MainDashboardViewController/CustumiseMyModuleViewController.swift
4. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/MainDashboardViewController/ModuleDashboardViewController.swift
5. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/MainDashBoardWithSidebar/MainDashboardWithSideBarViewController.swift
6. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/MainDashBoardWithSidebar/RotaryMenuViewController.swift
7. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/MainDashboardViewController/GroupView_DashBoard/ (all files in subfolders)
8. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/AdminModuleListingViewController.swift

Read WebserviceClass.swift for these methods (search for function names):
9. getGroupModulesList, getNewDashboard, getAdminSubModules, getAllGroupsList,
   getNotificationCount, updateModuleDashboard, getEntityInfo

Read Obj-C models:
10. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/ControllerObjectiveC/GroupCreatedScreenResult/ (all files)
11. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/ControllerObjectiveC/ (any TBGroupResult, TBGetGroupModuleResult, TBDashboardResult folders)

Also read:
12. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/folder_details.md (Section 4.2: Dashboard Feature)

Now create in /Users/ios2/Documents/Mani_mac_folder/touchbase_flutter/:

MODELS:
1. lib/src/features/dashboard/models/group_result.dart - TBGroupResult, GroupResult (all nullable)
2. lib/src/features/dashboard/models/module_result.dart - TBGetGroupModuleResult (all nullable)
3. lib/src/features/dashboard/models/dashboard_result.dart - TBDashboardResult with banner data (all nullable)
4. lib/src/features/dashboard/models/admin_submodules_result.dart - AdminSubmodulesResult (all nullable)

PROVIDERS:
5. lib/src/features/dashboard/providers/dashboard_provider.dart
   - State: dashboardData, banners, notificationCount, isLoading, error
   - Methods matching EXACT iOS API calls: fetchDashboard(), fetchBanners(), fetchNotificationCount()

6. lib/src/features/dashboard/providers/group_provider.dart
   - State: groups list, selectedGroup, modules list
   - Methods: fetchGroups(), switchGroup(), fetchModules()
   - Match EXACT same group switching logic as iOS

7. lib/src/features/dashboard/providers/module_provider.dart
   - State: modules list, customized order
   - Methods: fetchModules(), reorderModules(), updateModuleDashboard()

SCREENS:
8. lib/src/features/dashboard/screens/dashboard_screen.dart
   - Match EXACT same layout as iOS MainDashboardViewController
   - Banner carousel at top (celebrations/birthdays)
   - Module grid (CollectionView -> GridView.builder)
   - Group name display with switcher
   - Notification badge count
   - Use Consumer<DashboardProvider> and Consumer<GroupProvider>
   - FutureBuilder for initial data load

9. lib/src/features/dashboard/screens/customize_modules_screen.dart
   - Match iOS CustumiseMyModuleViewController
   - Drag-reorderable module list
   - Save customized order via API

10. lib/src/features/dashboard/screens/admin_modules_screen.dart
    - Match iOS AdminModuleListingViewController
    - Admin sub-modules grid

11. lib/src/features/dashboard/screens/sidebar_screen.dart
    - Match iOS MainDashboardWithSideBarViewController
    - Drawer with menu items

WIDGETS:
12. lib/src/features/dashboard/widgets/module_grid_item.dart - Module cell
13. lib/src/features/dashboard/widgets/banner_carousel.dart - Auto-scrolling banner
14. lib/src/features/dashboard/widgets/sidebar_menu.dart - Drawer menu content
15. lib/src/features/dashboard/widgets/group_switcher.dart - Group picker dropdown

STRICT RULES:
- EXACT same API endpoints and parameters as iOS
- EXACT same module grid layout and navigation logic
- EXACT same sidebar menu items and navigation targets
- ALL fields nullable, NO force unwraps
- Provider + Consumer + FutureBuilder
```

---

## iOS Source Files to Read
- `TouchBase/Controllers/MainDashboardViewController/` (all files)
- `TouchBase/Controllers/MainDashBoardWithSidebar/` (all files)
- `TouchBase/AdminModuleListingViewController.swift`
- `WebserviceClass.swift` (getGroupModulesList, getNewDashboard, etc.)
- `ControllerObjectiveC/GroupCreatedScreenResult/`
- `folder_details.md` (Section 4.2)

## Expected Output Files
- `lib/src/features/dashboard/models/group_result.dart`
- `lib/src/features/dashboard/models/module_result.dart`
- `lib/src/features/dashboard/models/dashboard_result.dart`
- `lib/src/features/dashboard/models/admin_submodules_result.dart`
- `lib/src/features/dashboard/providers/dashboard_provider.dart`
- `lib/src/features/dashboard/providers/group_provider.dart`
- `lib/src/features/dashboard/providers/module_provider.dart`
- `lib/src/features/dashboard/screens/dashboard_screen.dart`
- `lib/src/features/dashboard/screens/customize_modules_screen.dart`
- `lib/src/features/dashboard/screens/admin_modules_screen.dart`
- `lib/src/features/dashboard/screens/sidebar_screen.dart`
- `lib/src/features/dashboard/widgets/module_grid_item.dart`
- `lib/src/features/dashboard/widgets/banner_carousel.dart`
- `lib/src/features/dashboard/widgets/sidebar_menu.dart`
- `lib/src/features/dashboard/widgets/group_switcher.dart`
