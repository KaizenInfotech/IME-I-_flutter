import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/common_toast.dart';
import '../providers/gallery_provider.dart';
import '../widgets/multi_image_picker.dart';

/// Port of iOS AddPhotoViewController — 5-image batch upload.
/// Picks up to 5 images, each with optional description, then uploads.
class AddPhotoScreen extends StatefulWidget {
  const AddPhotoScreen({
    super.key,
    required this.albumId,
    required this.groupId,
    required this.profileId,
  });

  final String albumId;
  final String groupId;
  final String profileId;

  @override
  State<AddPhotoScreen> createState() => _AddPhotoScreenState();
}

class _AddPhotoScreenState extends State<AddPhotoScreen> {
  List<PickedImageData> _images = [];

  void _onImagesChanged(List<PickedImageData> images) {
    _images = images;
  }

  Future<void> _upload() async {
    if (_images.isEmpty) {
      CommonToast.show(context, 'Please select at least one photo');
      return;
    }

    final provider = context.read<GalleryProvider>();

    final imageData = _images
        .map((img) => {
              'bytes': img.bytes.toList(),
              'description': img.description,
              'filename': img.filename,
            })
        .toList();

    final successCount = await provider.uploadMultiplePhotos(
      albumId: widget.albumId,
      groupId: widget.groupId,
      createdBy: widget.profileId,
      images: imageData,
    );

    if (!mounted) return;

    if (successCount > 0) {
      CommonToast.success(
          context, '$successCount photo(s) uploaded successfully');
      Navigator.pop(context);
    } else {
      CommonToast.error(context, 'Failed to upload photos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CommonAppBar(
        title: 'Add Photos',
        actions: [
          Consumer<GalleryProvider>(
            builder: (context, provider, _) {
              if (provider.isUploading) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation(AppColors.textOnPrimary),
                    ),
                  ),
                );
              }
              return IconButton(
                icon:
                    const Icon(Icons.check, color: AppColors.textOnPrimary),
                onPressed: _upload,
              );
            },
          ),
        ],
      ),
      body: Consumer<GalleryProvider>(
        builder: (context, provider, _) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select up to 5 photos to upload',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    MultiImagePicker(
                      maxImages: 5,
                      onImagesChanged: _onImagesChanged,
                    ),
                  ],
                ),
              ),

              // Upload progress overlay
              if (provider.isUploading)
                Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: Center(
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              value: provider.uploadProgress > 0
                                  ? provider.uploadProgress
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Uploading photos...',
                              style: AppTextStyles.body2,
                            ),
                            if (provider.uploadProgress > 0) ...[
                              const SizedBox(height: 8),
                              Text(
                                '${(provider.uploadProgress * 100).toInt()}%',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
