# Phase 5: Core Extensions & Utils

## Priority: 5
## Depends On: Phase 2

---

## Command Prompt

```
I am migrating an iOS app to Flutter.

Read these iOS source files:
1. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Classes/CommonClasses/CommonExtension.swift
2. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Classes/CommonClasses/ValidationExtension.swift
3. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/ImageLoader.swift
4. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/HttpDownloader.swift

Also read:
5. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/folder_details.md (Section 5.4: Extensions Mapping)

Now create these files in /Users/ios2/Documents/Mani_mac_folder/touchbase_flutter/:

1. lib/src/core/extensions/string_extensions.dart
   - Port ALL String extensions from CommonExtension.swift:
     isEmail validation, phone validation, trimming, isEmpty checks,
     URL validation, and any other string utility extensions
   - Use Dart extension syntax: extension StringExtension on String?

2. lib/src/core/extensions/date_extensions.dart
   - Port ALL date utility methods from CommonExtension.swift:
     functionForMonthWordWise, date formatting, date parsing,
     date comparison, relative date strings
   - Use intl package DateFormat where needed

3. lib/src/core/extensions/widget_extensions.dart
   - Port UIView extensions: ThreeDView shadow -> Card elevation
   - Port UITextField bottom border styling
   - Port UILabel styling helpers
   - Dart extension on Widget

4. lib/src/core/extensions/context_extensions.dart
   - Replace iOS CGRect screen size helpers (Iphone, Iphone5And5s, etc.)
   - Use MediaQuery.of(context).size
   - Provide: screenWidth, screenHeight, isSmallScreen, isTablet

5. lib/src/core/utils/validators.dart
   - Port ALL validation methods from ValidationExtension.swift
   - Email, phone, password, required field, min/max length validators
   - Return String? (null = valid, String = error message)

6. lib/src/core/utils/image_loader.dart
   - Replace iOS ImageLoader.swift and SDWebImage
   - Wrapper widget around CachedNetworkImage
   - Handle: placeholder, error widget, loading indicator
   - imageFromServerURL equivalent

7. lib/src/core/utils/file_downloader.dart
   - Replace iOS HttpDownloader.swift
   - Use http package streamed request for download with progress callback
   - Methods: downloadFile(url, savePath, onProgress)
   - Return downloaded file path

8. lib/src/core/utils/date_utils.dart
   - Port commonClassFunction date methods
   - Month name parsing, year extraction, date range helpers

STRICT RULES:
- Port EVERY extension method from iOS - don't skip any
- Follow the EXACT same validation logic and regex patterns
- All nullable, no force unwraps
- Use Dart null-safe patterns: ?.  ??  ?? ''
```

---

## iOS Source Files to Read
- `TouchBase/Classes/CommonClasses/CommonExtension.swift`
- `TouchBase/Classes/CommonClasses/ValidationExtension.swift`
- `TouchBase/ImageLoader.swift`
- `TouchBase/HttpDownloader.swift`
- `folder_details.md` (Section 5.4)

## Expected Output Files
- `lib/src/core/extensions/string_extensions.dart`
- `lib/src/core/extensions/date_extensions.dart`
- `lib/src/core/extensions/widget_extensions.dart`
- `lib/src/core/extensions/context_extensions.dart`
- `lib/src/core/utils/validators.dart`
- `lib/src/core/utils/image_loader.dart`
- `lib/src/core/utils/file_downloader.dart`
- `lib/src/core/utils/date_utils.dart`
