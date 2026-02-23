import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../providers/gallery_provider.dart';
import '../widgets/album_grid_item.dart';
import 'album_photos_screen.dart';

/// Port of iOS GalleryCatyegoryNewViewController + ShowCaseAlbumListViewController.
/// Showcase albums with year/district/club/category filtering and search.
class ShowcaseAlbumsScreen extends StatefulWidget {
  const ShowcaseAlbumsScreen({
    super.key,
    this.groupId = '0',
    this.districtId = '',
    this.clubId = '',
    this.profileId = '',
    this.moduleId = '',
  });

  final String groupId;
  final String districtId;
  final String clubId;
  final String profileId;
  final String moduleId;

  @override
  State<ShowcaseAlbumsScreen> createState() => _ShowcaseAlbumsScreenState();
}

class _ShowcaseAlbumsScreenState extends State<ShowcaseAlbumsScreen> {
  final _searchController = TextEditingController();
  String _selectedYear = '';
  final String _selectedCategory = '0';
  String _shareType = '0';

  @override
  void initState() {
    super.initState();
    _fetchShowcaseAlbums();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _fetchShowcaseAlbums() {
    context.read<GalleryProvider>().fetchShowcaseAlbums(
          groupId: widget.groupId,
          districtId: widget.districtId,
          clubId: widget.clubId,
          categoryId: _selectedCategory,
          year: _selectedYear,
          shareType: _shareType,
          profileId: widget.profileId,
          moduleId: widget.moduleId,
          searchText: _searchController.text.trim(),
        );
  }

  void _onSearch(String query) {
    _fetchShowcaseAlbums();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CommonAppBar(
        title: 'Showcase Albums',
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Search albums...',
                hintStyle: const TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14,
                  color: AppColors.grayMedium,
                ),
                prefixIcon:
                    const Icon(Icons.search, color: AppColors.grayMedium),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear,
                            color: AppColors.grayMedium),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.backgroundGray,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Filter chips
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    label: _selectedYear.isEmpty ? 'Year' : _selectedYear,
                    onTap: _pickYear,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: _shareType == '0'
                        ? 'All Types'
                        : _shareType == '1'
                            ? 'Public'
                            : 'Private',
                    onTap: _toggleShareType,
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 1),

          // Album grid
          Expanded(
            child: Consumer<GalleryProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return EmptyStateWidget(
                    icon: Icons.error_outline,
                    message: provider.error!,
                    onRetry: _fetchShowcaseAlbums,
                    retryLabel: 'Retry',
                  );
                }

                if (provider.albums.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.photo_library,
                    message: 'No showcase albums found',
                    onRetry: _fetchShowcaseAlbums,
                    retryLabel: 'Refresh',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => _fetchShowcaseAlbums(),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                        onTap: () => _navigateToPhotos(album),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onTap,
  }) {
    return ActionChip(
      label: Text(
        label,
        style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
      ),
      onPressed: onTap,
      backgroundColor: AppColors.backgroundGray,
    );
  }

  void _pickYear() {
    final currentYear = DateTime.now().year;
    final years =
        List.generate(10, (i) => (currentYear - i).toString());

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Years'),
              onTap: () {
                Navigator.pop(ctx);
                setState(() => _selectedYear = '');
                _fetchShowcaseAlbums();
              },
            ),
            ...years.map((year) => ListTile(
                  title: Text(year),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _selectedYear = year);
                    _fetchShowcaseAlbums();
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _toggleShareType() {
    setState(() {
      if (_shareType == '0') {
        _shareType = '1';
      } else if (_shareType == '1') {
        _shareType = '2';
      } else {
        _shareType = '0';
      }
    });
    _fetchShowcaseAlbums();
  }

  void _navigateToPhotos(dynamic album) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AlbumPhotosScreen(
          albumId: album.albumId ?? '',
          albumTitle: album.title ?? 'Album',
          groupId: album.groupId ?? widget.groupId,
          profileId: widget.profileId,
        ),
      ),
    );
  }
}
