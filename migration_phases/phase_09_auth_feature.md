# Phase 9: Auth Feature (Login + OTP + Welcome)

## Priority: 9
## Depends On: Phases 3, 4, 7, 8

---

## Command Prompt

```
I am migrating an iOS app to Flutter.

Read these iOS source files CAREFULLY - follow the EXACT same logic:
1. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/ServiceManager/WebserviceClass.swift
   (Read the signinTapped, OTPverify, getAllGroupsWelcome, MemberDetail methods - find them by searching for these function names)
2. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/ControllerObjectiveC/LoginResult/ (ALL files)
3. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/CountyCodes.plist
4. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Main.storyboard
   (Find the Login and OTP view controller scenes for exact UI layout)

Also read:
5. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/api_details.md (Section 4: Authentication Flow)
6. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/folder_details.md (Section 4.1: Authentication Feature)

Now create these files in /Users/ios2/Documents/Mani_mac_folder/touchbase_flutter/:

MODELS:
1. lib/src/features/auth/models/login_result.dart
   - Match EXACT structure of iOS LoginResult + LoginResultResponse Obj-C models
   - Nested: LoginResultData -> Ds -> List<LoginTable>
   - LoginTable fields: masterUID, grpid0, firstName, middleName, lastName,
     mobileNo, IMEI_Mem_Id, profileImg, memberIdss, isAdmin, and ALL other fields from iOS
   - ALL fields nullable (String?, int?, etc.)
   - fromJson/toJson for each class

2. lib/src/features/auth/models/otp_result.dart
   - Match iOS OTP verification response structure exactly
   - All fields nullable

PROVIDERS:
3. lib/src/features/auth/providers/auth_provider.dart
   - Extends ChangeNotifier
   - State fields: LoginResult? loginResult, bool isLoading, String? error,
     List<dynamic>? welcomeGroups, bool isOtpSent
   - Methods (match EXACT same API calls and parameters as iOS):
     a. login(String? mobileNumber, String? countryCode, String? loginType)
        -> POST to Login/UserLogin with EXACT same params as signinTapped()
        -> Uses postUrlEncoded (URLEncoding like iOS)
     b. verifyOtp(String? otp, String? mobileNumber, String? masterUID)
        -> POST to Login/PostOTP with EXACT same params as OTPverify()
     c. getWelcomeGroups(String? masterUID)
        -> POST to Login/GetWelcomeScreen with EXACT same params
     d. getMemberDetails(String? masterUID, String? grpID)
        -> POST to Login/GetMemberDetails with EXACT same params
     e. saveLoginDataToLocal() -> save to SharedPreferences
     f. logout() -> clear storage, reset state
   - Use FutureBuilder-compatible pattern: expose Future methods + state fields
   - notifyListeners() after every state change

SCREENS:
4. lib/src/features/auth/screens/login_screen.dart
   - Match EXACT same UI layout as iOS Login ViewController from storyboard
   - Country code picker + mobile number field
   - Login button triggers provider.login()
   - Use Consumer<AuthProvider> for reactive UI
   - Use FutureBuilder where appropriate for async operations
   - Show CommonLoader during API call
   - Show CommonToast for errors
   - Navigate to OTP screen on success

5. lib/src/features/auth/screens/otp_screen.dart
   - Match EXACT same UI as iOS OTP ViewController
   - OTP input field (4 or 6 digit)
   - Verify button triggers provider.verifyOtp()
   - Resend OTP option
   - Consumer<AuthProvider> for reactive UI
   - Navigate to Welcome screen on success

6. lib/src/features/auth/screens/welcome_screen.dart
   - Match EXACT same UI as iOS Welcome/Group selection screen
   - Show list of groups user belongs to
   - User selects primary group
   - Save selection to local storage
   - Navigate to Dashboard on selection

WIDGETS:
7. lib/src/features/auth/widgets/country_code_picker.dart
   - Replace iOS UIPickerView for country codes
   - Load from country codes data
   - Bottom sheet with searchable list

8. lib/src/features/auth/widgets/otp_input_field.dart
   - OTP text field with individual boxes
   - Auto-focus next box on input

STRICT RULES:
- EXACT same API endpoints as iOS
- EXACT same request parameter names and values as iOS
- EXACT same business logic flow as iOS
- ALL model fields nullable
- NO force unwraps
- Use Provider (ChangeNotifier) + Consumer + FutureBuilder
- Match the visual design from iOS storyboard
```

---

## iOS Source Files to Read
- `TouchBase/ServiceManager/WebserviceClass.swift` (signinTapped, OTPverify, getAllGroupsWelcome, MemberDetail)
- `TouchBase/Controllers/ControllerObjectiveC/LoginResult/` (ALL files)
- `TouchBase/CountyCodes.plist`
- `TouchBase/Main.storyboard` (Login/OTP scenes)
- `api_details.md` (Section 4)
- `folder_details.md` (Section 4.1)

## Expected Output Files
- `lib/src/features/auth/models/login_result.dart`
- `lib/src/features/auth/models/otp_result.dart`
- `lib/src/features/auth/providers/auth_provider.dart`
- `lib/src/features/auth/screens/login_screen.dart`
- `lib/src/features/auth/screens/otp_screen.dart`
- `lib/src/features/auth/screens/welcome_screen.dart`
- `lib/src/features/auth/widgets/country_code_picker.dart`
- `lib/src/features/auth/widgets/otp_input_field.dart`
