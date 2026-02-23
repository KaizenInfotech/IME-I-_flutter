import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_app_bar.dart';

/// Port of iOS ShowDocumentViewController / DocumentsDetailController WKWebView.
/// Displays PDF/document files using WebView or image viewer.
/// Supports both embedded mode (within DocumentDetailScreen) and standalone.
class DocumentViewerScreen extends StatefulWidget {
  const DocumentViewerScreen({
    super.key,
    required this.filePath,
    this.docType = 'pdf',
    this.title,
    this.embedded = false,
  });

  final String filePath;
  final String docType;
  final String? title;
  final bool embedded;

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            debugPrint('WebView error: ${error.description}');
            if (mounted) setState(() => _isLoading = false);
          },
        ),
      );

    _loadDocument();
  }

  void _loadDocument() {
    final file = File(widget.filePath);
    if (file.existsSync()) {
      // Load local file
      _controller.loadFile(widget.filePath);
    }
  }

  bool get _isImage {
    final type = widget.docType.toLowerCase();
    return type == 'jpg' ||
        type == 'jpeg' ||
        type == 'png' ||
        type == 'gif' ||
        type == '.jpg' ||
        type == '.jpeg' ||
        type == '.png' ||
        type == '.gif';
  }

  @override
  Widget build(BuildContext context) {
    final content = _isImage ? _buildImageViewer() : _buildWebViewer();

    if (widget.embedded) {
      return content;
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CommonAppBar(
        title: widget.title ?? 'Document',
      ),
      body: content,
    );
  }

  Widget _buildWebViewer() {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading)
          const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  Widget _buildImageViewer() {
    final file = File(widget.filePath);
    if (!file.existsSync()) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.broken_image,
                size: 64, color: AppColors.grayMedium),
            const SizedBox(height: 16),
            Text(
              'File not found',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,
      child: Center(
        child: Image.file(
          file,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => const Center(
            child: Icon(Icons.broken_image,
                size: 64, color: AppColors.grayMedium),
          ),
        ),
      ),
    );
  }
}
