import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_app_bar.dart';

/// Port of iOS AdminListWebViewViewController.swift.
/// Simple full-screen WKWebView that loads a URL with a title in the nav bar.
/// Used by admin module listing to display web-based admin content.
class AdminWebViewScreen extends StatefulWidget {
  const AdminWebViewScreen({
    super.key,
    required this.url,
    this.title,
  });

  final String url;
  final String? title;

  @override
  State<AdminWebViewScreen> createState() => _AdminWebViewScreenState();
}

class _AdminWebViewScreenState extends State<AdminWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // iOS: sanitize URL (strip "Optional(" prefix if present)
    String urlStr = widget.url;
    if (urlStr.startsWith('Optional(')) {
      urlStr = urlStr.substring(10);
      if (urlStr.endsWith(')')) {
        urlStr = urlStr.substring(0, urlStr.length - 2);
      }
    }

    // Ensure scheme
    if (!urlStr.contains('http')) {
      urlStr = 'http://$urlStr';
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(urlStr));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: widget.title ?? ''),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const LinearProgressIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.border,
            ),
        ],
      ),
    );
  }
}
