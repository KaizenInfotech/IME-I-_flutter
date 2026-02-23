import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_toast.dart';
import '../models/event_detail_result.dart';

/// Port of iOS EventDetailScreenShotViewController.swift — screenshot sharing.
/// Renders event details in a scrollable layout, captures as image,
/// and allows sharing via activity sheet.
class EventScreenshotScreen extends StatefulWidget {
  const EventScreenshotScreen({
    super.key,
    required this.event,
  });

  final EventsDetail event;

  @override
  State<EventScreenshotScreen> createState() => _EventScreenshotScreenState();
}

class _EventScreenshotScreenState extends State<EventScreenshotScreen> {
  final GlobalKey _repaintKey = GlobalKey();

  /// iOS: createImage() — capture widget as image
  Future<void> _captureAndShare() async {
    try {
      final boundary = _repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      if (!mounted) return;
      // In a full implementation, use share_plus to share pngBytes
      CommonToast.success(
          context, 'Screenshot captured (${pngBytes.length} bytes)');
    } catch (e) {
      if (!mounted) return;
      CommonToast.error(context, 'Failed to capture screenshot');
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textOnPrimary),
        title: const Text(
          'Event Screenshot',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 17,
            fontWeight: FontWeight.w400,
            color: AppColors.textOnPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon:
                const Icon(Icons.share, color: AppColors.textOnPrimary),
            onPressed: _captureAndShare,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: RepaintBoundary(
          key: _repaintKey,
          child: Container(
            color: AppColors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event image — iOS: row 0
                if (event.hasValidImage)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      event.eventImg!.replaceAll(' ', '%20'),
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          const SizedBox(height: 0),
                    ),
                  ),
                if (event.hasValidImage) const SizedBox(height: 16),
                // Title — iOS: row 2
                Text(
                  event.eventTitle ?? '',
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                // Description — iOS: row 3
                if (event.eventDesc != null && event.eventDesc!.isNotEmpty)
                  Text(
                    event.eventDesc!,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                const SizedBox(height: 12),
                // Venue — iOS: row 4
                if (event.venue != null && event.venue!.isNotEmpty)
                  _buildDetailRow(Icons.location_on, event.venue!),
                // Date — iOS: row 5
                if (event.eventDateTime != null &&
                    event.eventDateTime!.isNotEmpty)
                  _buildDetailRow(
                      Icons.calendar_today, event.eventDateTime!),
                // Link — iOS: row 6
                if (event.hasLink)
                  _buildDetailRow(Icons.link, event.link!),
                const SizedBox(height: 16),
                // RSVP counts — iOS: row 7
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCountChip(
                      'Yes',
                      event.goingCount ?? '0',
                      const Color(0xFF4CAF50),
                    ),
                    _buildCountChip(
                      'No',
                      event.notgoingCount ?? '0',
                      const Color(0xFFFF4C4D),
                    ),
                    _buildCountChip(
                      'Maybe',
                      event.maybeCount ?? '0',
                      AppColors.gray,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountChip(String label, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(76)),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
