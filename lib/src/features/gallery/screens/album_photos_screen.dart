import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/common_toast.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../models/album_detail_result.dart';
import '../providers/gallery_provider.dart';
import '../widgets/photo_grid_item.dart';
import 'add_photo_screen.dart';
import 'photo_detail_screen.dart';

/// Port of iOS AlbumPhotosViewController — photo grid for an album.
/// Shows photos with admin add/delete controls.
class AlbumPhotosScreen extends StatefulWidget {
  const AlbumPhotosScreen({
    super.key,
    required this.albumId,
    required this.albumTitle,
    required this.groupId,
    this.isAdmin = false,
    this.profileId = '',
  });

  final String albumId;
  final String albumTitle;
  final String groupId;
  final bool isAdmin;
  final String profileId;

  @override
  State<AlbumPhotosScreen> createState() => _AlbumPhotosScreenState();
}

class _AlbumPhotosScreenState extends State<AlbumPhotosScreen> {
  bool _isSelectionMode = false;
  final Set<String> _selectedPhotoIds = {};

  @override
  void initState() {
    super.initState();
    _fetchPhotos();
  }

  void _fetchPhotos() {
    context.read<GalleryProvider>().fetchAlbumPhotos(
          albumId: widget.albumId,
          groupId: widget.groupId,
        );
  }

  void _toggleSelection(AlbumPhoto photo) {
    if (!_isSelectionMode) return;
    setState(() {
      final id = photo.photoId ?? '';
      if (_selectedPhotoIds.contains(id)) {
        _selectedPhotoIds.remove(id);
        if (_selectedPhotoIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedPhotoIds.add(id);
      }
    });
  }

  void _startSelectionMode(AlbumPhoto photo) {
    if (!widget.isAdmin) return;
    setState(() {
      _isSelectionMode = true;
      _selectedPhotoIds.add(photo.photoId ?? '');
    });
  }

  Future<void> _deleteSelected() async {
    if (_selectedPhotoIds.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Photos'),
        content: Text(
            'Are you sure you want to delete ${_selectedPhotoIds.length} photo(s)?'),
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

    final provider = context.read<GalleryProvider>();
    int deleted = 0;
    for (final photoId in _selectedPhotoIds) {
      final success = await provider.deletePhoto(
        photoId: photoId,
        albumId: widget.albumId,
        deletedBy: widget.profileId,
      );
      if (success) deleted++;
    }

    if (!mounted) return;

    setState(() {
      _selectedPhotoIds.clear();
      _isSelectionMode = false;
    });

    if (deleted > 0) {
      CommonToast.success(context, '$deleted photo(s) deleted');
    } else {
      CommonToast.error(context, 'Failed to delete photos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CommonAppBar(
        title: _isSelectionMode
            ? '${_selectedPhotoIds.length} Selected'
            : widget.albumTitle,
        actions: [
          if (_isSelectionMode) ...[
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.textOnPrimary),
              onPressed: _deleteSelected,
            ),
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.textOnPrimary),
              onPressed: () {
                setState(() {
                  _isSelectionMode = false;
                  _selectedPhotoIds.clear();
                });
              },
            ),
          ] else if (widget.isAdmin)
            IconButton(
              icon: const Icon(Icons.add_a_photo,
                  color: AppColors.textOnPrimary),
              onPressed: _navigateToAddPhoto,
            ),
        ],
      ),
      body: Consumer<GalleryProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return EmptyStateWidget(
              icon: Icons.error_outline,
              message: provider.error!,
              onRetry: _fetchPhotos,
              retryLabel: 'Retry',
            );
          }

          if (provider.photos.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.photo,
              message: 'No photos in this album',
              onRetry: _fetchPhotos,
              retryLabel: 'Refresh',
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _fetchPhotos(),
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: provider.photos.length,
              itemBuilder: (_, index) {
                final photo = provider.photos[index];
                return PhotoGridItem(
                  photo: photo,
                  isSelected:
                      _selectedPhotoIds.contains(photo.photoId ?? ''),
                  onTap: () {
                    if (_isSelectionMode) {
                      _toggleSelection(photo);
                    } else {
                      _navigateToPhotoDetail(provider.photos, index);
                    }
                  },
                  onLongPress: () => _startSelectionMode(photo),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _navigateToAddPhoto() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddPhotoScreen(
          albumId: widget.albumId,
          groupId: widget.groupId,
          profileId: widget.profileId,
        ),
      ),
    ).then((_) => _fetchPhotos());
  }

  void _navigateToPhotoDetail(List<AlbumPhoto> photos, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PhotoDetailScreen(
          photos: photos,
          initialIndex: index,
        ),
      ),
    );
  }
}
