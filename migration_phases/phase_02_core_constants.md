# Phase 2: Core Constants

## Priority: 2
## Depends On: Phase 1

---

## Command Prompt

```
I am migrating an iOS app to Flutter.

Read these iOS source files:
1. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/MISC/Constant/APIConstant.swift
2. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/MISC/Constant/AppConstant.swift
3. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/MISC/Constant/ToastConstant.swift

Also read the API reference doc:
4. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/api_details.md

Now create these files in the Flutter project at /Users/ios2/Documents/Mani_mac_folder/touchbase_flutter/:

1. lib/src/core/constants/api_constants.dart
   - Production base URL: "https://api.imeiconnect.com/api/"
   - EVERY single API endpoint path from the iOS APIConstant.swift - do NOT miss any
   - Static page URLs (terms, subscribes)
   - Timeout durations (30s default, 120s for celebrations)
   - Use static const String for each endpoint
   - Group them with comments matching the iOS structure exactly

2. lib/src/core/constants/app_constants.dart
   - All app-level constants from AppConstant.swift
   - SharedPreferences key names mapped from iOS UserDefaults keys:
     masterUID -> master_uid, grpId0 -> group_id_primary, grpId -> group_id,
     firstName -> first_name, middleName -> middle_name, lastName -> last_name,
     IMEI_Mem_Id -> imei_member_id, ClubName -> club_name, profileImg -> profile_image,
     memberIdss -> member_profile_id, DeviceToken -> device_token, isAdmin -> is_admin,
     user_auth_token_profileId -> auth_profile_id, user_auth_token_groupId -> auth_group_id
   - All other UserDefaults keys used in the iOS project

3. lib/src/core/constants/toast_constants.dart
   - All toast/alert messages used across the iOS app

STRICT RULES:
- Match EXACT endpoint paths from iOS (case-sensitive)
- No force unwraps anywhere
- Use private constructor pattern: ClassName._()
```

---

## iOS Source Files to Read
- `TouchBase/MISC/Constant/APIConstant.swift`
- `TouchBase/MISC/Constant/AppConstant.swift`
- `TouchBase/MISC/Constant/ToastConstant.swift`
- `api_details.md`

## Expected Output Files
- `lib/src/core/constants/api_constants.dart`
- `lib/src/core/constants/app_constants.dart`
- `lib/src/core/constants/toast_constants.dart`
