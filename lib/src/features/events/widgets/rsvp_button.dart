import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// iOS RSVP response type.
/// iOS: "0"=going(yes), "1"=maybe, "2"=not going(no)
enum RsvpResponse { yes, no, maybe }

/// Port of iOS buttonYes/buttonNo/buttonMayBe — RSVP action buttons.
/// Shows three buttons: Yes (green), No (red), Maybe (gray).
/// Highlights the user's current response.
class RsvpButtonRow extends StatelessWidget {
  const RsvpButtonRow({
    super.key,
    required this.currentResponse,
    required this.goingCount,
    required this.notgoingCount,
    required this.maybeCount,
    required this.onResponse,
    this.isEnabled = true,
  });

  final String? currentResponse;
  final String? goingCount;
  final String? notgoingCount;
  final String? maybeCount;
  final void Function(RsvpResponse response) onResponse;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _RsvpButton(
            label: 'Yes',
            count: goingCount ?? '0',
            icon: Icons.check_circle_outline,
            color: const Color(0xFF4CAF50),
            isSelected: currentResponse == '0',
            onTap: isEnabled ? () => onResponse(RsvpResponse.yes) : null,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _RsvpButton(
            label: 'No',
            count: notgoingCount ?? '0',
            icon: Icons.cancel_outlined,
            color: const Color(0xFFFF4C4D),
            isSelected: currentResponse == '2',
            onTap: isEnabled ? () => onResponse(RsvpResponse.no) : null,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _RsvpButton(
            label: 'Maybe',
            count: maybeCount ?? '0',
            icon: Icons.help_outline,
            color: const Color(0xFF727272),
            isSelected: currentResponse == '1',
            onTap: isEnabled ? () => onResponse(RsvpResponse.maybe) : null,
          ),
        ),
      ],
    );
  }
}

class _RsvpButton extends StatelessWidget {
  const _RsvpButton({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
    required this.isSelected,
    this.onTap,
  });

  final String label;
  final String count;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? color : AppColors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? color : AppColors.border,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.white : color,
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                '$label ($count)',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.white : color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
