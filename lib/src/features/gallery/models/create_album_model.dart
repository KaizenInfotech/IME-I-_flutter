import '../../../core/models/base_model.dart';

/// Port of iOS TBAddGalleryResult — add/update album response.
/// API: Gallery/AddUpdateAlbum_New
/// Response key: "TBAddGalleryResult"
class TBAddGalleryResult extends BaseModel {
  TBAddGalleryResult({
    this.status,
    this.message,
    this.galleryId,
  });

  final String? status;
  final String? message;
  final String? galleryId;

  factory TBAddGalleryResult.fromJson(Map<String, dynamic> json) {
    return TBAddGalleryResult(
      status: BaseModel.safeString(json['status']),
      message: BaseModel.safeString(json['message']),
      galleryId: BaseModel.safeString(json['galleryid']),
    );
  }

  bool get isSuccess => message != 'failed';

  @override
  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'galleryid': galleryId,
      };
}
