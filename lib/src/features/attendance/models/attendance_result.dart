import '../../../core/models/base_model.dart';

/// Android: TBAttendanceListResult → { status, message, Result: { Table: [...] } }
/// API: Attendance/GetAttendanceListNew
class TBAttendanceListResult extends BaseModel {
  TBAttendanceListResult({
    this.status,
    this.message,
    this.attendanceList,
  });

  final String? status;
  final String? message;
  final List<AttendanceItem>? attendanceList;

  factory TBAttendanceListResult.fromJson(Map<String, dynamic> json) {
    List<AttendanceItem>? items;

    // Android parses: TBAttendanceListResult.Result.Table[]
    final result = json['Result'] as Map<String, dynamic>?;
    if (result != null) {
      final table = result['Table'] as List<dynamic>? ?? [];
      items = table
          .map((e) => AttendanceItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      // Fallback: try AttendanceListResult[].AttendanceResult (iOS format)
      final listResult = json['AttendanceListResult'] as List<dynamic>?;
      if (listResult != null) {
        items = listResult.map((e) {
          final map = e as Map<String, dynamic>;
          final r = map['AttendanceResult'] as Map<String, dynamic>? ?? map;
          return AttendanceItem.fromJson(r);
        }).toList();
      }
    }

    return TBAttendanceListResult(
      status: BaseModel.safeString(json['status']),
      message: BaseModel.safeString(json['message']),
      attendanceList: items,
    );
  }

  bool get isSuccess => status == '0';

  @override
  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
      };
}

/// Single attendance item from the list.
/// iOS: AttendanceResult nested inside AttendanceListResult array.
class AttendanceItem extends BaseModel {
  AttendanceItem({
    this.attendanceID,
    this.attendanceName,
    this.attendanceDate,
    this.attendanceTime,
    this.memberCount,
    this.visitorCount,
    this.description,
  });

  final String? attendanceID;
  final String? attendanceName;
  final String? attendanceDate;
  final String? attendanceTime;
  final String? memberCount;
  final String? visitorCount;
  final String? description;

  factory AttendanceItem.fromJson(Map<String, dynamic> json) {
    return AttendanceItem(
      attendanceID: BaseModel.safeString(json['AttendanceID']),
      attendanceName: BaseModel.safeString(json['AttendanceName']),
      attendanceDate: BaseModel.safeString(json['AttendanceDate']),
      attendanceTime: BaseModel.safeString(json['Attendancetime']),
      memberCount: BaseModel.safeString(json['member_count']),
      visitorCount: BaseModel.safeString(json['visitor_count']),
      description: BaseModel.safeString(json['Description']),
    );
  }

  String get displayDateTime {
    final parts = <String>[];
    if (attendanceDate != null && attendanceDate!.isNotEmpty) {
      parts.add(attendanceDate!);
    }
    if (attendanceTime != null && attendanceTime!.isNotEmpty) {
      parts.add(attendanceTime!);
    }
    return parts.join(' ');
  }

  @override
  Map<String, dynamic> toJson() => {
        'AttendanceID': attendanceID,
        'AttendanceName': attendanceName,
        'AttendanceDate': attendanceDate,
        'Attendancetime': attendanceTime,
        'member_count': memberCount,
        'visitor_count': visitorCount,
        'Description': description,
      };
}

/// Port of iOS TBAttendanceDetailsResult — attendance detail response.
/// API: Attendance/getAttendanceDetails
/// Response key: "TBAttendanceDetailsResult"
class TBAttendanceDetailsResult extends BaseModel {
  TBAttendanceDetailsResult({
    this.status,
    this.message,
    this.detail,
  });

  final String? status;
  final String? message;
  final AttendanceDetail? detail;

  factory TBAttendanceDetailsResult.fromJson(Map<String, dynamic> json) {
    final listResult = json['AttendanceDetailsResult'] as List<dynamic>?;
    AttendanceDetail? detail;

    if (listResult != null && listResult.isNotEmpty) {
      final map = listResult[0] as Map<String, dynamic>;
      final result =
          map['AttendanceResult'] as Map<String, dynamic>? ?? map;
      detail = AttendanceDetail.fromJson(result);
    }

    return TBAttendanceDetailsResult(
      status: BaseModel.safeString(json['status']),
      message: BaseModel.safeString(json['message']),
      detail: detail,
    );
  }

  bool get isSuccess => status == '0';

  @override
  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
      };
}

/// Detailed attendance info with counts for each category.
/// iOS: 6 attendee categories — Members, Anns, Annets, Visitors, Rotarians, DistrictDelegates.
class AttendanceDetail extends BaseModel {
  AttendanceDetail({
    this.attendanceID,
    this.attendanceName,
    this.attendanceDate,
    this.attendanceTime,
    this.attendanceDesc,
    this.memberCount,
    this.annsCount,
    this.annetsCount,
    this.visitorsCount,
    this.rotarianCount,
    this.districtDelegatesCount,
  });

  final String? attendanceID;
  final String? attendanceName;
  final String? attendanceDate;
  final String? attendanceTime;
  final String? attendanceDesc;
  final int? memberCount;
  final int? annsCount;
  final int? annetsCount;
  final int? visitorsCount;
  final int? rotarianCount;
  final int? districtDelegatesCount;

  factory AttendanceDetail.fromJson(Map<String, dynamic> json) {
    return AttendanceDetail(
      attendanceID: BaseModel.safeString(json['AttendanceID']),
      attendanceName: BaseModel.safeString(json['AttendanceName']),
      attendanceDate: BaseModel.safeString(json['AttendanceDate']),
      attendanceTime: BaseModel.safeString(json['Attendancetime']),
      attendanceDesc: BaseModel.safeString(json['AttendanceDesc']),
      memberCount: BaseModel.safeInt(json['MemberCount']),
      annsCount: BaseModel.safeInt(json['AnnsCount']),
      annetsCount: BaseModel.safeInt(json['AnnetsCount']),
      visitorsCount: BaseModel.safeInt(json['VisitorsCount']),
      rotarianCount: BaseModel.safeInt(json['RotarianCount']),
      districtDelegatesCount:
          BaseModel.safeInt(json['DistrictDelegatesCount']),
    );
  }

  /// Total attendees across all categories
  int get totalCount =>
      (memberCount ?? 0) +
      (annsCount ?? 0) +
      (annetsCount ?? 0) +
      (visitorsCount ?? 0) +
      (rotarianCount ?? 0) +
      (districtDelegatesCount ?? 0);

  /// Chart data as map of category → count
  Map<String, int> get chartData => {
        'Members': memberCount ?? 0,
        'Anns': annsCount ?? 0,
        'Annets': annetsCount ?? 0,
        'Visitors': visitorsCount ?? 0,
        'Rotarians': rotarianCount ?? 0,
        'District Delegates': districtDelegatesCount ?? 0,
      };

  String get displayDateTime {
    final parts = <String>[];
    if (attendanceDate != null && attendanceDate!.isNotEmpty) {
      parts.add(attendanceDate!);
    }
    if (attendanceTime != null && attendanceTime!.isNotEmpty) {
      parts.add(attendanceTime!);
    }
    return parts.join(' ');
  }

  @override
  Map<String, dynamic> toJson() => {
        'AttendanceID': attendanceID,
        'AttendanceName': attendanceName,
        'AttendanceDate': attendanceDate,
        'Attendancetime': attendanceTime,
        'AttendanceDesc': attendanceDesc,
        'MemberCount': memberCount,
        'AnnsCount': annsCount,
        'AnnetsCount': annetsCount,
        'VisitorsCount': visitorsCount,
        'RotarianCount': rotarianCount,
        'DistrictDelegatesCount': districtDelegatesCount,
      };
}

/// Android: AttendanceMemberDataModel — member in attendance list.
/// API: Attendance/getAttendanceMemberDetails (type=1)
class AttendanceMemberItem extends BaseModel {
  AttendanceMemberItem({
    this.memberID,
    this.memberName,
    this.designation,
    this.image,
  });

  final String? memberID;
  final String? memberName;
  final String? designation;
  final String? image;

  factory AttendanceMemberItem.fromJson(Map<String, dynamic> json) {
    return AttendanceMemberItem(
      memberID: BaseModel.safeString(json['FK_MemberID']),
      memberName: BaseModel.safeString(json['MemberName']),
      designation: BaseModel.safeString(json['Designation']),
      image: BaseModel.safeString(json['image']),
    );
  }

  bool get hasValidImage =>
      image != null && image!.isNotEmpty && image != 'null';

  String get encodedImageUrl => image?.replaceAll(' ', '%20') ?? '';

  @override
  Map<String, dynamic> toJson() => {
        'FK_MemberID': memberID,
        'MemberName': memberName,
        'Designation': designation,
        'image': image,
      };
}

/// Android: AttendanceVisitorsDataModel — visitor in attendance list.
/// API: Attendance/getAttendanceVisitorsDetails (type=2)
class AttendanceVisitorItem extends BaseModel {
  AttendanceVisitorItem({
    this.visitorID,
    this.attendanceID,
    this.visitorName,
  });

  final String? visitorID;
  final String? attendanceID;
  final String? visitorName;

  factory AttendanceVisitorItem.fromJson(Map<String, dynamic> json) {
    return AttendanceVisitorItem(
      visitorID: BaseModel.safeString(json['PK_AttendanceVisitorID']),
      attendanceID: BaseModel.safeString(json['FK_AttendanceID']),
      visitorName: BaseModel.safeString(json['VisitorsName']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'PK_AttendanceVisitorID': visitorID,
        'FK_AttendanceID': attendanceID,
        'VisitorsName': visitorName,
      };
}
