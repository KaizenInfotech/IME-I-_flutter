import 'package:flutter/material.dart';

/// Port of iOS CGRect extensions and CGFloat.methodForGetCurrentDeviceWidthAndHeight.
/// Replaces hardcoded iPhone/iPad sizes with responsive MediaQuery values.
extension ContextExtension on BuildContext {
  /// iOS: CGFloat.methodForGetCurrentDeviceWidthAndHeight — screen width.
  double get screenWidth => MediaQuery.of(this).size.width;

  /// iOS: CGFloat.methodForGetCurrentDeviceWidthAndHeight — screen height.
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Screen size object.
  Size get screenSize => MediaQuery.of(this).size;

  /// iOS: CGRect.Iphone5And5s — small screen (width <= 320).
  bool get isSmallScreen => screenWidth <= 320;

  /// iOS: CGRect.Iphone6And6s — medium screen (width ~375).
  bool get isMediumScreen => screenWidth > 320 && screenWidth <= 375;

  /// iOS: CGRect.Iphone6Plus / Iphone7Plus — large screen (width ~414).
  bool get isLargeScreen => screenWidth > 375 && screenWidth <= 414;

  /// iOS: CGRect.Ipad — tablet (width >= 768).
  bool get isTablet => screenWidth >= 768;

  /// Safe area padding.
  EdgeInsets get safeAreaPadding => MediaQuery.of(this).padding;

  /// Status bar height.
  double get statusBarHeight => MediaQuery.of(this).padding.top;

  /// Bottom safe area (home indicator on notch devices).
  double get bottomSafeArea => MediaQuery.of(this).padding.bottom;

  /// Keyboard height.
  double get keyboardHeight => MediaQuery.of(this).viewInsets.bottom;

  /// Whether keyboard is visible.
  bool get isKeyboardVisible => MediaQuery.of(this).viewInsets.bottom > 0;

  /// Theme data shortcut.
  ThemeData get theme => Theme.of(this);

  /// Text theme shortcut.
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Color scheme shortcut.
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Show a SnackBar toast — replaces iOS UIView.messageShowToast.
  void showToast(String message, {Duration? duration}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration ?? const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Dismiss the current SnackBar.
  void hideToast() {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
  }
}
