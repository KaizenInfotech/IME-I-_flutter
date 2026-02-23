import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../models/web_link_result.dart';

/// Port of iOS WebLinkWebViewViewController — shows web link detail.
/// Displays title, clickable URL button, and HTML description in WebView.
class WebLinkDetailScreen extends StatefulWidget {
  const WebLinkDetailScreen({
    super.key,
    required this.item,
    this.moduleName = 'Web Links',
  });

  final WebLinkItem item;
  final String moduleName;

  @override
  State<WebLinkDetailScreen> createState() => _WebLinkDetailScreenState();
}

class _WebLinkDetailScreenState extends State<WebLinkDetailScreen> {
  late final WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white);

    if (widget.item.hasDescription) {
      _webViewController.loadHtmlString(widget.item.fullDesc!);
    }
  }

  Future<void> _openUrl() async {
    final urlStr = widget.item.linkUrl;
    if (urlStr == null || urlStr.isEmpty) return;

    var normalized = urlStr;
    if (!normalized.startsWith('http://') &&
        !normalized.startsWith('https://')) {
      normalized = 'https://$normalized';
    }

    final uri = Uri.tryParse(normalized);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CommonAppBar(title: widget.moduleName),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            color: AppColors.white,
            child: Text(
              widget.item.title ?? '',
              style: AppTextStyles.heading6,
            ),
          ),

          // Clickable URL button
          if (widget.item.hasUrl)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: _openUrl,
                child: Text(
                  widget.item.linkUrl!,
                  style: AppTextStyles.body2.copyWith(
                    color: const Color(0xFF281B92),
                    decoration: TextDecoration.underline,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

          const SizedBox(height: 8),

          // HTML description WebView
          if (widget.item.hasDescription)
            Expanded(
              child: WebViewWidget(controller: _webViewController),
            )
          else
            const Expanded(child: SizedBox.shrink()),
        ],
      ),
    );
  }
}
