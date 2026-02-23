# Phase 33: Section Table & Remaining Shared Components

## Priority: 33
## Depends On: Phase 32

---

## Command Prompt

```
I am migrating an iOS app to Flutter.

Read these iOS source files:
1. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/SectionTable/MultipleSectionTableViewController.swift
2. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/SectionTable/CollapsibleTableViewHeader.swift
3. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/SectionTable/customTableMultiSection.swift
4. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/MainDashBoardWithSidebar/RotaryBlogs/ (ALL files)
5. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/MainDashBoardWithSidebar/RotaryNews/ (ALL files)
6. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/AdminListWebViewViewController.swift
7. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/webViewCommonViewController.swift

Also read the complete ViewController mapping table:
8. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/folder_details.md (Section 7: Swift ViewController to Flutter Widget Mapping Table - ALL 60 entries)

Now create any MISSING widgets/screens in /Users/ios2/Documents/Mani_mac_folder/touchbase_flutter/:

1. lib/src/core/widgets/collapsible_section.dart
   - Expandable/collapsible table section header
   - Match iOS CollapsibleTableViewHeader behavior
   - Props: title, isExpanded, onToggle, child

2. lib/src/core/widgets/multiple_section_list.dart
   - Grouped list with collapsible sections
   - Match iOS MultipleSectionTableViewController
   - Props: sections list with title + items

3. Any missing screens that were not covered in previous phases.
   Review the COMPLETE mapping table (all 60 ViewControllers) from folder_details.md Section 7.
   For each iOS ViewController in the table, verify a Flutter screen exists.
   If ANY are missing, create them now:

   Likely missing screens to check:
   - Rotary blogs screen (from RotaryBlogs/)
   - Rotary news screen (from RotaryNews/)
   - Admin WebView screen (from AdminListWebViewViewController)
   - Jito profile screen (from JitoProfileViewController)
   - Club events list screen (from ClubEventsListViewController)
   - National event detail screen (from NationalEventDetailViewController)
   - Common WebView screen (from webViewCommonViewController)
   - Event announcement WebView screen (from EventAnnouncementwebViewViewController)

   For each missing screen:
   - Read the iOS source file
   - Create the Flutter equivalent with EXACT same logic
   - Place in the appropriate feature folder
   - Use Provider + Consumer + FutureBuilder pattern

STRICT RULES:
- No iOS screen should be missing from the Flutter project
- ALL nullable, NO force unwraps
- Provider + Consumer + FutureBuilder
- Match EXACT same logic as iOS for every screen
```

---

## iOS Source Files to Read
- `TouchBase/Controllers/SectionTable/` (all 3 files)
- `TouchBase/Controllers/MainDashBoardWithSidebar/RotaryBlogs/` (ALL files)
- `TouchBase/Controllers/MainDashBoardWithSidebar/RotaryNews/` (ALL files)
- `TouchBase/AdminListWebViewViewController.swift`
- `TouchBase/webViewCommonViewController.swift`
- `folder_details.md` (Section 7 - complete 60-VC mapping table)

## Expected Output Files
- `lib/src/core/widgets/collapsible_section.dart`
- `lib/src/core/widgets/multiple_section_list.dart`
- Any missing feature screens identified from the mapping table audit
