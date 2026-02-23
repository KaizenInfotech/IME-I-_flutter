# Phase 30: Monthly Report & Maps Features

## Priority: 30
## Depends On: Phase 10

---

## Command Prompt

```
I am migrating an iOS app to Flutter.

Read these iOS source files:
1. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/MontlyPDFListViewControllerViewController.swift
2. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/MonthlyPDFViewWebViewController.swift
3. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/mapNew/MapAddressViewController.swift
4. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/mapNew/GooglePlaceApi/ (ALL files)

Read WebserviceClass.swift for any monthly report related methods:
5. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/ServiceManager/WebserviceClass.swift

Now create in /Users/ios2/Documents/Mani_mac_folder/touchbase_flutter/:

MONTHLY REPORT:
1. lib/src/features/monthly_report/providers/monthly_report_provider.dart
   - State: reports list, selectedReport, isLoading, error
   - Methods: fetchMonthlyReports()
   - EXACT same API calls as iOS

2. lib/src/features/monthly_report/screens/monthly_pdf_list_screen.dart
   - List of monthly PDF reports
   - Match iOS MontlyPDFListViewControllerViewController layout

3. lib/src/features/monthly_report/screens/monthly_pdf_view_screen.dart
   - PDF viewer using webview_flutter or flutter_pdfview
   - Match iOS MonthlyPDFViewWebViewController

MAPS:
4. lib/src/features/maps/providers/map_provider.dart
   - Google Places API logic matching iOS GooglePlaceApi exactly
   - State: selectedAddress, searchResults, selectedLocation, isLoading, error
   - Methods: searchPlaces(), getPlaceDetails(), reverseGeocode()

5. lib/src/features/maps/screens/map_address_screen.dart
   - Google Map with pin selection
   - Address search using Google Places API
   - Match iOS MapAddressViewController layout

6. lib/src/features/maps/widgets/map_view_widget.dart
   - Reusable Google Map widget
   - Use google_maps_flutter package

STRICT RULES:
- EXACT same API calls, Google Places logic, PDF viewing as iOS
- ALL nullable, NO force unwraps
- Provider + Consumer + FutureBuilder
```

---

## iOS Source Files to Read
- `TouchBase/MontlyPDFListViewControllerViewController.swift`
- `TouchBase/MonthlyPDFViewWebViewController.swift`
- `TouchBase/Controllers/mapNew/MapAddressViewController.swift`
- `TouchBase/Controllers/mapNew/GooglePlaceApi/` (ALL files)
- `WebserviceClass.swift` (monthly report methods)

## Expected Output Files
- `lib/src/features/monthly_report/providers/monthly_report_provider.dart`
- `lib/src/features/monthly_report/screens/monthly_pdf_list_screen.dart`
- `lib/src/features/monthly_report/screens/monthly_pdf_view_screen.dart`
- `lib/src/features/maps/providers/map_provider.dart`
- `lib/src/features/maps/screens/map_address_screen.dart`
- `lib/src/features/maps/widgets/map_view_widget.dart`
