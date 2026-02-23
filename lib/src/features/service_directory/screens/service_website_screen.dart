import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_app_bar.dart';

/// Port of iOS WebSiteViewController / WebSiteNewViewController —
/// WebView screen for displaying service directory website.
class ServiceWebsiteScreen extends StatefulWidget {
  const ServiceWebsiteScreen({
    super.key,
    required this.url,
    this.title = 'Website',
  });

  final String url;
  final String title;

  @override
  State<ServiceWebsiteScreen> createState() => _ServiceWebsiteScreenState();
}

class _ServiceWebsiteScreenState extends State<ServiceWebsiteScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    var normalizedUrl = widget.url.trim();
    if (!normalizedUrl.startsWith('http')) {
      normalizedUrl = 'https://$normalizedUrl';
    }

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
          onWebResourceError: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(normalizedUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CommonAppBar(title: widget.title),
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
