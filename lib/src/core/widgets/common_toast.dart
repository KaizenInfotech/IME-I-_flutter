import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Replaces iOS UIView.messageShowToast and AGPushNoteView.
/// Uses ScaffoldMessenger.showSnackBar for toast messages.
class CommonToast {
  CommonToast._();

  /// Show a success toast (green).
  static void success(BuildContext context, String message) {
    _show(context, message, AppColors.green, Icons.check_circle);
  }

  /// Show an error toast (red).
  static void error(BuildContext context, String message) {
    _show(context, message, AppColors.systemRed, Icons.error);
  }

  /// Show an info toast (primary blue).
  static void info(BuildContext context, String message) {
    _show(context, message, AppColors.primaryBlue, Icons.info);
  }

  /// Show a warning toast (orange).
  static void warning(BuildContext context, String message) {
    _show(context, message, AppColors.orange, Icons.warning);
  }

  /// Show a plain toast matching iOS messageShowToast (2 second, center).
  static void show(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, textAlign: TextAlign.center),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  static void _show(
    BuildContext context,
    String message,
    Color backgroundColor,
    IconData icon,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: AppColors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: AppColors.white),
                ),
              ),
            ],
          ),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
  }

  /// Dismiss current toast.
  static void dismiss(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }
}
