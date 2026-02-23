import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

/// Complete ThemeData matching the iOS app appearance.
/// Uses colors from AppColors and styles from AppTextStyles.
class AppTheme {
  AppTheme._();

  // ═══════════════════════════════════════════════════════
  // LIGHT THEME (Primary)
  // ═══════════════════════════════════════════════════════

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTextStyles.fontFamily,
      brightness: Brightness.light,

      // Color scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        error: AppColors.systemRed,
        onPrimary: AppColors.textOnPrimary,
        onSecondary: AppColors.textOnPrimary,
        onSurface: AppColors.textPrimary,
        onError: AppColors.textOnPrimary,
      ),

      scaffoldBackgroundColor: AppColors.scaffoldBackground,

      // AppBar — iOS: purple/blue nav bar with white text
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.navTitle,
        iconTheme: IconThemeData(color: AppColors.textOnPrimary),
        actionsIconTheme: IconThemeData(color: AppColors.textOnPrimary),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      // Bottom navigation — iOS tab bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.gray,
        selectedLabelStyle: AppTextStyles.tabLabel,
        unselectedLabelStyle: AppTextStyles.tabLabel,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Card — iOS: white surface with shadow
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 2,
        shadowColor: AppColors.shadow.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      // Input decoration — iOS: bottom border text fields (Roboto 15pt)
      inputDecorationTheme: const InputDecorationTheme(
        filled: false,
        contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 12),
        hintStyle: AppTextStyles.inputHint,
        labelStyle: AppTextStyles.label,
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.systemRed),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.systemRed, width: 2),
        ),
      ),

      // Elevated button — iOS: setButtonBackGroundColor (blue, 5px radius)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColors.textOnPrimary,
          backgroundColor: AppColors.primary,
          textStyle: AppTextStyles.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          elevation: 2,
        ),
      ),

      // Outlined button — iOS: setButtonFullBorder (white bg, gray border)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          backgroundColor: AppColors.surface,
          textStyle: AppTextStyles.button.copyWith(color: AppColors.textPrimary),
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),

      // Text button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.button.copyWith(color: AppColors.primary),
        ),
      ),

      // Floating action button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 4,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        titleTextStyle: AppTextStyles.heading5,
        contentTextStyle: AppTextStyles.body2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // ListTile
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
        titleTextStyle: AppTextStyles.body1,
        subtitleTextStyle: AppTextStyles.label,
        iconColor: AppColors.textSecondary,
      ),

      // Divider — iOS: light gray separators
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 0.5,
        space: 0,
      ),

      // SnackBar — replaces iOS toast
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: AppTextStyles.body2.copyWith(
          color: AppColors.textOnPrimary,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // TabBar
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.textOnPrimary,
        unselectedLabelColor: AppColors.graySubtle,
        labelStyle: AppTextStyles.tabLabel,
        unselectedLabelStyle: AppTextStyles.tabLabel,
        indicatorColor: AppColors.textOnPrimary,
      ),

      // Checkbox / Switch
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.border;
        }),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.grayMedium;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary.withValues(alpha: 0.5);
          }
          return AppColors.border;
        }),
      ),

      // Progress indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.border,
      ),

      // Text theme
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.heading1,
        displayMedium: AppTextStyles.heading2,
        displaySmall: AppTextStyles.heading3,
        headlineMedium: AppTextStyles.heading4,
        headlineSmall: AppTextStyles.heading5,
        titleLarge: AppTextStyles.heading6,
        titleMedium: AppTextStyles.body1,
        titleSmall: AppTextStyles.body2,
        bodyLarge: AppTextStyles.body1,
        bodyMedium: AppTextStyles.body2,
        bodySmall: AppTextStyles.body3,
        labelLarge: AppTextStyles.button,
        labelMedium: AppTextStyles.label,
        labelSmall: AppTextStyles.caption,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // DARK THEME
  // ═══════════════════════════════════════════════════════

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTextStyles.fontFamily,
      brightness: Brightness.dark,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        secondary: AppColors.primary,
        surface: Color(0xFF1E1E1E),
        error: AppColors.systemRed,
        onPrimary: AppColors.textPrimary,
        onSecondary: AppColors.textOnPrimary,
        onSurface: AppColors.textOnPrimary,
        onError: AppColors.textOnPrimary,
      ),

      scaffoldBackgroundColor: const Color(0xFF121212),

      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.navTitle.copyWith(
          color: AppColors.textOnPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textOnPrimary),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        hintStyle: AppTextStyles.inputHint.copyWith(
          color: AppColors.graySubtle,
        ),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.grayDark),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.grayDark),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.accent, width: 2),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          backgroundColor: AppColors.accent,
          textStyle: AppTextStyles.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),

      textTheme: TextTheme(
        displayLarge: AppTextStyles.heading1.copyWith(color: AppColors.white),
        displayMedium: AppTextStyles.heading2.copyWith(color: AppColors.white),
        displaySmall: AppTextStyles.heading3.copyWith(color: AppColors.white),
        headlineMedium:
            AppTextStyles.heading4.copyWith(color: AppColors.white),
        headlineSmall:
            AppTextStyles.heading5.copyWith(color: AppColors.white),
        titleLarge: AppTextStyles.heading6.copyWith(color: AppColors.white),
        titleMedium: AppTextStyles.body1.copyWith(color: AppColors.white),
        titleSmall: AppTextStyles.body2.copyWith(color: AppColors.white),
        bodyLarge: AppTextStyles.body1.copyWith(color: AppColors.white),
        bodyMedium: AppTextStyles.body2.copyWith(color: AppColors.white),
        bodySmall:
            AppTextStyles.body3.copyWith(color: AppColors.graySubtle),
        labelLarge: AppTextStyles.button.copyWith(color: AppColors.white),
        labelMedium:
            AppTextStyles.label.copyWith(color: AppColors.graySubtle),
        labelSmall:
            AppTextStyles.caption.copyWith(color: AppColors.graySubtle),
      ),
    );
  }
}
