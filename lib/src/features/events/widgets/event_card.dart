import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/event_list_result.dart';

/// Port of iOS ClubEventsDetailsTableViewCell — event list card.
/// Shows: event image, title, date, venue, RSVP counts, user response badge.
class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  final EventListItem event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: event.hasValidImage
                  ? Image.network(
                      event.eventImg!.replaceAll(' ', '%20'),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _placeholderImage(),
                    )
                  : _placeholderImage(),
            ),
            const SizedBox(width: 12),
            // Event details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    event.eventTitle ?? '',
                    style: const TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Date — iOS: displays formatted date
                  if (event.eventDateTime != null &&
                      event.eventDateTime!.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 13, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.displayDateTime,
                            style: const TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 2),
                  // Venue
                  if (event.venue != null && event.venue!.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 13, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.venue!,
                            style: const TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 6),
                  // RSVP counts row
                  _buildRsvpRow(),
                ],
              ),
            ),
            // User response badge
            if (event.myResponse != null && event.myResponse!.isNotEmpty)
              _buildResponseBadge(event.myResponse!),
          ],
        ),
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.backgroundGray,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.event, color: AppColors.grayMedium, size: 32),
    );
  }

  /// iOS: goingCount, maybeCount, notgoingCount labels
  Widget _buildRsvpRow() {
    return Row(
      children: [
        _rsvpChip(
          'Yes ${event.goingCount ?? '0'}',
          const Color(0xFF4CAF50),
        ),
        const SizedBox(width: 6),
        _rsvpChip(
          'No ${event.notgoingCount ?? '0'}',
          const Color(0xFFFF4C4D),
        ),
        const SizedBox(width: 6),
        _rsvpChip(
          'Maybe ${event.maybeCount ?? '0'}',
          AppColors.gray,
        ),
      ],
    );
  }

  Widget _rsvpChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  /// iOS: myResponse badge — "0"=going(green), "1"=maybe(gray), "2"=not going(red)
  Widget _buildResponseBadge(String response) {
    Color color;
    String label;
    switch (response) {
      case '0':
        color = const Color(0xFF4CAF50);
        label = 'Going';
        break;
      case '1':
        color = AppColors.gray;
        label = 'Maybe';
        break;
      case '2':
        color = const Color(0xFFFF4C4D);
        label = 'Not Going';
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(76)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
