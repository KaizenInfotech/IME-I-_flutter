# Phase 8: Core Base Model

## Priority: 8
## Depends On: Phase 3

---

## Command Prompt

```
I am migrating an iOS app to Flutter.

Read this reference:
1. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/api_details.md (Section 6: Dart Models and Section 8: Error Handling)

Now create these files in /Users/ios2/Documents/Mani_mac_folder/touchbase_flutter/:

1. lib/src/core/models/api_response_model.dart
   - Generic API response wrapper matching iOS JSON response structure
   - Fields: int? status, String? message, dynamic data
   - Factory: fromJson(Map<String, dynamic> json)
   - The iOS API returns JSON with top-level "status"/"message" and nested data
   - All fields nullable

2. lib/src/core/models/base_model.dart
   - Abstract base class for all feature models
   - Abstract fromJson factory pattern
   - toJson method
   - Helper: safe type casting methods
     safeString(dynamic value) -> String?
     safeInt(dynamic value) -> int?
     safeDouble(dynamic value) -> double?
     safeBool(dynamic value) -> bool?
     safeList<T>(dynamic value, T Function(Map<String,dynamic>) fromJson) -> List<T>?
   - These helpers prevent force unwrap crashes when API returns unexpected types

STRICT RULES:
- All fields nullable
- No force unwraps
- Safe type casting for all JSON parsing
- Match the EXACT response structure of the iOS API
```

---

## Reference Files to Read
- `api_details.md` (Section 6 and Section 8)

## Expected Output Files
- `lib/src/core/models/api_response_model.dart`
- `lib/src/core/models/base_model.dart`
