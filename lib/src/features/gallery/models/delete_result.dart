import '../../../core/models/base_model.dart';

/// Port of iOS TBDelteAlbumPhoto — delete photo response.
/// API: Gallery/DeleteAlbumPhoto
/// Response key: "TBDelteAlbumPhoto" (note: iOS has typo "Delte")
class TBDeleteAlbumPhotoResult extends BaseModel {
  TBDeleteAlbumPhotoResult({
    this.status,
    this.message,
  });

  final String? status;
  final String? message;

  factory TBDeleteAlbumPhotoResult.fromJson(Map<String, dynamic> json) {
    return TBDeleteAlbumPhotoResult(
      status: BaseModel.safeString(json['status']),
      message: BaseModel.safeString(json['message']),
    );
  }

  bool get isSuccess => message != 'failed';

  @override
  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
      };
}
