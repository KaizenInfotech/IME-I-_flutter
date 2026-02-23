# Phase 4: Core Storage (SharedPreferences + SQLite + Secure Storage)

## Priority: 4
## Depends On: Phase 2

---

## Command Prompt

```
I am migrating an iOS app to Flutter.

Read these iOS source files:
1. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Classes/CommonClasses/CommonUserDefault.swift
2. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Classes/CommonClasses/CommonSqlite.swift
3. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/DataBase/DBmanager.swift
4. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/DataBase/ModelManager.swift
5. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/DataBase/Util.swift
6. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/DataBase/CalendarInfo.swift
7. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/DataBase/StudentInfo.swift

Also read:
8. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/api_details.md (Section 10: Offline & Caching Strategy)
9. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/folder_details.md (Section 10: Database & Local Storage Mapping)

Now create these files in /Users/ios2/Documents/Mani_mac_folder/touchbase_flutter/:

1. lib/src/core/storage/local_storage.dart
   - Singleton wrapper around SharedPreferences
   - Getter/setter for EVERY UserDefaults key used in iOS project:
     masterUid, groupIdPrimary, groupId, firstName, middleName, lastName,
     imeiMemberId, clubName, profileImage, memberProfileId, deviceToken,
     isAdmin, authProfileId, authGroupId, and ALL others found in iOS code
   - All getters return nullable types (String?, int?, bool?)
   - Methods: init(), clear(), saveLoginData(), getLoginData()
   - No force unwraps

2. lib/src/core/storage/secure_storage.dart
   - Wrapper around flutter_secure_storage
   - Store sensitive data: auth tokens, device token
   - Methods: saveToken(), getToken(), deleteToken(), clearAll()
   - All returns nullable

3. lib/src/core/storage/database_helper.dart
   - Singleton wrapper around sqflite
   - Match EXACT same SQLite tables from iOS FMDB:
     a. GROUPMASTER table (same columns as iOS)
     b. MODULE_DATA_MASTER table (same columns as iOS)
     c. Notification_Table (same columns as iOS)
   - CRUD methods for each table matching the iOS CommonSqlite methods exactly
   - onCreate, onUpgrade handlers
   - All query results return nullable types
   - No force unwraps

STRICT RULES:
- EXACT same table schemas as iOS SQLite
- EXACT same UserDefaults key mappings
- All nullable, no force unwraps
```

---

## iOS Source Files to Read
- `TouchBase/Classes/CommonClasses/CommonUserDefault.swift`
- `TouchBase/Classes/CommonClasses/CommonSqlite.swift`
- `TouchBase/DataBase/DBmanager.swift`
- `TouchBase/DataBase/ModelManager.swift`
- `TouchBase/DataBase/Util.swift`
- `TouchBase/DataBase/CalendarInfo.swift`
- `TouchBase/DataBase/StudentInfo.swift`
- `api_details.md` (Section 10)
- `folder_details.md` (Section 10)

## Expected Output Files
- `lib/src/core/storage/local_storage.dart`
- `lib/src/core/storage/secure_storage.dart`
- `lib/src/core/storage/database_helper.dart`
