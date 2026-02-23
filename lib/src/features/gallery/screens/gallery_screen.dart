import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/storage/local_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../providers/gallery_provider.dart';
import '../widgets/album_grid_item.dart';
import 'album_photos_screen.dart';
import 'create_album_screen.dart';

/// Port of iOS CreateAlbumViewController — album list grid.
/// Shows all albums for a group with admin controls.
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({
    super.key,
    this.groupId,
    this.profileId,
    this.moduleId = '',
    this.isAdmin = false,
  });

  final String? groupId;
  final String? profileId;
  final String moduleId;
  final bool isAdmin;

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  String _groupId = '';
  String _profileId = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final localStorage = LocalStorage.instance;
    _profileId = widget.profileId ?? localStorage.authProfileId ?? '';
    _groupId = widget.groupId ?? localStorage.authGroupId ?? '';
    _fetchAlbums();
  }

  void _fetchAlbums() {
    context.read<GalleryProvider>().fetchAlbums(
          profileId: _profileId,
          groupId: _groupId,
          moduleId: widget.moduleId,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CommonAppBar(
        title: 'Gallery',
        actions: [
          if (widget.isAdmin)
            IconButton(
              icon: const Icon(Icons.add, color: AppColors.textOnPrimary),
              onPressed: _navigateToCreateAlbum,
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
              onRetry: _fetchAlbums,
              retryLabel: 'Retry',
            );
          }

          if (provider.albums.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.photo_library,
              message: 'No albums found',
              onRetry: _fetchAlbums,
              retryLabel: 'Refresh',
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _fetchAlbums(),
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: provider.albums.length,
              itemBuilder: (_, index) {
                final album = provider.albums[index];
                return AlbumGridItem(
                  album: album,
                  onTap: () => _navigateToAlbumPhotos(album),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _navigateToAlbumPhotos(dynamic album) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AlbumPhotosScreen(
          albumId: album.albumId ?? '',
          albumTitle: album.title ?? 'Album',
          groupId: _groupId,
          isAdmin: album.isUserAdmin || widget.isAdmin,
          profileId: _profileId,
        ),
      ),
    ).then((_) => _fetchAlbums());
  }

  void _navigateToCreateAlbum() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateAlbumScreen(
          groupId: _groupId,
          profileId: _profileId,
          moduleId: widget.moduleId,
        ),
      ),
    ).then((_) => _fetchAlbums());
  }
}
