import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Port of iOS CollapsibleTableViewHeader — expandable/collapsible section.
/// Tapping the header toggles child visibility with animation.
class CollapsibleSection extends StatefulWidget {
  const CollapsibleSection({
    super.key,
    required this.title,
    this.initiallyExpanded = true,
    this.onToggle,
    required this.child,
    this.headerColor,
    this.titleStyle,
  });

  final String title;
  final bool initiallyExpanded;
  final ValueChanged<bool>? onToggle;
  final Widget child;
  final Color? headerColor;
  final TextStyle? titleStyle;

  @override
  State<CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<CollapsibleSection>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _controller;
  late Animation<double> _heightFactor;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _heightFactor = _controller.drive(CurveTween(curve: Curves.easeInOut));
    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
      widget.onToggle?.call(_isExpanded);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // iOS: CollapsibleTableViewHeader — tappable header bar
        GestureDetector(
          onTap: _toggle,
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            color: widget.headerColor ??
                const Color(0xFFCCCCCC), // iOS: rgb(204,204,204)
            alignment: Alignment.center,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: widget.titleStyle ??
                        const TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textPrimary,
                        ),
                  ),
                ),
                AnimatedRotation(
                  turns: _isExpanded ? 0.25 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Animated content — iOS: collapsed == true → height 0
        ClipRect(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Align(
                alignment: Alignment.topCenter,
                heightFactor: _heightFactor.value,
                child: child,
              );
            },
            child: widget.child,
          ),
        ),
      ],
    );
  }
}
