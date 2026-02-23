/// Model for Gallery/Fillyearlist response — list of years.
/// iOS: EventYr → YrResult → YrTable
/// JSON: { status, message, Result: { Table: [{ Yearlist: "2023" }] } }
class PastEventYearResult {
  PastEventYearResult({this.status, this.message, this.years});

  final String? status;
  final String? message;
  final List<String>? years;

  factory PastEventYearResult.fromJson(Map<String, dynamic> json) {
    List<String> yearList = [];
    final result = json['Result'] ?? json['result'];
    if (result is Map<String, dynamic>) {
      final table =
          (result['Table'] ?? result['table']) as List<dynamic>? ?? [];
      yearList = table
          .map((e) {
            final map = e as Map<String, dynamic>;
            return (map['Yearlist'] ?? map['yearlist'] ?? '').toString();
          })
          .where((y) => y.isNotEmpty)
          .toList();
    } else if (result is List<dynamic>) {
      yearList = result
          .map((e) {
            final map = e as Map<String, dynamic>;
            return (map['Yearlist'] ?? map['yearlist'] ?? '').toString();
          })
          .where((y) => y.isNotEmpty)
          .toList();
    }

    return PastEventYearResult(
      status: json['status']?.toString(),
      message: json['message']?.toString(),
      years: yearList,
    );
  }
}

/// Model for Gallery/GetAlbumsList_New response — list of past event albums.
/// iOS: PastEventModule → AlbumsListResult → PastResult → NewAlbum
/// JSON: { TBAlbumsListResult: { status, message, Result: { newAlbums: [...] } } }
class PastEventAlbumResult {
  PastEventAlbumResult({this.status, this.message, this.albums});

  final String? status;
  final String? message;
  final List<PastEventAlbum>? albums;

  factory PastEventAlbumResult.fromJson(Map<String, dynamic> json) {
    // iOS CodingKey: "TBAlbumsListResult" (capital TB)
    final tbResult = json['TBAlbumsListResult'] ??
        json['tbAlbumsListResult'] ??
        json['TbAlbumsListResult'] ??
        json;
    final resultMap = tbResult is Map<String, dynamic> ? tbResult : json;

    List<PastEventAlbum> albumList = [];
    final result = resultMap['Result'] ?? resultMap['result'];

    if (result is Map<String, dynamic>) {
      // iOS: result.newAlbums (camelCase, no CodingKey transformation)
      final newAlbums =
          (result['newAlbums'] ?? result['NewAlbums']) as List<dynamic>? ?? [];
      albumList = newAlbums
          .map((e) => PastEventAlbum.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (result is List<dynamic>) {
      // Fallback: Result is directly a list of albums
      albumList = result
          .map((e) => PastEventAlbum.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return PastEventAlbumResult(
      status: resultMap['status']?.toString(),
      message: resultMap['message']?.toString(),
      albums: albumList,
    );
  }
}

/// Single past event album item.
/// iOS: NewAlbum struct — CodingKeys map exact JSON fields.
class PastEventAlbum {
  PastEventAlbum({
    this.albumId,
    this.title,
    this.description,
    this.image,
    this.groupId,
    this.moduleId,
    this.clubName,
    this.projectDate,
    this.shareType,
    this.attendance,
    this.attendancePer,
    this.meetingType,
    this.agendaDocId,
    this.momDocId,
  });

  final String? albumId;
  final String? title;
  final String? description;
  final String? image;
  final String? groupId;
  final String? moduleId;
  final String? clubName;
  final String? projectDate;
  final String? shareType;
  final String? attendance;
  final String? attendancePer;
  final String? meetingType;
  final String? agendaDocId;
  final String? momDocId;

  factory PastEventAlbum.fromJson(Map<String, dynamic> json) {
    return PastEventAlbum(
      // iOS CodingKey: albumID = "albumId"
      albumId: (json['albumId'] ?? json['albumID'] ?? json['AlbumID'])
          ?.toString(),
      title: (json['title'] ?? json['Title'])?.toString(),
      description: (json['description'] ?? json['Description'])?.toString(),
      image: (json['image'] ?? json['Image'])?.toString(),
      // iOS CodingKey: groupID = "groupId"
      groupId: (json['groupId'] ?? json['groupID'] ?? json['GroupID'])
          ?.toString(),
      // iOS CodingKey: moduleID = "moduleId"
      moduleId:
          (json['moduleId'] ?? json['moduleID'] ?? json['ModuleID'])
              ?.toString(),
      clubName: (json['clubname'] ?? json['Clubname'] ?? json['ClubName'])
          ?.toString(),
      // iOS CodingKey: projectDate = "project_date" (snake_case!)
      projectDate:
          (json['project_date'] ?? json['projectDate'] ?? json['ProjectDate'])
              ?.toString(),
      shareType: (json['sharetype'] ?? json['Sharetype'])?.toString(),
      // iOS CodingKey: attendance = "Attendance" (PascalCase)
      attendance: (json['Attendance'] ?? json['attendance'])?.toString(),
      attendancePer:
          (json['AttendancePer'] ?? json['attendancePer'])?.toString(),
      meetingType: (json['MeetingType'] ?? json['meetingType'])?.toString(),
      // iOS CodingKey: agendaDocID = "AgendaDocID"
      agendaDocId:
          (json['AgendaDocID'] ?? json['agendaDocID'])?.toString(),
      // iOS CodingKey: momDocID = "MOMDocID"
      momDocId: (json['MOMDocID'] ?? json['momDocID'])?.toString(),
    );
  }
}

/// Model for Gallery/GetAlbumPhotoList_New response — album photos.
/// iOS: PastEventGallery → TBAlbumPhotoListResult → [PhotoGalleryResult]
/// JSON: { TBAlbumPhotoListResult: { status, message, Result: [...] } }
class PastEventPhotoResult {
  PastEventPhotoResult({this.status, this.message, this.photos});

  final String? status;
  final String? message;
  final List<PastEventPhoto>? photos;

  factory PastEventPhotoResult.fromJson(Map<String, dynamic> json) {
    final tbResult = json['TBAlbumPhotoListResult'] ??
        json['tbAlbumPhotoListResult'] ??
        json;
    final resultMap = tbResult is Map<String, dynamic> ? tbResult : json;

    List<PastEventPhoto> photoList = [];
    final result = resultMap['Result'] ?? resultMap['result'];
    if (result is List<dynamic>) {
      photoList = result
          .map((e) => PastEventPhoto.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return PastEventPhotoResult(
      status: resultMap['status']?.toString(),
      message: resultMap['message']?.toString(),
      photos: photoList,
    );
  }
}

/// Single album photo.
/// iOS: PhotoGalleryResult — photoId, url, description.
class PastEventPhoto {
  PastEventPhoto({this.photoId, this.url, this.description});

  final String? photoId;
  final String? url;
  final String? description;

  factory PastEventPhoto.fromJson(Map<String, dynamic> json) {
    return PastEventPhoto(
      photoId: (json['photoId'] ?? json['photoID'])?.toString(),
      url: (json['url'] ?? json['Url'])?.toString(),
      description: (json['description'] ?? json['Description'])?.toString(),
    );
  }
}
