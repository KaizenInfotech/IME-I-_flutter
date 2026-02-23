import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Custom AppBar replacing iOS NavigationSettings.swift.
/// Matches iOS nav bar: purple/blue background, white text, centered title.
class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CommonAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.onBackPressed,
    this.actions,
    this.backgroundColor,
    this.titleColor,
    this.elevation = 0,
    this.centerTitle = true,
    this.leading,
    this.bottom,
  });

  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? titleColor;
  final double elevation;
  final bool centerTitle;
  final Widget? leading;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? AppColors.primary,
      foregroundColor: titleColor ?? AppColors.textOnPrimary,
      elevation: elevation,
      centerTitle: centerTitle,
      title: Text(
        title,
        style: AppTextStyles.navTitle.copyWith(
          color: titleColor ?? AppColors.textOnPrimary,
        ),
      ),
      leading: leading ??
          (showBackButton
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 20),
                  onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                )
              : null),
      automaticallyImplyLeading: showBackButton,
      actions: actions,
      bottom: bottom,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    );
  }
}
