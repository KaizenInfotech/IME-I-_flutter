# Phase 6: Core Theme & App Colors

## Priority: 6
## Depends On: Phase 5

---

## Command Prompt

```
I am migrating an iOS app to Flutter.

Read these iOS source files:
1. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Classes/CommonClasses/CommonExtension.swift
   (Look for ALL hex color values, font definitions, UIColor extensions, text styling)
2. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Main.storyboard
   (Look for color definitions, font sizes, styling attributes)

Now create these files in /Users/ios2/Documents/Mani_mac_folder/touchbase_flutter/:

1. lib/src/core/theme/app_colors.dart
   - Extract EVERY hex color value used in the iOS project
   - Define as static const Color fields
   - Include: primary, secondary, accent, background, surface, error,
     text colors, border colors, shadow colors, status colors,
     navigation bar color, tab bar color, cell background colors
   - Match the EXACT same colors as iOS app

2. lib/src/core/theme/app_text_styles.dart
   - Extract ALL text styles from iOS (font family, sizes, weights)
   - iOS uses system font / Roboto - replicate exactly
   - Define heading1-6, body1-2, caption, button, label styles
   - Match EXACT same font sizes as iOS storyboard/code

3. lib/src/core/theme/app_theme.dart
   - Build complete ThemeData matching iOS app appearance
   - AppBar theme matching iOS navigation bar styling
   - InputDecoration theme matching iOS text field styling
   - Button themes matching iOS button styling
   - Card theme, list tile theme, dialog theme
   - Both light theme (primary) and dark theme if iOS supports it
   - Use the colors from app_colors.dart and styles from app_text_styles.dart

STRICT RULES:
- EXACT same colors as iOS app (extract hex values from code)
- EXACT same font sizes and weights
- No hardcoded values in theme - use app_colors and app_text_styles constants
```

---

## iOS Source Files to Read
- `TouchBase/Classes/CommonClasses/CommonExtension.swift` (hex colors, fonts)
- `TouchBase/Main.storyboard` (styling attributes)

## Expected Output Files
- `lib/src/core/theme/app_colors.dart`
- `lib/src/core/theme/app_text_styles.dart`
- `lib/src/core/theme/app_theme.dart`
