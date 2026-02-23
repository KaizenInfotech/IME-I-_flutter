# Phase 25: Web Links Feature

## Priority: 25
## Depends On: Phase 10

---

## Command Prompt

```
I am migrating an iOS app to Flutter.

Read these iOS source files CAREFULLY:
1. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/WebLink/WebLinkListViewController.swift
2. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/WebLink/WebLinkWebViewViewController.swift
3. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/WebLink/CustomWebLinkCell.swift

Read WebserviceClass.swift for:
4. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/ServiceManager/WebserviceClass.swift
   Search for: getWebLinksList method

Now create in /Users/ios2/Documents/Mani_mac_folder/touchbase_flutter/:

MODELS:
1. lib/src/features/web_links/models/web_link_result.dart
   - Web link list response model
   - All fields nullable
   - fromJson/toJson

PROVIDERS:
2. lib/src/features/web_links/providers/web_links_provider.dart
   - State: webLinks list, selectedLink, isLoading, error
   - Methods: fetchWebLinks()

SCREENS:
3. lib/src/features/web_links/screens/web_links_screen.dart - list of web links
4. lib/src/features/web_links/screens/web_link_detail_screen.dart - WebView to display link

WIDGETS:
5. lib/src/features/web_links/widgets/web_link_tile.dart

STRICT RULES:
- EXACT same API endpoints and UI as iOS
- ALL nullable, NO force unwraps
- Provider + Consumer + FutureBuilder
```

---

## iOS Source Files to Read
- `TouchBase/Controllers/WebLink/` (all 3 files)
- `WebserviceClass.swift` (getWebLinksList)

## Expected Output Files
- `lib/src/features/web_links/models/web_link_result.dart`
- `lib/src/features/web_links/providers/web_links_provider.dart`
- `lib/src/features/web_links/screens/web_links_screen.dart`
- `lib/src/features/web_links/screens/web_link_detail_screen.dart`
- `lib/src/features/web_links/widgets/web_link_tile.dart`
