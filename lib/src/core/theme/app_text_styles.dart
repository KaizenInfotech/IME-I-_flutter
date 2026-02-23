import 'package:flutter/material.dart';

import 'app_colors.dart';

/// All text styles extracted from the iOS project.
/// iOS primary font: Roboto (Regular, Medium, Bold).
/// Sources: CommonExtension.swift font helpers, Main.storyboard, controller files.
class AppTextStyles {
  AppTextStyles._();

  // ═══════════════════════════════════════════════════════
  // FONT FAMILY (iOS: "Roboto" — registered in storyboard)
  // ═══════════════════════════════════════════════════════

  static const String fontFamily = 'Roboto';

  // ═══════════════════════════════════════════════════════
  // HEADINGS
  // ═══════════════════════════════════════════════════════

  /// Large title — iOS: Roboto-Regular 35pt.
  static const TextStyle heading1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 35,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// Section title — iOS: Roboto-Regular 28-30pt.
  static const TextStyle heading2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// Screen title — iOS: Roboto-Bold 22-23pt.
  static const TextStyle heading3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// Card title — iOS: Roboto-Medium 20pt.
  static const TextStyle heading4 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  /// Subsection — iOS: Roboto-Medium 18pt.
  static const TextStyle heading5 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  /// Small heading — iOS: Roboto-Bold 16-17pt.
  static const TextStyle heading6 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  // ═══════════════════════════════════════════════════════
  // BODY
  // ═══════════════════════════════════════════════════════

  /// Primary body — iOS: Roboto-Regular 17pt (most common body size).
  static const TextStyle body1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// Secondary body — iOS: Roboto-Regular 15pt (default from helpers).
  /// Matches iOS labelFontfamilyAndSize / textfieldFontfamilyAndSize.
  static const TextStyle body2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// Small body — iOS: Roboto-Regular 14pt.
  static const TextStyle body3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  // ═══════════════════════════════════════════════════════
  // CAPTION / LABEL
  // ═══════════════════════════════════════════════════════

  /// Caption — iOS: Roboto-Regular 12pt.
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// Small caption — iOS: Roboto-Regular 10pt.
  static const TextStyle captionSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// Overline — iOS: Roboto-Medium 12pt.
  static const TextStyle overline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );

  // ═══════════════════════════════════════════════════════
  // BUTTON
  // ═══════════════════════════════════════════════════════

  /// Primary button — iOS: Roboto-Medium 16pt / OpenSans-Semibold 15-18pt.
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textOnPrimary,
  );

  /// Small button — iOS: Roboto-Regular 14pt.
  static const TextStyle buttonSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textOnPrimary,
  );

  // ═══════════════════════════════════════════════════════
  // LABEL (iOS: UILabel.LabelColor gray text)
  // ═══════════════════════════════════════════════════════

  /// Gray label — iOS: UILabel.LabelColor, Roboto 15pt.
  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// Medium label — iOS: Roboto-Medium 15pt.
  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  // ═══════════════════════════════════════════════════════
  // NAVIGATION
  // ═══════════════════════════════════════════════════════

  /// Nav bar title — iOS: Roboto-Regular 18-20pt white.
  static const TextStyle navTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textOnPrimary,
  );

  /// Tab bar label — iOS: system 10-12pt.
  static const TextStyle tabLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  // ═══════════════════════════════════════════════════════
  // INPUT
  // ═══════════════════════════════════════════════════════

  /// Text field — iOS: Roboto-Regular 15pt (from textfieldFontfamilyAndSize).
  static const TextStyle input = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// Text field hint — iOS: gray Roboto 15pt.
  static const TextStyle inputHint = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textHint,
  );
}
