# Phase 18: Attendance Feature

## Priority: 18
## Depends On: Phase 10

---

## Command Prompt

```
I am migrating an iOS app to Flutter.

Read these iOS source files CAREFULLY:
1. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/AttendanceViewController/AttendanceViewController.swift
2. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/AttendanceViewController/ChartClasses/ (ALL files)
3. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/AttendanceViewController/SubModules/ (ALL files)

Read WebserviceClass.swift for:
4. getAttendanceList method

Now create in /Users/ios2/Documents/Mani_mac_folder/touchbase_flutter/:

MODELS:
1. lib/src/features/attendance/models/attendance_result.dart
   - All fields nullable
   - fromJson/toJson

PROVIDERS:
2. lib/src/features/attendance/providers/attendance_provider.dart
   - State: attendanceList, selectedEvent, chartData, isLoading, error
   - Methods: fetchAttendanceList(), EXACT same as iOS getAttendanceList

SCREENS:
3. lib/src/features/attendance/screens/attendance_screen.dart - event picker + attendance list
4. lib/src/features/attendance/screens/attendance_detail_screen.dart

WIDGETS:
5. lib/src/features/attendance/widgets/attendance_chart.dart - pie chart using fl_chart package
6. lib/src/features/attendance/widgets/monthly_report_tile.dart

STRICT RULES:
- EXACT same API endpoints, chart logic, and UI as iOS
- ALL nullable, NO force unwraps
- Provider + Consumer + FutureBuilder
```

---

## iOS Source Files to Read
- `TouchBase/Controllers/AttendanceViewController/AttendanceViewController.swift`
- `TouchBase/Controllers/AttendanceViewController/ChartClasses/` (ALL files)
- `TouchBase/Controllers/AttendanceViewController/SubModules/` (ALL files)
- `WebserviceClass.swift` (getAttendanceList)

## Expected Output Files
- `lib/src/features/attendance/models/attendance_result.dart`
- `lib/src/features/attendance/providers/attendance_provider.dart`
- `lib/src/features/attendance/screens/attendance_screen.dart`
- `lib/src/features/attendance/screens/attendance_detail_screen.dart`
- `lib/src/features/attendance/widgets/attendance_chart.dart`
- `lib/src/features/attendance/widgets/monthly_report_tile.dart`
