import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/common_toast.dart';

/// Port of iOS MonthlyPDFViewWebViewController.
/// Displays PDFs via WebView — supports both local files and remote URLs.
class MonthlyPdfViewScreen extends StatefulWidget {
  const MonthlyPdfViewScreen({
    super.key,
    required this.urlStr,
    this.isLocalFile = false,
    this.moduleName = 'Document',
  });

  /// File path (local) or URL (remote).
  final String urlStr;
  final bool isLocalFile;
  final String moduleName;

  @override
  State<MonthlyPdfViewScreen> createState() => _MonthlyPdfViewScreenState();
}

class _MonthlyPdfViewScreenState extends State<MonthlyPdfViewScreen> {
  late WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            if (mounted) {
              setState(() => _isLoading = false);
              CommonToast.error(context,
                  'Failed to load document. Please check your connection.');
            }
          },
        ),
      );

    _loadContent();
  }

  void _loadContent() {
    if (widget.isLocalFile) {
      // iOS: loads local file from Documents directory
      final file = File(widget.urlStr);
      if (file.existsSync()) {
        _controller.loadFile(file.path);
      }
    } else {
      // iOS: loads remote URL, adds http:// if no scheme
      var url = widget.urlStr;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'http://$url';
      }
      // iOS: replaces spaces with %20
      url = url.replaceAll(' ', '%20');
      _controller.loadRequest(Uri.parse(url));
    }
  }

  /// iOS: share button using UIActivityViewController
  void _shareDocument() {
    if (widget.isLocalFile) {
      Share.shareXFiles([XFile(widget.urlStr)]);
    } else {
      Share.share(widget.urlStr);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CommonAppBar(
        title: widget.moduleName,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: AppColors.textOnPrimary),
            onPressed: _shareDocument,
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
