import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/common_toast.dart';
import '../models/ebulletin_list_result.dart';

/// Port of iOS EbulletinDetailViewController — displays e-bulletin content.
/// Downloads PDF/document and shows in WebView with share/delete.
class EbulletinDetailScreen extends StatefulWidget {
  const EbulletinDetailScreen({
    super.key,
    required this.ebulletin,
    this.profileId = '',
    this.isAdmin = false,
  });

  final EbulletinItem ebulletin;
  final String profileId;
  final bool isAdmin;

  @override
  State<EbulletinDetailScreen> createState() => _EbulletinDetailScreenState();
}

class _EbulletinDetailScreenState extends State<EbulletinDetailScreen> {
  late final WebViewController _webController;
  bool _isLoading = true;
  String? _localFilePath;
  double _downloadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            debugPrint('WebView error: ${error.description}');
            if (mounted) setState(() => _isLoading = false);
          },
        ),
      );
    _loadContent();
  }

  Future<void> _loadContent() async {
    final url = widget.ebulletin.ebulletinlink;
    if (url == null || url.isEmpty) return;

    try {
      // iOS: check cache (NewsLetterDirectory)
      final cacheDir = await getTemporaryDirectory();
      final fileName =
          '${widget.ebulletin.ebulletinID ?? 'bulletin'}.${_getExtension(url)}';
      final filePath = '${cacheDir.path}/$fileName';
      final file = File(filePath);

      if (await file.exists()) {
        _localFilePath = filePath;
        _webController.loadFile(filePath);
        return;
      }

      // Download with progress
      final request = http.Request('GET', Uri.parse(url));
      final streamedResponse = await request.send();
      final totalBytes = streamedResponse.contentLength ?? 0;
      int receivedBytes = 0;
      final List<int> bytes = [];

      await for (final chunk in streamedResponse.stream) {
        bytes.addAll(chunk);
        receivedBytes += chunk.length;
        if (totalBytes > 0 && mounted) {
          setState(() {
            _downloadProgress = receivedBytes / totalBytes;
          });
        }
      }

      await file.writeAsBytes(bytes);
      _localFilePath = filePath;

      if (mounted) {
        _webController.loadFile(filePath);
      }
    } catch (e) {
      debugPrint('EbulletinDetail load error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        CommonToast.error(context, 'Failed to load e-bulletin');
      }
    }
  }

  String _getExtension(String url) {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      final path = uri.path.toLowerCase();
      if (path.endsWith('.pdf')) return 'pdf';
      if (path.endsWith('.docx')) return 'docx';
      if (path.endsWith('.doc')) return 'doc';
      if (path.endsWith('.html')) return 'html';
      if (path.endsWith('.jpg') || path.endsWith('.jpeg')) return 'jpg';
      if (path.endsWith('.png')) return 'png';
    }
    return 'pdf';
  }

  void _shareDocument() {
    if (_localFilePath != null) {
      Share.shareXFiles([XFile(_localFilePath!)]);
    } else if (widget.ebulletin.hasValidLink) {
      Share.share(widget.ebulletin.ebulletinlink!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CommonAppBar(
        title: widget.ebulletin.ebulletinTitle ?? 'E-Bulletin',
        actions: [
          if (_localFilePath != null)
            IconButton(
              icon: const Icon(Icons.share, color: AppColors.textOnPrimary),
              onPressed: _shareDocument,
            ),
          if (widget.isAdmin)
            IconButton(
              icon:
                  const Icon(Icons.delete, color: AppColors.textOnPrimary),
              onPressed: () {
                // Delete handled by parent via pop result
                Navigator.pop(context, 'delete');
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _webController),

          // Loading / download progress
          if (_isLoading)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    value:
                        _downloadProgress > 0 ? _downloadProgress : null,
                    valueColor:
                        const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                  if (_downloadProgress > 0) ...[
                    const SizedBox(height: 12),
                    Text(
                      '${(_downloadProgress * 100).toInt()}%',
                      style: AppTextStyles.body3.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
