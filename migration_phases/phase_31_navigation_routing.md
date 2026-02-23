# Phase 31: Navigation & Routing (GoRouter)

## Priority: 31
## Depends On: All feature phases (11-30)

---

## Command Prompt

```
I am migrating an iOS app to Flutter.

Read this reference:
1. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/folder_details.md (Section 8: Navigation Mapping)

Also read the iOS storyboard for navigation flow:
2. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Main.storyboard

Now create in /Users/ios2/Documents/Mani_mac_folder/touchbase_flutter/:

1. lib/src/core/navigation/app_router.dart
   - Use go_router package
   - Define EVERY route matching the iOS navigation tree:

     AUTH ROUTES:
     /login -> /otp -> /welcome

     MAIN ROUTES (after auth):
     /dashboard (main shell with drawer)
       /dashboard/customize
       /dashboard/admin-modules

     FEATURE ROUTES:
       /directory -> /directory/profile/:id -> /directory/edit/:id
       /events -> /events/:id -> /events/add
       /celebrations -> /celebrations/birthday -> /celebrations/district-event/:id
       /announcements -> /announcements/:id -> /announcements/add
       /gallery -> /gallery/album/:id -> /gallery/add-photo -> /gallery/create-album
       /documents -> /documents/:id -> /documents/view/:id
       /ebulletin -> /ebulletin/:id -> /ebulletin/add
       /attendance -> /attendance/detail
       /find-rotarian -> /find-rotarian/profile/:id
       /find-club -> /find-club/:id
       /service-directory -> /service-directory/category/:id
       /subgroups -> /subgroups/:id
       /district -> /district/member/:id -> /district/club-members/:id
       /leaderboard
       /web-links -> /web-links/:id
       /notifications -> /notifications/settings
       /settings -> /settings/group
       /profile -> /profile/edit-family -> /profile/edit-address -> /profile/change-request
       /monthly-report -> /monthly-report/view/:id
       /maps/address

   - Auth guard: redirect to /login if not authenticated
     Check SharedPreferences for masterUID - if null, redirect to login
   - All route parameters are nullable String?
   - Error/404 page with "Page not found" message and back button
   - Import ALL screen widgets from their respective feature folders

STRICT RULES:
- EXACT same navigation flow as iOS storyboard
- Every iOS push/present transition must have a GoRouter equivalent
- Auth guard must check SharedPreferences for masterUID
- NO force unwraps on route parameters
- All route parameter access uses nullable types
```

---

## Reference Files to Read
- `folder_details.md` (Section 8: Navigation Mapping)
- `TouchBase/Main.storyboard` (navigation flows)

## Expected Output Files
- `lib/src/core/navigation/app_router.dart`
