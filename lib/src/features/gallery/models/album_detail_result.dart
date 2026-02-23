import '../../../core/models/base_model.dart';

/// Port of iOS TBAlbumDetailResult — album detail with photos.
/// API: Gallery/GetAlbumDetails_New
/// Response key: "TBAlbumDetailResult"
class TBAlbumDetailResult extends BaseModel {
  TBAlbumDetailResult({
    this.status,
    this.message,
    this.albumDetail,
  });

  final String? status;
  final String? message;
  final AlbumDetail? albumDetail;

  factory TBAlbumDetailResult.fromJson(Map<String, dynamic> json) {
    final result = json['AlbumDetailResult'] as Map<String, dynamic>?;
    AlbumDetail? detail;
    if (result != null) {
      final detailList = result['AlbumDetail'] as List<dynamic>?;
      if (detailList != null && detailList.isNotEmpty) {
        detail = AlbumDetail.fromJson(detailList[0] as Map<String, dynamic>);
      }
    }
    return TBAlbumDetailResult(
      status: BaseModel.safeString(json['status']),
      message: BaseModel.safeString(json['message']),
      albumDetail: detail,
    );
  }

  bool get isSuccess => status == '0';

  @override
  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
      };
}

/// Detailed album info — iOS: AlbumDetailResult.AlbumDetail
class AlbumDetail extends BaseModel {
  AlbumDetail({
    this.albumTitle,
    this.albumDescription,
    this.albumImage,
    this.type,
    this.groupId,
    this.albumId,
    this.memberIds,
    this.beneficiary,
    this.numberOfRotarian,
    this.projectCost,
    this.projectDate,
    this.workingHour,
    this.albumCategoryID,
    this.albumCategoryText,
    this.otherCategoryText,
    this.shareType,
    this.costOfProjectType,
    this.workingHourType,
  });

  final String? albumTitle;
  final String? albumDescription;
  final String? albumImage;
  final String? type;
  final String? groupId;
  final String? albumId;
  final String? memberIds;
  final String? beneficiary;
  final String? numberOfRotarian;
  final String? projectCost;
  final String? projectDate;
  final String? workingHour;
  final String? albumCategoryID;
  final String? albumCategoryText;
  final String? otherCategoryText;
  final String? shareType;
  final String? costOfProjectType;
  final String? workingHourType;

  factory AlbumDetail.fromJson(Map<String, dynamic> json) {
    return AlbumDetail(
      albumTitle: BaseModel.safeString(json['albumTitle']),
      albumDescription: BaseModel.safeString(json['albumDescription']),
      albumImage: BaseModel.safeString(json['albumImage']),
      type: BaseModel.safeString(json['type']),
      groupId: BaseModel.safeString(json['groupId']),
      albumId: BaseModel.safeString(json['albumId']),
      memberIds: BaseModel.safeString(json['memberIds']),
      beneficiary: BaseModel.safeString(json['beneficiary']),
      numberOfRotarian: BaseModel.safeString(json['NumberOfRotarian']),
      projectCost: BaseModel.safeString(json['project_cost']),
      projectDate: BaseModel.safeString(json['project_date']),
      workingHour: BaseModel.safeString(json['working_hour']),
      albumCategoryID: BaseModel.safeString(json['albumCategoryID']),
      albumCategoryText: BaseModel.safeString(json['albumCategoryText']),
      otherCategoryText: BaseModel.safeString(json['othercategorytext']),
      shareType: BaseModel.safeString(json['shareType']),
      costOfProjectType: BaseModel.safeString(json['cost_of_project_type']),
      workingHourType: BaseModel.safeString(json['working_hour_type']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'albumTitle': albumTitle,
        'albumDescription': albumDescription,
        'albumImage': albumImage,
        'type': type,
        'groupId': groupId,
        'albumId': albumId,
        'memberIds': memberIds,
        'beneficiary': beneficiary,
        'NumberOfRotarian': numberOfRotarian,
        'project_cost': projectCost,
        'project_date': projectDate,
        'working_hour': workingHour,
        'albumCategoryID': albumCategoryID,
        'albumCategoryText': albumCategoryText,
        'othercategorytext': otherCategoryText,
        'shareType': shareType,
        'cost_of_project_type': costOfProjectType,
        'working_hour_type': workingHourType,
      };
}

/// Port of iOS TBAlbumPhotoListResult — photo list with delta sync.
/// API: Gallery/GetAlbumPhotoList
/// Response key: "TBAlbumPhotoListResult"
class TBAlbumPhotoListResult extends BaseModel {
  TBAlbumPhotoListResult({
    this.status,
    this.message,
    this.updatedOn,
    this.newPhotos,
    this.updatedPhotos,
    this.deletedPhotos,
  });

  final String? status;
  final String? message;
  final String? updatedOn;
  final List<AlbumPhoto>? newPhotos;
  final List<AlbumPhoto>? updatedPhotos;
  final String? deletedPhotos;

  factory TBAlbumPhotoListResult.fromJson(Map<String, dynamic> json) {
    final result = json['Result'] as Map<String, dynamic>? ?? json;
    return TBAlbumPhotoListResult(
      status: BaseModel.safeString(json['status']),
      message: BaseModel.safeString(json['message']),
      updatedOn: BaseModel.safeString(json['updatedOn']),
      newPhotos: BaseModel.safeList(result['newPhotos'], AlbumPhoto.fromJson),
      updatedPhotos:
          BaseModel.safeList(result['updatedPhotos'], AlbumPhoto.fromJson),
      deletedPhotos: BaseModel.safeString(result['deletedPhotos']),
    );
  }

  bool get isSuccess => status == '0';

  /// Combined list of photos
  List<AlbumPhoto> get allPhotos => [
        ...newPhotos ?? [],
        ...updatedPhotos ?? [],
      ];

  @override
  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'updatedOn': updatedOn,
      };
}

/// Single photo in an album.
class AlbumPhoto extends BaseModel {
  AlbumPhoto({
    this.photoId,
    this.url,
    this.description,
  });

  final String? photoId;
  final String? url;
  final String? description;

  factory AlbumPhoto.fromJson(Map<String, dynamic> json) {
    return AlbumPhoto(
      photoId: BaseModel.safeString(json['photoId']),
      url: BaseModel.safeString(json['url']),
      description: BaseModel.safeString(json['description']),
    );
  }

  bool get hasValidUrl => url != null && url!.isNotEmpty;

  @override
  Map<String, dynamic> toJson() => {
        'photoId': photoId,
        'url': url,
        'description': description,
      };
}
