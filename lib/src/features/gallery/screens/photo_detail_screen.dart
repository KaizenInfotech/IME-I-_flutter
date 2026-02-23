import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/album_detail_result.dart';

/// Port of iOS NewShowCasePhotoDetailsVC — full screen photo viewer with zoom.
/// Swipes between photos with PageView, pinch to zoom via InteractiveViewer.
class PhotoDetailScreen extends StatefulWidget {
  const PhotoDetailScreen({
    super.key,
    required this.photos,
    this.initialIndex = 0,
  });

  final List<AlbumPhoto> photos;
  final int initialIndex;

  @override
  State<PhotoDetailScreen> createState() => _PhotoDetailScreenState();
}

class _PhotoDetailScreenState extends State<PhotoDetailScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.white),
        title: Text(
          '${_currentIndex + 1} / ${widget.photos.length}',
          style: AppTextStyles.navTitle,
        ),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Page view with zoom
          PageView.builder(
            controller: _pageController,
            itemCount: widget.photos.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (_, index) {
              final photo = widget.photos[index];
              return _buildPhotoPage(photo);
            },
          ),

          // Description overlay at bottom
          if (_currentPhoto?.description != null &&
              _currentPhoto!.description!.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(16, 40, 16, 32),
                child: Text(
                  _currentPhoto!.description!,
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  AlbumPhoto? get _currentPhoto {
    if (_currentIndex >= 0 && _currentIndex < widget.photos.length) {
      return widget.photos[_currentIndex];
    }
    return null;
  }

  Widget _buildPhotoPage(AlbumPhoto photo) {
    if (!photo.hasValidUrl) {
      return const Center(
        child: Icon(Icons.broken_image, size: 64, color: AppColors.grayMedium),
      );
    }

    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,
      child: Center(
        child: Image.network(
          photo.url!,
          fit: BoxFit.contain,
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: progress.expectedTotalBytes != null
                    ? progress.cumulativeBytesLoaded /
                        progress.expectedTotalBytes!
                    : null,
                valueColor:
                    const AlwaysStoppedAnimation(AppColors.white),
              ),
            );
          },
          errorBuilder: (_, _, _) => const Center(
            child: Icon(Icons.broken_image,
                size: 64, color: AppColors.grayMedium),
          ),
        ),
      ),
    );
  }
}
