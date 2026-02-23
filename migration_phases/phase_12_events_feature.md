# Phase 12: Events Feature

## Priority: 12
## Depends On: Phase 10

---

## Command Prompt

```
I am migrating an iOS app to Flutter.

Read these iOS source files CAREFULLY:
1. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/EventsDetailController/EventsDetailController.swift
2. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/EventsDetailController/EventDetailScreenShotViewController.swift
3. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/EventsDetailController/CompletedActivitiesViewController.swift
4. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/ADDViewControllers/Add_Events/ (ALL files)
5. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/SegmentMemberFamily/ClubEventsListViewController.swift
6. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/EventDetailNotiViewController.swift
7. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/NationalEventDetailViewController.swift
8. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/EventAnnouncementwebViewViewController.swift

Read WebserviceClass.swift for these methods:
9. getEventDetails, getEventList, addEventsResult (AddEvent_New), answeringEvent, getSmscountdetails

Read Obj-C models:
10. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/ControllerObjectiveC/ (find EventListDetailResult, EventsListDetailResult, AddEventResult, EventJoinResult folders)

Also read:
11. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/folder_details.md (Section 4.4)

Now create in /Users/ios2/Documents/Mani_mac_folder/touchbase_flutter/:

MODELS:
1. lib/src/features/events/models/event_list_result.dart - all nullable
2. lib/src/features/events/models/event_detail_result.dart - all nullable
3. lib/src/features/events/models/add_event_result.dart - all nullable
4. lib/src/features/events/models/event_join_result.dart - all nullable

PROVIDERS:
5. lib/src/features/events/providers/events_provider.dart
   - State: events list, selectedEvent, isLoading, error
   - Methods matching EXACT iOS: fetchEventList(), fetchEventDetail(),
     addEvent() (with ALL 25+ parameters from iOS), answerEvent() (RSVP),
     getSmsCount(), shareEventPdf()

SCREENS:
6. lib/src/features/events/screens/events_list_screen.dart - match iOS event listing exactly
7. lib/src/features/events/screens/event_detail_screen.dart - match iOS EventsDetailController exactly
8. lib/src/features/events/screens/add_event_screen.dart - match iOS Add_Events with ALL form fields
9. lib/src/features/events/screens/event_screenshot_screen.dart - match iOS screenshot sharing
10. lib/src/features/events/screens/completed_activities_screen.dart - past events list

WIDGETS:
11. lib/src/features/events/widgets/event_card.dart
12. lib/src/features/events/widgets/rsvp_button.dart
13. lib/src/features/events/widgets/event_share_sheet.dart

STRICT RULES:
- EXACT same API endpoints, parameters, and logic as iOS
- AddEvent must have ALL 25+ parameters from iOS addEventsResult method
- EXACT same RSVP/question-answer flow as iOS
- ALL nullable, NO force unwraps
- Provider + Consumer + FutureBuilder
```

---

## iOS Source Files to Read
- `TouchBase/Controllers/EventsDetailController/` (all files)
- `TouchBase/Controllers/ADDViewControllers/Add_Events/` (ALL files)
- `TouchBase/Controllers/SegmentMemberFamily/ClubEventsListViewController.swift`
- `TouchBase/EventDetailNotiViewController.swift`
- `TouchBase/NationalEventDetailViewController.swift`
- `WebserviceClass.swift` (event methods)
- `ControllerObjectiveC/` (event result folders)
- `folder_details.md` (Section 4.4)

## Expected Output Files
- `lib/src/features/events/models/event_list_result.dart`
- `lib/src/features/events/models/event_detail_result.dart`
- `lib/src/features/events/models/add_event_result.dart`
- `lib/src/features/events/models/event_join_result.dart`
- `lib/src/features/events/providers/events_provider.dart`
- `lib/src/features/events/screens/events_list_screen.dart`
- `lib/src/features/events/screens/event_detail_screen.dart`
- `lib/src/features/events/screens/add_event_screen.dart`
- `lib/src/features/events/screens/event_screenshot_screen.dart`
- `lib/src/features/events/screens/completed_activities_screen.dart`
- `lib/src/features/events/widgets/event_card.dart`
- `lib/src/features/events/widgets/rsvp_button.dart`
- `lib/src/features/events/widgets/event_share_sheet.dart`
