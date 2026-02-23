import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// iOS: AddPhotoViewController — pick up to 5 images for batch upload.
/// Uses image_picker to select from camera or gallery.
class MultiImagePicker extends StatefulWidget {
  const MultiImagePicker({
    super.key,
    required this.onImagesChanged,
    this.maxImages = 5,
  });

  final ValueChanged<List<PickedImageData>> onImagesChanged;
  final int maxImages;

  @override
  State<MultiImagePicker> createState() => _MultiImagePickerState();
}

class _MultiImagePickerState extends State<MultiImagePicker> {
  final List<PickedImageData> _images = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickFromGallery() async {
    if (_images.length >= widget.maxImages) return;

    final remaining = widget.maxImages - _images.length;
    try {
      final picked = await _picker.pickMultiImage(
        imageQuality: 90,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (picked.isNotEmpty) {
        final toAdd = picked.take(remaining);
        for (final xFile in toAdd) {
          final bytes = await xFile.readAsBytes();
          _images.add(PickedImageData(
            bytes: bytes,
            filename: xFile.name,
            description: '',
          ));
        }
        setState(() {});
        widget.onImagesChanged(_images);
      }
    } catch (e) {
      debugPrint('MultiImagePicker gallery error: $e');
    }
  }

  Future<void> _pickFromCamera() async {
    if (_images.length >= widget.maxImages) return;

    try {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        _images.add(PickedImageData(
          bytes: bytes,
          filename: picked.name,
          description: '',
        ));
        setState(() {});
        widget.onImagesChanged(_images);
      }
    } catch (e) {
      debugPrint('MultiImagePicker camera error: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
    widget.onImagesChanged(_images);
  }

  void _updateDescription(int index, String desc) {
    _images[index] = _images[index].copyWith(description: desc);
    widget.onImagesChanged(_images);
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(ctx);
                _pickFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with count
        Row(
          children: [
            Text(
              'Photos (${_images.length}/${widget.maxImages})',
              style: AppTextStyles.body2.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (_images.length < widget.maxImages)
              TextButton.icon(
                onPressed: _showPickerOptions,
                icon: const Icon(Icons.add_a_photo, size: 18),
                label: const Text('Add'),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Image grid
        if (_images.isEmpty)
          GestureDetector(
            onTap: _showPickerOptions,
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.backgroundGray,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.border,
                  style: BorderStyle.solid,
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo, size: 40, color: AppColors.grayMedium),
                  SizedBox(height: 8),
                  Text(
                    'Tap to add photos',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _images.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, index) {
              final img = _images[index];
              return _buildImageRow(img, index);
            },
          ),
      ],
    );
  }

  Widget _buildImageRow(PickedImageData img, int index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thumbnail
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            img.bytes,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 12),

        // Description field
        Expanded(
          child: TextField(
            onChanged: (val) => _updateDescription(index, val),
            style: AppTextStyles.body3,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Description (optional)',
              hintStyle: AppTextStyles.inputHint.copyWith(fontSize: 13),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: AppColors.border),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Remove button
        IconButton(
          onPressed: () => _removeImage(index),
          icon: const Icon(Icons.close, color: AppColors.systemRed, size: 20),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ],
    );
  }
}

/// Data class for a picked image.
class PickedImageData {
  const PickedImageData({
    required this.bytes,
    required this.filename,
    required this.description,
  });

  final Uint8List bytes;
  final String filename;
  final String description;

  PickedImageData copyWith({
    Uint8List? bytes,
    String? filename,
    String? description,
  }) {
    return PickedImageData(
      bytes: bytes ?? this.bytes,
      filename: filename ?? this.filename,
      description: description ?? this.description,
    );
  }
}
