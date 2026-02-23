import 'package:flutter/material.dart';

/// Port of iOS UIView/UITextField/UILabel/UIButton extensions from CommonExtension.swift.
/// Provides Flutter widget decoration helpers.

/// Port of iOS UIView.ThreeDView() — shadow/elevation.
extension ThreeDExtension on Widget {
  /// Wrap widget in a Card-like container matching iOS ThreeDView shadow.
  /// iOS: shadowColor=lightGray, opacity=2, offset=zero, radius=2
  Widget withThreeDShadow({
    double elevation = 2.0,
    Color shadowColor = Colors.grey,
    double borderRadius = 0.0,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.4),
            blurRadius: elevation * 2,
            spreadRadius: 0,
            offset: Offset.zero,
          ),
        ],
      ),
      child: this,
    );
  }
}

/// Input decoration helpers matching iOS UITextField border extensions.
class AppInputDecorations {
  AppInputDecorations._();

  /// iOS: functionForSetTextFieldBottomBorder
  /// Bottom-only underline border with light gray color.
  static InputDecoration bottomBorder({
    String? hintText,
    String? labelText,
  }) {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      border: const UnderlineInputBorder(
        borderSide: BorderSide(
          color: Color(0xFFCCCCCC), // iOS: 204/255
        ),
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(
          color: Color(0xFFCCCCCC),
        ),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(
          color: Color(0xFFFA6843), // iOS orange editing color: 250,104,67
        ),
      ),
    );
  }

  /// iOS: functionTextFieldFullBorder / functionForCornerRadiusWithFullBorder
  /// Full border with light gray color and optional corner radius.
  static InputDecoration fullBorder({
    String? hintText,
    String? labelText,
    double borderRadius = 1.0,
  }) {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(
          color: Colors.grey,
          width: 1.0,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(
          color: Colors.grey,
          width: 1.0,
        ),
      ),
    );
  }

  /// iOS: functionForSetRemoveTextFieldAllBorder
  /// No visible border.
  static InputDecoration noBorder({
    String? hintText,
    String? labelText,
  }) {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      border: InputBorder.none,
    );
  }
}

/// Button styling helpers matching iOS UIButton extensions.
class AppButtonStyles {
  AppButtonStyles._();

  /// iOS: setButtonFullBorder — white background, lightGray 1px border.
  static ButtonStyle fullBorder() {
    return OutlinedButton.styleFrom(
      foregroundColor: Colors.black,
      backgroundColor: Colors.white,
      side: const BorderSide(color: Colors.grey, width: 1.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(1.0),
      ),
    );
  }

  /// iOS: setButtonBackGroundColor — blue background with 5px radius.
  /// Color: rgb(24, 117, 210)
  static ButtonStyle primaryBlue() {
    return ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: const Color(0xFF1875D2), // 24/255, 117/255, 210/255
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      side: const BorderSide(
        color: Color(0xFF1875D2),
        width: 2.0,
      ),
    );
  }
}

/// iOS UILabel.LabelColor() — text color 102/255 gray.
const Color kLabelGrayColor = Color(0xFF666666);

/// iOS UITextField/UITextView border color — 204/255 gray.
const Color kBorderGrayColor = Color(0xFFCCCCCC);

/// iOS setButtonBackGroundColor primary blue.
const Color kPrimaryBlue = Color(0xFF1875D2);
