import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/event_detail_result.dart';

/// Port of iOS shareButtonClickEvent — share event bottom sheet.
/// Provides share options: Share Text, Share Image, Share PDF.
class EventShareSheet extends StatelessWidget {
  const EventShareSheet({
    super.key,
    required this.event,
    this.onShareText,
    this.onShareImage,
    this.onSharePdf,
  });

  final EventsDetail event;
  final VoidCallback? onShareText;
  final VoidCallback? onShareImage;
  final VoidCallback? onSharePdf;

  /// Show as bottom sheet — iOS: UIAlertController with actionSheet style
  static void show(
    BuildContext context, {
    required EventsDetail event,
    VoidCallback? onShareText,
    VoidCallback? onShareImage,
    VoidCallback? onSharePdf,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => EventShareSheet(
        event: event,
        onShareText: onShareText,
        onShareImage: onShareImage,
        onSharePdf: onSharePdf,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grayMedium,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Share Event',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            // Share text option
            _buildShareOption(
              context,
              icon: Icons.text_snippet_outlined,
              label: 'Share as Text',
              color: AppColors.primaryBlue,
              onTap: onShareText,
            ),
            // Share image option — iOS: takeScreenshot
            _buildShareOption(
              context,
              icon: Icons.image_outlined,
              label: 'Share as Image',
              color: AppColors.green,
              onTap: onShareImage,
            ),
            // Share PDF option — iOS: pdfDataWithTableView
            _buildShareOption(
              context,
              icon: Icons.picture_as_pdf_outlined,
              label: 'Share as PDF',
              color: AppColors.orange,
              onTap: onSharePdf,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 15,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: const Icon(Icons.chevron_right,
          color: AppColors.primary, size: 22),
      onTap: () {
        Navigator.of(context).pop();
        onTap?.call();
      },
    );
  }
}
