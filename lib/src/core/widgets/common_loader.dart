import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Full-screen loading overlay replacing iOS SVProgressHUD / MBProgressHUD /
/// ProgressBarShowHideViewController.
/// Usage: CommonLoader.show(context) and CommonLoader.dismiss(context).
class CommonLoader {
  CommonLoader._();

  static OverlayEntry? _overlayEntry;

  /// Show full-screen loading overlay.
  /// iOS: progressBarShow / SVProgressHUD.show()
  static void show(BuildContext context, {String? message}) {
    dismiss(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => _LoaderOverlay(message: message),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  /// Dismiss the loading overlay.
  /// iOS: progressBarHide / SVProgressHUD.dismiss()
  static void dismiss(BuildContext context) {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  /// Check if loader is currently showing.
  static bool get isShowing => _overlayEntry != null;
}

class _LoaderOverlay extends StatelessWidget {
  const _LoaderOverlay({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.black.withValues(alpha: 0.4),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _loaderChildren(message),
          ),
        ),
      ),
    );
  }
}

List<Widget> _loaderChildren(String? message) {
  final list = <Widget>[
    const CircularProgressIndicator(color: AppColors.primary),
  ];
  if (message != null) {
    list.add(const SizedBox(height: 16));
    list.add(
      Text(
        message,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
  return list;
}

/// Inline loading widget for use inside screens.
class CommonLoadingWidget extends StatelessWidget {
  const CommonLoadingWidget({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _loaderChildren(message),
      ),
    );
  }
}
