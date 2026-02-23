import '../../../core/models/base_model.dart';

/// Port of iOS TBGetClubResult — club search list response.
/// API: FindClub/GetClubList
/// Response key: "TBGetClubResult" → "ClubResult"
class TBGetClubResult extends BaseModel {
  TBGetClubResult({
    this.status,
    this.message,
    this.clubs,
  });

  final String? status;
  final String? message;
  final List<ClubItem>? clubs;

  factory TBGetClubResult.fromJson(Map<String, dynamic> json) {
    final result = json['ClubResult'] as List<dynamic>?;

    return TBGetClubResult(
      status: BaseModel.safeString(json['status']),
      message: BaseModel.safeString(json['message']),
      clubs: result
          ?.map((e) => ClubItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  bool get isSuccess => status == '0';

  @override
  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
      };
}

/// Single club from search results.
/// iOS: Stored in Find_A_Club_List SQLite table with these fields.
class ClubItem extends BaseModel {
  ClubItem({
    this.groupId,
    this.clubName,
    this.clubType,
    this.clubId,
    this.district,
    this.charterDate,
    this.meetingDay,
    this.meetingTime,
    this.website,
    this.distance,
  });

  final String? groupId;
  final String? clubName;
  final String? clubType;
  final String? clubId;
  final String? district;
  final String? charterDate;
  final String? meetingDay;
  final String? meetingTime;
  final String? website;
  final String? distance;

  factory ClubItem.fromJson(Map<String, dynamic> json) {
    return ClubItem(
      groupId: BaseModel.safeString(json['GroupId']),
      clubName: BaseModel.safeString(json['ClubName']),
      clubType: BaseModel.safeString(json['ClubType']),
      clubId: BaseModel.safeString(json['ClubId']),
      district: BaseModel.safeString(json['District']),
      charterDate: BaseModel.safeString(json['CharterDate']),
      meetingDay: BaseModel.safeString(json['MeetingDay']),
      meetingTime: BaseModel.safeString(json['MeetingTime']),
      website: BaseModel.safeString(json['Website']),
      distance: BaseModel.safeString(json['distance']),
    );
  }

  /// iOS: "MeetingDay | MeetingTime" display
  String get displayMeetingInfo {
    final parts = <String>[];
    if (meetingDay != null && meetingDay!.isNotEmpty) parts.add(meetingDay!);
    if (meetingTime != null && meetingTime!.isNotEmpty) parts.add(meetingTime!);
    return parts.join(' | ');
  }

  /// Distance in KM (for near-me results)
  String? get displayDistance {
    if (distance == null || distance!.isEmpty) return null;
    final d = double.tryParse(distance!);
    if (d == null) return distance;
    return '${d.toStringAsFixed(2)} km';
  }

  @override
  Map<String, dynamic> toJson() => {
        'GroupId': groupId,
        'ClubName': clubName,
        'ClubType': clubType,
        'ClubId': clubId,
        'District': district,
        'CharterDate': charterDate,
        'MeetingDay': meetingDay,
        'MeetingTime': meetingTime,
        'Website': website,
        'distance': distance,
      };
}

/// Port of iOS TBGetClubDetailResult — club detail response.
/// API: FindClub/GetClubDetails
/// Response key: "TBGetClubDetailResult" → "ClubDetailResult"
class TBGetClubDetailResult extends BaseModel {
  TBGetClubDetailResult({
    this.status,
    this.message,
    this.detail,
  });

  final String? status;
  final String? message;
  final ClubDetail? detail;

  factory TBGetClubDetailResult.fromJson(Map<String, dynamic> json) {
    final result = json['ClubDetailResult'] as Map<String, dynamic>?;

    return TBGetClubDetailResult(
      status: BaseModel.safeString(json['status']),
      message: BaseModel.safeString(json['message']),
      detail: result != null ? ClubDetail.fromJson(result) : null,
    );
  }

  bool get isSuccess => status == '0';

  @override
  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
      };
}

/// Detailed club info with address, contacts, and map coordinates.
/// iOS: InfoSegmentFindAClubViewController parses these fields.
class ClubDetail extends BaseModel {
  ClubDetail({
    this.clubId,
    this.districtId,
    this.clubName,
    this.address,
    this.city,
    this.state,
    this.country,
    this.meetingDay,
    this.meetingTime,
    this.clubWebsite,
    this.lat,
    this.longi,
    this.presidentName,
    this.presidentMobile,
    this.presidentEmail,
    this.secretaryName,
    this.secretaryMobile,
    this.secretaryEmail,
    this.governorName,
    this.governorMobile,
    this.governorEmail,
  });

  final String? clubId;
  final String? districtId;
  final String? clubName;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? meetingDay;
  final String? meetingTime;
  final String? clubWebsite;
  final String? lat;
  final String? longi;
  final String? presidentName;
  final String? presidentMobile;
  final String? presidentEmail;
  final String? secretaryName;
  final String? secretaryMobile;
  final String? secretaryEmail;
  final String? governorName;
  final String? governorMobile;
  final String? governorEmail;

  factory ClubDetail.fromJson(Map<String, dynamic> json) {
    // iOS: officer arrays — take first element if available
    String? firstFromList(dynamic value) {
      if (value is List && value.isNotEmpty) {
        return value.first?.toString();
      }
      if (value is String) return value;
      return null;
    }

    // President
    final presMap = json['president'] as Map<String, dynamic>?;
    final secMap = json['secretary'] as Map<String, dynamic>?;
    final govMap = json['districtGovernor'] as Map<String, dynamic>?;

    return ClubDetail(
      clubId: BaseModel.safeString(json['clubId']),
      districtId: BaseModel.safeString(json['districtId']),
      clubName: BaseModel.safeString(json['clubName']),
      address: BaseModel.safeString(json['address']),
      city: BaseModel.safeString(json['city']),
      state: BaseModel.safeString(json['state']),
      country: BaseModel.safeString(json['country']),
      meetingDay: BaseModel.safeString(json['meetingDay']),
      meetingTime: BaseModel.safeString(json['meetingTime']),
      clubWebsite: BaseModel.safeString(json['clubWebsite']),
      lat: BaseModel.safeString(json['lat']),
      longi: BaseModel.safeString(json['longi']),
      presidentName: presMap != null ? firstFromList(presMap['name']) : null,
      presidentMobile:
          presMap != null ? firstFromList(presMap['mobileNo']) : null,
      presidentEmail:
          presMap != null ? firstFromList(presMap['emailId']) : null,
      secretaryName: secMap != null ? firstFromList(secMap['name']) : null,
      secretaryMobile:
          secMap != null ? firstFromList(secMap['mobileNo']) : null,
      secretaryEmail:
          secMap != null ? firstFromList(secMap['emailId']) : null,
      governorName: govMap != null ? firstFromList(govMap['name']) : null,
      governorMobile:
          govMap != null ? firstFromList(govMap['mobileNo']) : null,
      governorEmail:
          govMap != null ? firstFromList(govMap['emailId']) : null,
    );
  }

  /// Full formatted address
  String get fullAddress {
    final parts = <String>[];
    if (address != null && address!.isNotEmpty) parts.add(address!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (country != null && country!.isNotEmpty) parts.add(country!);
    return parts.join(', ');
  }

  /// Whether map coordinates are available
  bool get hasCoordinates {
    final latVal = double.tryParse(lat ?? '');
    final lngVal = double.tryParse(longi ?? '');
    return latVal != null && lngVal != null && latVal != 0 && lngVal != 0;
  }

  /// Meeting info display
  String get displayMeetingInfo {
    final parts = <String>[];
    if (meetingDay != null && meetingDay!.isNotEmpty) parts.add(meetingDay!);
    if (meetingTime != null && meetingTime!.isNotEmpty) parts.add(meetingTime!);
    return parts.join(' | ');
  }

  @override
  Map<String, dynamic> toJson() => {
        'clubId': clubId,
        'districtId': districtId,
        'clubName': clubName,
        'address': address,
        'city': city,
        'state': state,
        'country': country,
        'meetingDay': meetingDay,
        'meetingTime': meetingTime,
        'clubWebsite': clubWebsite,
        'lat': lat,
        'longi': longi,
      };
}

/// Club member from FindClub/GetClubMembers.
class ClubMember extends BaseModel {
  ClubMember({
    this.memberName,
    this.designation,
    this.profileId,
    this.pic,
    this.memberMobile,
  });

  final String? memberName;
  final String? designation;
  final String? profileId;
  final String? pic;
  final String? memberMobile;

  factory ClubMember.fromJson(Map<String, dynamic> json) {
    return ClubMember(
      memberName: BaseModel.safeString(json['memberName']),
      designation: BaseModel.safeString(json['designation']),
      profileId: BaseModel.safeString(json['profileId']),
      pic: BaseModel.safeString(json['pic']),
      memberMobile: BaseModel.safeString(json['memberMobile']),
    );
  }

  bool get hasValidPic =>
      pic != null && pic!.isNotEmpty && pic!.startsWith('http');

  String? get encodedPicUrl => pic?.replaceAll(' ', '%20');

  @override
  Map<String, dynamic> toJson() => {
        'memberName': memberName,
        'designation': designation,
        'profileId': profileId,
        'pic': pic,
        'memberMobile': memberMobile,
      };
}
