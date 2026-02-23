import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/album_detail_result.dart';
import '../models/album_list_result.dart';
import '../models/create_album_model.dart';
import '../models/delete_result.dart';

/// Port of iOS gallery WebserviceClass + UploadDocManager methods.
/// Matches: getAlbumList, getAlbumPhotoList, addUpdateAlbum,
/// deleteAlbumPhoto, getAlbumDetails, uploadImage (multipart).
class GalleryProvider extends ChangeNotifier {
  // ─── STATE ──────────────────────────────────────────────
  List<AlbumItem> _albums = [];
  List<AlbumItem> get albums => _albums;

  List<AlbumPhoto> _photos = [];
  List<AlbumPhoto> get photos => _photos;

  AlbumDetail? _selectedAlbum;
  AlbumDetail? get selectedAlbum => _selectedAlbum;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isUploading = false;
  bool get isUploading => _isUploading;

  double _uploadProgress = 0.0;
  double get uploadProgress => _uploadProgress;

  String? _error;
  String? get error => _error;

  String? _lastUpdatedOn;

  // ─── iOS: getAlbumList → POST Gallery/GetAlbumsList ──
  Future<bool> fetchAlbums({
    required String profileId,
    required String groupId,
    String moduleId = '',
    String updatedOn = '1970/01/01 00:00:00',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.galleryGetAlbumsList,
        body: {
          'profileId': profileId,
          'groupId': groupId,
          'updatedOn': _lastUpdatedOn ?? updatedOn,
          'moduleId': moduleId,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = TBAlbumsListResult.fromJson(
            jsonData['TBAlbumsListResult'] as Map<String, dynamic>? ??
                jsonData);

        if (result.isSuccess) {
          _lastUpdatedOn = result.updatedOn;
          _albums = result.allAlbums;
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _error = result.message ?? 'Failed to load albums';
        }
      } else {
        _error = 'Server error';
      }
    } catch (e) {
      _error = 'Error loading albums: $e';
      debugPrint('fetchAlbums error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ─── iOS: showcase albums → POST Gallery/GetAlbumsList_New ──
  Future<bool> fetchShowcaseAlbums({
    String groupId = '0',
    String districtId = '',
    String clubId = '',
    String categoryId = '0',
    String year = '',
    String shareType = '0',
    String profileId = '',
    String moduleId = '',
    String searchText = '',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.galleryGetAlbumsListNew,
        body: {
          'groupId': groupId,
          'district_id': districtId,
          'club_id': clubId,
          'category_id': categoryId,
          'year': year,
          'SharType': shareType,
          'profileId': profileId,
          'moduleId': moduleId,
          'searchText': searchText,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = TBAlbumsListResult.fromJson(
            jsonData['TBAlbumsListResult'] as Map<String, dynamic>? ??
                jsonData);

        if (result.isSuccess) {
          _albums = result.allAlbums;
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _error = result.message ?? 'No albums found';
        }
      } else {
        _error = 'Server error';
      }
    } catch (e) {
      _error = 'Error loading showcase albums: $e';
      debugPrint('fetchShowcaseAlbums error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ─── iOS: getAlbumPhotoList → POST Gallery/GetAlbumPhotoList ──
  Future<bool> fetchAlbumPhotos({
    required String albumId,
    required String groupId,
    String updatedOn = '1970/01/01 00:00:00',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.galleryGetAlbumPhotoList,
        body: {
          'albumId': albumId,
          'groupId': groupId,
          'updatedOn': updatedOn,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = TBAlbumPhotoListResult.fromJson(
            jsonData['TBAlbumPhotoListResult'] as Map<String, dynamic>? ??
                jsonData);

        if (result.isSuccess) {
          _photos = result.allPhotos;

          // Handle deletions
          if (result.deletedPhotos != null &&
              result.deletedPhotos!.isNotEmpty) {
            final deletedIds = result.deletedPhotos!.split(',');
            _photos.removeWhere(
                (p) => deletedIds.contains(p.photoId));
          }

          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _error = result.message ?? 'Failed to load photos';
        }
      } else {
        _error = 'Server error';
      }
    } catch (e) {
      _error = 'Error loading photos: $e';
      debugPrint('fetchAlbumPhotos error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ─── iOS: getAlbumDetails → POST Gallery/GetAlbumDetails_New ──
  Future<bool> fetchAlbumDetails({
    required String albumId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.galleryGetAlbumDetails,
        body: {
          'albumId': albumId,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = TBAlbumDetailResult.fromJson(
            jsonData['TBAlbumDetailResult'] as Map<String, dynamic>? ??
                jsonData);

        if (result.isSuccess) {
          _selectedAlbum = result.albumDetail;
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _error = result.message ?? 'Failed to load album details';
        }
      } else {
        _error = 'Server error';
      }
    } catch (e) {
      _error = 'Error loading album details: $e';
      debugPrint('fetchAlbumDetails error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ─── iOS: addUpdateAlbum → POST Gallery/AddUpdateAlbum_New ──
  Future<TBAddGalleryResult?> createOrUpdateAlbum({
    required String albumId,
    required String groupId,
    required String type,
    required String memberIds,
    required String albumTitle,
    required String albumDescription,
    required String albumImage,
    required String createdBy,
    required String moduleId,
    String shareType = 'Public',
    String categoryId = '',
    String dateOfProject = '',
    String costOfProject = '',
    String beneficiary = '',
    String manHoursSpent = '',
    String manHoursSpentType = 'Hours',
    String numberOfRotarian = '',
    String otherCategoryText = '',
    String costOfProjectType = 'Rupee',
    String isSubGrpAdmin = '0',
    String subGrpIDs = '',
  }) async {
    try {
      final response = await ApiClient.instance.post(
        ApiConstants.galleryAddUpdateAlbum,
        body: {
          'albumId': albumId,
          'groupId': groupId,
          'type': type,
          'memberIds': memberIds,
          'albumTitle': albumTitle,
          'albumDescription': albumDescription,
          'albumImage': albumImage,
          'createdBy': createdBy,
          'isSubGrpAdmin': isSubGrpAdmin,
          'subgrpIDs': subGrpIDs,
          'moduleId': moduleId,
          'shareType': shareType,
          'categoryId': categoryId,
          'dateofproject': dateOfProject,
          'costofproject': costOfProject,
          'beneficiary': beneficiary,
          'manhourspent': manHoursSpent,
          'Manhourspenttype': manHoursSpentType,
          'NumberofRotarian': numberOfRotarian,
          'OtherCategorytext': otherCategoryText,
          'costofprojecttype': costOfProjectType,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return TBAddGalleryResult.fromJson(
            jsonData['TBAddGalleryResult'] as Map<String, dynamic>? ??
                jsonData);
      }
    } catch (e) {
      debugPrint('createOrUpdateAlbum error: $e');
    }
    return null;
  }

  // ─── iOS: UploadDocManager.MultiplePhotoSendServer → multipart upload ──
  /// Upload a photo to an album via multipart POST.
  /// iOS: Gallery/AddUpdateAlbumPhoto?photoId=0&desc=...&albumId=...&groupId=...&createdBy=...
  Future<bool> uploadAlbumPhoto({
    required String albumId,
    required String groupId,
    required String createdBy,
    required String description,
    required List<int> imageBytes,
    String photoId = '0',
    String filename = 'photo.jpg',
  }) async {
    _isUploading = true;
    notifyListeners();

    try {
      final uri = Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.galleryAddUpdateAlbumPhoto}'
          '?photoId=$photoId&desc=${Uri.encodeComponent(description)}'
          '&albumId=$albumId&groupId=$groupId&createdBy=$createdBy');

      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ=='
        ..files.add(http.MultipartFile.fromBytes(
          'userfile',
          imageBytes,
          filename: filename,
        ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final status = jsonData['status']?.toString();
        _isUploading = false;
        notifyListeners();
        return status == '0';
      }
    } catch (e) {
      debugPrint('uploadAlbumPhoto error: $e');
    }

    _isUploading = false;
    notifyListeners();
    return false;
  }

  /// iOS: batch upload up to 5 images
  Future<int> uploadMultiplePhotos({
    required String albumId,
    required String groupId,
    required String createdBy,
    required List<Map<String, dynamic>> images,
  }) async {
    _isUploading = true;
    _uploadProgress = 0.0;
    notifyListeners();

    int successCount = 0;
    for (int i = 0; i < images.length; i++) {
      final imageData = images[i];
      final success = await uploadAlbumPhoto(
        albumId: albumId,
        groupId: groupId,
        createdBy: createdBy,
        description: imageData['description'] as String? ?? '',
        imageBytes: imageData['bytes'] as List<int>,
        filename: imageData['filename'] as String? ?? 'photo_$i.jpg',
      );
      if (success) successCount++;

      _uploadProgress = (i + 1) / images.length;
      notifyListeners();
    }

    _isUploading = false;
    _uploadProgress = 0.0;
    notifyListeners();
    return successCount;
  }

  // ─── iOS: deleteAlbumPhoto → POST Gallery/DeleteAlbumPhoto ──
  Future<bool> deletePhoto({
    required String photoId,
    required String albumId,
    required String deletedBy,
  }) async {
    try {
      final response = await ApiClient.instance.post(
        ApiConstants.galleryDeleteAlbumPhoto,
        body: {
          'photoId': photoId,
          'albumId': albumId,
          'deletedBy': deletedBy,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = TBDeleteAlbumPhotoResult.fromJson(
            jsonData['TBDelteAlbumPhoto'] as Map<String, dynamic>? ??
                jsonData);

        if (result.isSuccess) {
          _photos.removeWhere((p) => p.photoId == photoId);
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      debugPrint('deletePhoto error: $e');
    }
    return false;
  }

  void clearSelectedAlbum() {
    _selectedAlbum = null;
    notifyListeners();
  }

  void clearAll() {
    _albums = [];
    _photos = [];
    _selectedAlbum = null;
    _isLoading = false;
    _isUploading = false;
    _uploadProgress = 0.0;
    _error = null;
    _lastUpdatedOn = null;
    notifyListeners();
  }
}
