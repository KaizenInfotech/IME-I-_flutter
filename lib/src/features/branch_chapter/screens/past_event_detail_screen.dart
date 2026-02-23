import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../models/past_event_result.dart';
import '../providers/branch_chapter_provider.dart';

/// Port of iOS PastEventDetailViewController.
/// Shows event details (title, date, description, attendance) and photo gallery.
/// API: Gallery/GetAlbumPhotoList_New for photos.
class PastEventDetailScreen extends StatefulWidget {
  const PastEventDetailScreen({
    super.key,
    required this.event,
    required this.year,
  });

  final PastEventAlbum event;
  final String year;

  @override
  State<PastEventDetailScreen> createState() => _PastEventDetailScreenState();
}

class _PastEventDetailScreenState extends State<PastEventDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  void _loadPhotos() {
    context.read<BranchChapterProvider>().fetchPastEventPhotos(
          albumId: widget.event.albumId ?? '',
          year: widget.year,
          groupId: widget.event.groupId ?? '',
        );
  }

  Future<void> _openDocument(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _openPhotoViewer(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullScreenPhotoViewer(imageUrl: imageUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CommonAppBar(title: event.title ?? 'Event Detail'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Event Info Card ─────────────────────
            Container(
              width: double.infinity,
              color: AppColors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    event.title ?? '',
                    style: AppTextStyles.heading6
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (event.projectDate != null &&
                      event.projectDate!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          event.projectDate!,
                          style: AppTextStyles.body2
                              .copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ],
                  if (event.description != null &&
                      event.description!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      event.description!,
                      style: AppTextStyles.body2
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                  if (event.attendance != null &&
                      event.attendance!.isNotEmpty &&
                      event.attendance != '0') ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.people,
                            size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          'Total Attendance: ${event.attendance}',
                          style: AppTextStyles.body2
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // ─── Document Buttons (Agenda + MOM) ─────
            if (_hasDocuments) ...[
              const SizedBox(height: 8),
              Container(
                color: AppColors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    if (event.agendaDocId != null &&
                        event.agendaDocId!.isNotEmpty)
                      Expanded(
                        child: _buildDocButton(
                          icon: Icons.description,
                          label: 'Agenda',
                          onTap: () => _openDocument(event.agendaDocId),
                        ),
                      ),
                    if (event.agendaDocId != null &&
                        event.agendaDocId!.isNotEmpty &&
                        event.momDocId != null &&
                        event.momDocId!.isNotEmpty)
                      const SizedBox(width: 12),
                    if (event.momDocId != null && event.momDocId!.isNotEmpty)
                      Expanded(
                        child: _buildDocButton(
                          icon: Icons.note_alt,
                          label: 'Meeting Minutes',
                          onTap: () => _openDocument(event.momDocId),
                        ),
                      ),
                  ],
                ),
              ),
            ],

            // ─── Photo Gallery ───────────────────────
            const SizedBox(height: 8),
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Photos',
                    style: AppTextStyles.body1
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Consumer<BranchChapterProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoadingPhotos) {
                        return const SizedBox(
                          height: 100,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final photos = provider.eventPhotos;
                      if (photos.isEmpty) {
                        return const SizedBox(
                          height: 80,
                          child: Center(
                            child: Text(
                              'No photos available',
                              style: TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      }

                      // iOS: 2-column UICollectionView
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: photos.length,
                        itemBuilder: (_, index) {
                          final photo = photos[index];
                          return _buildPhotoTile(context, photo);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _hasDocuments =>
      (widget.event.agendaDocId != null &&
          widget.event.agendaDocId!.isNotEmpty) ||
      (widget.event.momDocId != null && widget.event.momDocId!.isNotEmpty);

  Widget _buildDocButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 13)),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildPhotoTile(BuildContext context, PastEventPhoto photo) {
    final url = photo.url?.replaceAll(' ', '%20') ?? '';
    return GestureDetector(
      onTap: () {
        if (url.isNotEmpty) _openPhotoViewer(context, url);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: url.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(
                  color: AppColors.grayLight,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (_, _, _) => Container(
                  color: AppColors.grayLight,
                  child: const Icon(Icons.broken_image,
                      color: AppColors.grayMedium),
                ),
              )
            : Container(
                color: AppColors.grayLight,
                child: const Icon(Icons.image, color: AppColors.grayMedium),
              ),
      ),
    );
  }
}

/// Full-screen photo viewer — iOS: PastEventGalleryViewController.
class _FullScreenPhotoViewer extends StatelessWidget {
  const _FullScreenPhotoViewer({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.contain,
            placeholder: (_, _) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (_, _, _) => const Icon(
              Icons.broken_image,
              color: Colors.white54,
              size: 48,
            ),
          ),
        ),
      ),
    );
  }
}
