import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/album_list_result.dart';

/// Grid item for displaying an album thumbnail with title.
/// iOS: CreateAlbumViewController collection view cell.
class AlbumGridItem extends StatelessWidget {
  const AlbumGridItem({
    super.key,
    required this.album,
    this.onTap,
  });

  final AlbumItem album;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Album image
            Expanded(
              child: album.hasValidImage
                  ? Image.network(
                      album.image!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),

            // Title + info
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    album.title ?? 'Untitled Album',
                    style: AppTextStyles.body3.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (album.clubName != null &&
                      album.clubName!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      album.clubName!,
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.backgroundGray,
      child: const Center(
        child: Icon(
          Icons.photo_library,
          size: 40,
          color: AppColors.grayMedium,
        ),
      ),
    );
  }
}
