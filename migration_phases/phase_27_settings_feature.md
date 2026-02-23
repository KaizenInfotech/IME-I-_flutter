# Phase 27: Settings Feature

## Priority: 27
## Depends On: Phase 10

---

## Command Prompt

```
I am migrating an iOS app to Flutter.

Read WebserviceClass.swift for:
1. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/ServiceManager/WebserviceClass.swift
   Search for: getTouchbaseSetting, touchbaseSetting, groupSetting, getGroupSetting methods

Read Obj-C models:
2. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/ControllerObjectiveC/ (find TBSettingResult, TBGroupSettingResult folders)

Now create in /Users/ios2/Documents/Mani_mac_folder/touchbase_flutter/:

MODELS:
1. lib/src/features/settings/models/setting_result.dart
   - TBSettingResult equivalent
   - All fields nullable
   - fromJson/toJson

2. lib/src/features/settings/models/group_setting_result.dart
   - TBGroupSettingResult equivalent
   - All fields nullable
   - fromJson/toJson

PROVIDERS:
3. lib/src/features/settings/providers/settings_provider.dart
   - State: settings list, groupSettings, isLoading, error
   - Methods: fetchSettings(), updateSetting(), fetchGroupSettings(), updateGroupSetting()
   - EXACT same API calls as iOS

SCREENS:
4. lib/src/features/settings/screens/settings_screen.dart
   - Settings list with toggle switches
   - Match iOS settings layout

5. lib/src/features/settings/screens/group_settings_screen.dart
   - Group-level settings
   - Match iOS group settings layout

WIDGETS:
6. lib/src/features/settings/widgets/setting_toggle_tile.dart
   - ListTile with Switch toggle

STRICT RULES:
- EXACT same API endpoints, toggle logic, and UI as iOS
- ALL nullable, NO force unwraps
- Provider + Consumer + FutureBuilder
```

---

## iOS Source Files to Read
- `WebserviceClass.swift` (settings methods)
- `ControllerObjectiveC/` (TBSettingResult, TBGroupSettingResult)

## Expected Output Files
- `lib/src/features/settings/models/setting_result.dart`
- `lib/src/features/settings/models/group_setting_result.dart`
- `lib/src/features/settings/providers/settings_provider.dart`
- `lib/src/features/settings/screens/settings_screen.dart`
- `lib/src/features/settings/screens/group_settings_screen.dart`
- `lib/src/features/settings/widgets/setting_toggle_tile.dart`
