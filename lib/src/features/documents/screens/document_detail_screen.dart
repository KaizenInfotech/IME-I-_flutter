import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/common_toast.dart';
import '../models/document_list_result.dart';
import '../providers/documents_provider.dart';
import '../widgets/download_progress.dart';
import 'document_viewer_screen.dart';

/// Port of iOS DocumentsDetailController — document detail with download + view.
/// Downloads document, marks as read, then shows in viewer.
class DocumentDetailScreen extends StatefulWidget {
  const DocumentDetailScreen({
    super.key,
    required this.document,
    this.profileId = '',
    this.isAdmin = false,
  });

  final DocumentItem document;
  final String profileId;
  final bool isAdmin;

  @override
  State<DocumentDetailScreen> createState() => _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends State<DocumentDetailScreen> {
  String? _localFilePath;

  @override
  void initState() {
    super.initState();
    _downloadAndView();
  }

  Future<void> _downloadAndView() async {
    if (!widget.document.hasValidUrl) return;

    final provider = context.read<DocumentsProvider>();

    // Mark as read (iOS: functionForUpdateReadStatus)
    provider.updateDocumentIsRead(
      docId: widget.document.docID ?? '',
      memberProfileId: widget.profileId,
    );

    // Download
    final filePath = await provider.downloadDocument(
      url: widget.document.docURL!,
      docId: widget.document.docID ?? 'doc',
      docType: widget.document.docType ?? 'pdf',
    );

    if (!mounted) return;

    if (filePath != null) {
      setState(() => _localFilePath = filePath);
    } else {
      CommonToast.error(context, 'Failed to download document');
    }
  }

  Future<void> _deleteDocument() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text(
            'Are you sure you want to delete "${widget.document.docTitle}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.systemRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final success = await context.read<DocumentsProvider>().deleteDocument(
          docId: widget.document.docID ?? '',
          profileId: widget.profileId,
        );

    if (!mounted) return;
    if (success) {
      CommonToast.success(context, 'Document deleted');
      Navigator.pop(context);
    } else {
      CommonToast.error(context, 'Failed to delete document');
    }
  }

  void _shareDocument() {
    if (_localFilePath != null) {
      Share.shareXFiles([XFile(_localFilePath!)]);
    } else if (widget.document.hasValidUrl) {
      Share.share(widget.document.docURL!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CommonAppBar(
        title: widget.document.docTitle ?? 'Document',
        actions: [
          // Share button (iOS: createNavigationBarAfterDocLoad)
          if (_localFilePath != null)
            IconButton(
              icon:
                  const Icon(Icons.share, color: AppColors.textOnPrimary),
              onPressed: _shareDocument,
            ),
          // Delete button (admin only)
          if (widget.isAdmin)
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.textOnPrimary),
              onPressed: _deleteDocument,
            ),
        ],
      ),
      body: Consumer<DocumentsProvider>(
        builder: (context, provider, _) {
          if (provider.isDownloading) {
            return DownloadProgressWidget(
              progress: provider.downloadProgress,
              message: 'Downloading document...',
            );
          }

          if (_localFilePath != null) {
            return DocumentViewerScreen(
              filePath: _localFilePath!,
              docType: widget.document.docType ?? '',
              embedded: true,
            );
          }

          // Fallback: show document info
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.document.isPdf
                        ? Icons.picture_as_pdf
                        : Icons.insert_drive_file,
                    size: 64,
                    color: AppColors.grayMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.document.docTitle ?? 'Document',
                    style: AppTextStyles.heading5,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.document.createDateTime ?? '',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 24),
                  if (widget.document.hasValidUrl)
                    ElevatedButton.icon(
                      onPressed: _downloadAndView,
                      icon: const Icon(Icons.download),
                      label: const Text('Download'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
