import 'package:flutter/material.dart';

/// All colors extracted from the iOS project.
/// Sources: CommonExtension.swift, Main.storyboard, controller files.
class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════════════════
  // PRIMARY / BRAND
  // ═══════════════════════════════════════════════════════

  /// iOS: UIColor(red: 40/255, green: 27/255, blue: 146/255) — primary purple.
  /// Used for buttons, tint colors, borders, nav bars, highlights.
  static const Color primary = Color(0xFF281B92);

  /// iOS: UIColor(red: 24/255, green: 117/255, blue: 210/255) — navigation blue.
  /// Used for nav bar background, button backgrounds.
  static const Color primaryBlue = Color(0xFF1875D2);

  /// iOS: #00AEEF — cyan accent.
  /// Used for LeaderBoard, Dashboard highlights, links.
  static const Color accent = Color(0xFF00AEEF);

  // ═══════════════════════════════════════════════════════
  // GREENS (Success / Positive)
  // ═══════════════════════════════════════════════════════

  /// iOS: UIColor(red: 76/255, green: 176/255, blue: 80/255) — action green.
  static const Color green = Color(0xFF4CB050);

  /// iOS: UIColor(red: 76/255, green: 176/255, blue: 80/255) — action mail.
  static const Color mail =  Color(0xFF00AEEF);


  /// iOS: UIColor(red: 76/255, green: 217/255, blue: 100/255) — bright green (toolbar).
  static const Color greenBright = Color(0xFF4CD964);

  /// iOS: #29B49B — teal green (TRF/Member background).
  static const Color teal = Color(0xFF29B49B);

  /// iOS: Storyboard green (red=0.120, green=0.642, blue=0.138).
  static const Color greenDark = Color(0xFF1EA422);

  // ═══════════════════════════════════════════════════════
  // REDS / ORANGES (Error / Warning)
  // ═══════════════════════════════════════════════════════

  /// iOS: UIColor(red: 250/255, green: 104/255, blue: 67/255) — orange-red.
  /// Used for editing highlights, bottom borders.
  static const Color orangeRed = Color(0xFFFA6843);

  /// iOS: #FA5951 — coral red.
  static const Color coralRed = Color(0xFFFA5951);

  /// iOS: #FF3B30 — iOS system red (calendar present selected).
  static const Color systemRed = Color(0xFFFF3B30);

  /// iOS: #E74C3C — calendar red.
  static const Color calendarRed = Color(0xFFE74C3C);

  /// iOS: #FF5E3A — orange-red (calendar present highlighted).
  static const Color calendarOrangeRed = Color(0xFFFF5E3A);

  /// iOS: UIColor(red: 235/255, green: 151/255, blue: 27/255) — orange shadow.
  static const Color orange = Color(0xFFEB971B);

  // ═══════════════════════════════════════════════════════
  // BLUES
  // ═══════════════════════════════════════════════════════

  /// iOS: #34AADC — light blue (calendar weekday highlighted).
  static const Color calendarBlue = Color(0xFF34AADC);

  /// iOS: #1D62F0 — blue (calendar weekday selected).
  static const Color calendarSelectedBlue = Color(0xFF1D62F0);

  /// iOS: Storyboard (red=0.155, green=0.531, blue=0.813).
  static const Color storyboardBlue = Color(0xFF2885CF);

  // ═══════════════════════════════════════════════════════
  // GRAYS
  // ═══════════════════════════════════════════════════════

  /// iOS: UIColor(red: 102/255, green: 102/255, blue: 102/255) — label gray.
  static const Color textSecondary = Color(0xFF666666);

  /// iOS: #696969 — dim gray (announcement text).
  static const Color textTertiary = Color(0xFF696969);

  /// iOS: #808080 — medium gray (HTML text).
  static const Color gray = Color(0xFF808080);

  /// iOS: UIColor(red: 182/255, green: 182/255, blue: 182/255) — medium gray text.
  static const Color grayMedium = Color(0xFFB6B6B6);

  /// iOS: UIColor(red: 204/255, green: 204/255, blue: 204/255) — border gray.
  static const Color border = Color(0xFFCCCCCC);

  /// iOS: UIColor(red: 209/255, green: 209/255, blue: 209/255) — very light gray.
  static const Color grayLight = Color(0xFFD1D1D1);

  /// iOS: Storyboard (0.84, 0.84, 0.84) — divider gray.
  static const Color divider = Color(0xFFD6D6D6);

  /// iOS: Storyboard (0.89, 0.89, 0.89) — light gray background.
  static const Color backgroundGray = Color(0xFFE3E3E3);

  /// iOS: Storyboard gray (0.333, 0.333, 0.333) — ~85,85,85.
  static const Color grayDark = Color(0xFF555555);

  /// iOS: Storyboard gray (0.667, 0.667, 0.667) — ~170,170,170.
  static const Color graySubtle = Color(0xFFAAAAAA);

  // ═══════════════════════════════════════════════════════
  // BACKGROUND / SURFACE
  // ═══════════════════════════════════════════════════════

  /// White background.
  static const Color background = Color(0xFFFFFFFF);

  /// iOS: Very light gray page background.
  static const Color scaffoldBackground = Color(0xFFF5F5F5);

  /// White surface (cards, cells).
  static const Color surface = Color(0xFFFFFFFF);

  // ═══════════════════════════════════════════════════════
  // TEXT
  // ═══════════════════════════════════════════════════════

  /// Primary text — black.
  static const Color textPrimary = Color(0xFF000000);

  /// iOS: Storyboard gray-blue (0.361, 0.388, 0.404).
  static const Color textHint = Color(0xFF5C6367);

  /// White text on dark backgrounds.
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ═══════════════════════════════════════════════════════
  // CONVENIENCE
  // ═══════════════════════════════════════════════════════

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);

  /// iOS shadow color: UIColor.lightGray.
  static const Color shadow = Colors.grey;
}
