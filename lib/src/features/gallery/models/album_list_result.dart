import '../../../core/models/base_model.dart';

/// Port of iOS TBAlbumsListResult Obj-C model.
/// API: Gallery/GetAlbumsList, Gallery/GetAlbumsList_New
/// Response key: "TBAlbumsListResult"
/// iOS: delta sync with newAlbums, updatedAlbums, deletedAlbums.
class TBAlbumsListResult extends BaseModel {
  TBAlbumsListResult({
    this.status,
    this.message,
    this.updatedOn,
    this.newAlbums,
    this.updatedAlbums,
    this.deletedAlbums,
  });

  final String? status;
  final String? message;
  final String? updatedOn;
  final List<AlbumItem>? newAlbums;
  final List<AlbumItem>? updatedAlbums;
  final String? deletedAlbums;

  factory TBAlbumsListResult.fromJson(Map<String, dynamic> json) {
    final result = json['Result'] as Map<String, dynamic>? ?? json;
    return TBAlbumsListResult(
      status: BaseModel.safeString(json['status']),
      message: BaseModel.safeString(json['message']),
      updatedOn: BaseModel.safeString(json['updatedOn']),
      newAlbums: BaseModel.safeList(result['newAlbums'], AlbumItem.fromJson),
      updatedAlbums:
          BaseModel.safeList(result['updatedAlbums'], AlbumItem.fromJson),
      deletedAlbums: BaseModel.safeString(result['deletedAlbums']),
    );
  }

  bool get isSuccess => status == '0';

  /// Combined list of all albums (new + updated)
  List<AlbumItem> get allAlbums => [
        ...newAlbums ?? [],
        ...updatedAlbums ?? [],
      ];

  @override
  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'updatedOn': updatedOn,
      };
}

/// Single album item from the albums list.
class AlbumItem extends BaseModel {
  AlbumItem({
    this.albumId,
    this.title,
    this.description,
    this.image,
    this.groupId,
    this.moduleId,
    this.type,
    this.isAdmin,
    this.beneficiary,
    this.costOfProject,
    this.costOfProjectType,
    this.workingHour,
    this.workingHourType,
    this.projectDate,
    this.clubName,
    this.shareType,
    this.numberOfRotarian,
    this.albumCategoryID,
    this.albumCategoryText,
  });

  final String? albumId;
  final String? title;
  final String? description;
  final String? image;
  final String? groupId;
  final String? moduleId;
  final String? type;
  final String? isAdmin;
  final String? beneficiary;
  final String? costOfProject;
  final String? costOfProjectType;
  final String? workingHour;
  final String? workingHourType;
  final String? projectDate;
  final String? clubName;
  final String? shareType;
  final String? numberOfRotarian;
  final String? albumCategoryID;
  final String? albumCategoryText;

  factory AlbumItem.fromJson(Map<String, dynamic> json) {
    return AlbumItem(
      albumId: BaseModel.safeString(json['albumId']),
      title: BaseModel.safeString(json['title']),
      description: BaseModel.safeString(json['description']),
      image: BaseModel.safeString(json['image']),
      groupId: BaseModel.safeString(json['groupId']),
      moduleId: BaseModel.safeString(json['moduleId']),
      type: BaseModel.safeString(json['type']),
      isAdmin: BaseModel.safeString(json['isAdmin']),
      beneficiary: BaseModel.safeString(json['beneficiary']),
      costOfProject: BaseModel.safeString(json['cost_of_project']),
      costOfProjectType: BaseModel.safeString(json['cost_of_project_type']),
      workingHour: BaseModel.safeString(json['working_hour']),
      workingHourType: BaseModel.safeString(json['working_hour_type']),
      projectDate: BaseModel.safeString(json['project_date']),
      clubName: BaseModel.safeString(json['clubname']),
      shareType: BaseModel.safeString(json['sharetype']),
      numberOfRotarian: BaseModel.safeString(json['NumberOfRotarian']),
      albumCategoryID: BaseModel.safeString(json['albumCategoryID']),
      albumCategoryText: BaseModel.safeString(json['albumCategoryText']),
    );
  }

  bool get hasValidImage => image != null && image!.isNotEmpty;

  bool get isUserAdmin => isAdmin == 'Yes' || isAdmin == '1';

  @override
  Map<String, dynamic> toJson() => {
        'albumId': albumId,
        'title': title,
        'description': description,
        'image': image,
        'groupId': groupId,
        'moduleId': moduleId,
        'type': type,
        'isAdmin': isAdmin,
        'beneficiary': beneficiary,
        'cost_of_project': costOfProject,
        'cost_of_project_type': costOfProjectType,
        'working_hour': workingHour,
        'working_hour_type': workingHourType,
        'project_date': projectDate,
        'clubname': clubName,
        'sharetype': shareType,
        'NumberOfRotarian': numberOfRotarian,
        'albumCategoryID': albumCategoryID,
        'albumCategoryText': albumCategoryText,
      };
}
