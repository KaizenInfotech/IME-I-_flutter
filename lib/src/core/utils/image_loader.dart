import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Port of iOS ImageLoader.swift (NSCache-based) and UIImageView.imageFromServerURL.
/// Wraps CachedNetworkImage with standard placeholder/error handling.
class AppImageLoader extends StatelessWidget {
  const AppImageLoader({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.isCircular = false,
  });

  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final double? borderRadius;
  final bool isCircular;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildError();
    }

    Widget image = CachedNetworkImage(
      imageUrl: imageUrl!,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => _buildPlaceholder(),
      errorWidget: (context, url, error) => _buildError(),
    );

    if (isCircular) {
      image = ClipOval(child: image);
    } else if (borderRadius != null && borderRadius! > 0) {
      image = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius!),
        child: image,
      );
    }

    return image;
  }

  Widget _buildPlaceholder() {
    return placeholder ??
        SizedBox(
          width: width,
          height: height,
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
  }

  Widget _buildError() {
    return errorWidget ??
        SizedBox(
          width: width,
          height: height,
          child: const Center(
            child: Icon(Icons.broken_image, color: Colors.grey),
          ),
        );
  }

  /// iOS: imageFromServerURL equivalent — static method for preloading.
  static void preload(BuildContext context, String? url) {
    if (url == null || url.isEmpty) return;
    precacheImage(CachedNetworkImageProvider(url), context);
  }
}
