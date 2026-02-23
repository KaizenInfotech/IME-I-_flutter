import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Standard styled button matching iOS app button design.
/// Port of iOS setButtonBackGroundColor (primary) and setButtonFullBorder (outlined).
class CommonButton extends StatelessWidget {
  const CommonButton({
    super.key,
    required this.title,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.color,
    this.textColor,
    this.width,
    this.height = 48,
    this.borderRadius = 5,
    this.isOutlined = false,
    this.icon,
  });

  final String title;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final Color? color;
  final Color? textColor;
  final double? width;
  final double height;
  final double borderRadius;

  /// false = filled button (iOS setButtonBackGroundColor).
  /// true = outlined button (iOS setButtonFullBorder).
  final bool isOutlined;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? AppColors.primary;
    final foreground = textColor ??
        (isOutlined ? AppColors.textPrimary : AppColors.textOnPrimary);

    final child = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: foreground,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: foreground),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: AppTextStyles.button.copyWith(color: foreground),
              ),
            ],
          );

    if (isOutlined) {
      return SizedBox(
        width: width,
        height: height,
        child: OutlinedButton(
          onPressed: (isDisabled || isLoading) ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: foreground,
            side: BorderSide(color: isDisabled ? AppColors.border : buttonColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: (isDisabled || isLoading) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: foreground,
          backgroundColor: isDisabled ? AppColors.grayMedium : buttonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 2,
        ),
        child: child,
      ),
    );
  }
}
