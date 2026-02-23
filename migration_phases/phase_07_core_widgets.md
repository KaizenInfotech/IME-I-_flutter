# Phase 7: Core Common Widgets

## Priority: 7
## Depends On: Phase 6

---

## Command Prompt

```
I am migrating an iOS app to Flutter.

Read these iOS source files:
1. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Classes/CommonClasses/NavigationSettings.swift
2. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Classes/CommonClasses/CommonExtension.swift
   (Look for: messageShowToast, ThreeDView, text field styling, alert helpers)
3. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/DatePicker/ (all files)
4. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/TopBarMessage/ (all files)
5. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Progressbar/ (all files)

Now create these files in /Users/ios2/Documents/Mani_mac_folder/touchbase_flutter/:

1. lib/src/core/widgets/common_app_bar.dart
   - Replace NavigationSettings.swift - custom AppBar matching iOS nav bar
   - Support: title, back button, right action buttons, custom colors
   - Match EXACT same navigation bar appearance as iOS

2. lib/src/core/widgets/common_loader.dart
   - Replace SVProgressHUD / MBProgressHUD
   - Full-screen loading overlay with spinner
   - Methods: show(context), dismiss(context)
   - Use flutter_easyloading or custom overlay

3. lib/src/core/widgets/common_toast.dart
   - Replace iOS messageShowToast extension
   - Use fluttertoast or ScaffoldMessenger.showSnackBar
   - Support: success, error, info toast types

4. lib/src/core/widgets/common_text_field.dart
   - Replace iOS UITextField with bottom border styling
   - functionForSetTextFieldBottomBorder equivalent
   - Props: label, hint, controller, validator, obscureText, keyboardType
   - UnderlineInputBorder matching iOS appearance

5. lib/src/core/widgets/common_button.dart
   - Standard styled button matching iOS app button design
   - Props: title, onPressed, isLoading, isDisabled, color, width

6. lib/src/core/widgets/common_picker.dart
   - Replace iOS UIPickerView
   - Dropdown/bottom sheet picker
   - Props: items, selectedValue, onChanged, hint

7. lib/src/core/widgets/common_date_picker.dart
   - Replace iOS UIDatePicker and custom DatePicker XIB
   - Use showDatePicker with custom theme
   - Support: date only, date+time, time only modes

8. lib/src/core/widgets/empty_state_widget.dart
   - Replace iOS "No Record" / "No Result Found" labels
   - Props: message, icon, onRetry

9. lib/src/core/widgets/search_bar_widget.dart
   - Replace iOS UISearchBar
   - TextField with search icon, clear button
   - Props: controller, onChanged, onSubmitted, hint

10. lib/src/core/widgets/webview_screen.dart
    - Replace iOS WKWebView / webViewCommonViewController
    - Full-screen WebView with AppBar
    - Props: url, title
    - Use webview_flutter package

11. lib/src/core/widgets/three_d_card.dart
    - Replace iOS ThreeDView() shadow extension
    - Card with elevation and shadow matching iOS appearance

STRICT RULES:
- Match EXACT same visual appearance as iOS widgets
- All callback parameters nullable where appropriate
- No force unwraps
- Every widget must be reusable across features
- Use Provider-compatible patterns (no setState for shared state)
```

---

## iOS Source Files to Read
- `TouchBase/Classes/CommonClasses/NavigationSettings.swift`
- `TouchBase/Classes/CommonClasses/CommonExtension.swift`
- `TouchBase/DatePicker/` (all files)
- `TouchBase/TopBarMessage/` (all files)
- `TouchBase/Progressbar/` (all files)

## Expected Output Files
- `lib/src/core/widgets/common_app_bar.dart`
- `lib/src/core/widgets/common_loader.dart`
- `lib/src/core/widgets/common_toast.dart`
- `lib/src/core/widgets/common_text_field.dart`
- `lib/src/core/widgets/common_button.dart`
- `lib/src/core/widgets/common_picker.dart`
- `lib/src/core/widgets/common_date_picker.dart`
- `lib/src/core/widgets/empty_state_widget.dart`
- `lib/src/core/widgets/search_bar_widget.dart`
- `lib/src/core/widgets/webview_screen.dart`
- `lib/src/core/widgets/three_d_card.dart`
