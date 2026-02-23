import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Replaces iOS UIView.ThreeDView() shadow extension.
/// Card with elevation and shadow matching iOS appearance:
/// shadowColor=lightGray, opacity=2, offset=zero, radius=2.
class ThreeDCard extends StatelessWidget {
  const ThreeDCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 8,
    this.elevation = 2,
    this.color,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double elevation;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.3),
            blurRadius: elevation * 2,
            spreadRadius: 0,
            offset: Offset.zero,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: padding != null
            ? Padding(padding: padding!, child: child)
            : child,
      ),
    );

    if (onTap != null) {
      card = GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}
