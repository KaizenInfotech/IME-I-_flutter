import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/notification_model.dart';

/// Port of iOS NotificationCell — notification list item.
/// Shows type icon, message, entity name, date, and read/unread styling.
class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.item,
    this.onTap,
    this.onDismissed,
  });

  final NotificationItem item;
  final VoidCallback? onTap;
  final VoidCallback? onDismissed;

  IconData _iconForType(String? type) {
    switch (type) {
      case 'Event':
        return Icons.event;
      case 'Calender':
        return Icons.calendar_month_rounded;
      case 'ann':
        return Icons.campaign;
      case 'Ebulle':
        return Icons.article;
      case 'Doc':
        return Icons.description;
      case 'Activity':
        return Icons.volunteer_activism;
      case 'Gallery':
        return Icons.photo_library;
      case 'PopupNoti':
        return Icons.celebration;
      default:
        return Icons.notifications;
    }
  }

  static const _iconColor = Color.fromARGB(255, 108, 106, 106);

  @override
  Widget build(BuildContext context) {
    final isUnread = item.isUnread;
    const typeColor = _iconColor;

    return Dismissible(
      key: ValueKey(item.msgId ?? UniqueKey()),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismissed?.call(),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isUnread
                ? const Color(0xFFF0F0F0)
                : AppColors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: Offset.zero,
              ),
            ],
          ),
          child: Row(
            children: [
              // Type icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipOval(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: item.type == 'Event'
                        ? Image.asset('assets/images/events_noti.png',
                            width: 24, height: 24)
                        : Icon(_iconForType(item.type),
                            color: typeColor, size: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.displayMessage,
                      style: AppTextStyles.body2.copyWith(
                        fontWeight:
                            isUnread ? FontWeight.w800 : FontWeight.w300,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.entityName.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.entityName,
                        style: AppTextStyles.captionSmall
                            .copyWith(color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      item.notifyDate ?? '',
                      style: AppTextStyles.captionSmall
                          .copyWith(color: AppColors.grayMedium),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
