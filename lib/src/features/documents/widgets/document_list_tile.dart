import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/document_list_result.dart';

/// Port of iOS DocumentCell — table cell for document list.
/// Shows title (blue if unread), date, type icon, and action buttons.
class DocumentListTile extends StatelessWidget {
  const DocumentListTile({
    super.key,
    required this.document,
    this.onTap,
    this.onDownload,
    this.onDelete,
    this.isAdmin = false,
  });

  final DocumentItem document;
  final VoidCallback? onTap;
  final VoidCallback? onDownload;
  final VoidCallback? onDelete;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(
            bottom: BorderSide(color: AppColors.divider, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            // Document type icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _iconBackgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  _documentIcon,
                  color: AppColors.white,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Title and date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.docTitle ?? 'Untitled',
                    style: AppTextStyles.body2.copyWith(
                      // iOS: blue text = unread, black = read
                      color: document.hasBeenRead
                          ? AppColors.textPrimary
                          : AppColors.primaryBlue,
                      fontWeight: document.hasBeenRead
                          ? FontWeight.w400
                          : FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    document.createDateTime ?? '',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),

            // Action buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (document.isDownloadable)
                  IconButton(
                    icon: const Icon(Icons.download,
                        color: AppColors.primary, size: 22),
                    onPressed: onDownload ?? onTap,
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                if (isAdmin)
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.systemRed, size: 22),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData get _documentIcon {
    if (document.isPdf) return Icons.picture_as_pdf;
    if (document.isImage) return Icons.image;
    final type = document.docType?.toLowerCase() ?? '';
    if (type.contains('doc') || type.contains('word')) return Icons.description;
    if (type.contains('xls') || type.contains('excel')) return Icons.table_chart;
    if (type.contains('ppt')) return Icons.slideshow;
    return Icons.insert_drive_file;
  }

  Color get _iconBackgroundColor {
    if (document.isPdf) return const Color(0xFFE74C3C);
    if (document.isImage) return AppColors.green;
    final type = document.docType?.toLowerCase() ?? '';
    if (type.contains('doc') || type.contains('word')) {
      return AppColors.primaryBlue;
    }
    if (type.contains('xls') || type.contains('excel')) {
      return const Color(0xFF27AE60);
    }
    if (type.contains('ppt')) return AppColors.orange;
    return AppColors.gray;
  }
}
