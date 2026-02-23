import '../../../core/models/base_model.dart';

/// Port of iOS district member list response.
/// API: District/GetDistrictMemberList (POST)
/// Response: status, resultCount, TotalPages, currentPage, Result (parallel arrays)
class TBDistrictMemberListResult extends BaseModel {
  TBDistrictMemberListResult({
    this.status,
    this.message,
    this.resultCount,
    this.totalPages,
    this.currentPage,
    this.members,
  });

  final String? status;
  final String? message;
  final String? resultCount;
  final String? totalPages;
  final String? currentPage;
  final List<DistrictMember>? members;

  factory TBDistrictMemberListResult.fromJson(Map<String, dynamic> json) {
    final result = json['Result'] as Map<String, dynamic>?;
    List<DistrictMember>? members;

    if (result != null) {
      // iOS: parallel arrays — profileID[], memberName[], membermobile[], etc.
      final profileIds = result['profileID'] as List<dynamic>? ?? [];
      final names = result['memberName'] as List<dynamic>? ?? [];
      final mobiles = result['membermobile'] as List<dynamic>? ?? [];
      final masterUIDs = result['masterUID'] as List<dynamic>? ?? [];
      final pics = result['pic'] as List<dynamic>? ?? [];
      final grpIDs = result['grpID'] as List<dynamic>? ?? [];
      final clubNames = result['club_name'] as List<dynamic>? ?? [];

      final count = profileIds.length;
      members = List.generate(count, (i) {
        return DistrictMember(
          profileId: i < profileIds.length ? profileIds[i]?.toString() : null,
          memberName: i < names.length ? names[i]?.toString() : null,
          memberMobile: i < mobiles.length ? mobiles[i]?.toString() : null,
          masterUID: i < masterUIDs.length ? masterUIDs[i]?.toString() : null,
          pic: i < pics.length ? pics[i]?.toString() : null,
          grpID: i < grpIDs.length ? grpIDs[i]?.toString() : null,
          clubName: i < clubNames.length ? clubNames[i]?.toString() : null,
        );
      });
    }

    return TBDistrictMemberListResult(
      status: BaseModel.safeString(json['status']),
      message: BaseModel.safeString(json['message']),
      resultCount: BaseModel.safeString(json['resultCount']),
      totalPages: BaseModel.safeString(json['TotalPages']),
      currentPage: BaseModel.safeString(json['currentPage']),
      members: members,
    );
  }

  bool get isSuccess => status == '0';

  int get totalPagesInt => int.tryParse(totalPages ?? '1') ?? 1;
  int get currentPageInt => int.tryParse(currentPage ?? '1') ?? 1;

  @override
  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'resultCount': resultCount,
        'TotalPages': totalPages,
        'currentPage': currentPage,
      };
}

/// Single district member parsed from parallel arrays.
class DistrictMember extends BaseModel {
  DistrictMember({
    this.profileId,
    this.memberName,
    this.memberMobile,
    this.masterUID,
    this.pic,
    this.grpID,
    this.clubName,
  });

  final String? profileId;
  final String? memberName;
  final String? memberMobile;
  final String? masterUID;
  final String? pic;
  final String? grpID;
  final String? clubName;

  bool get hasValidPic =>
      pic != null && pic!.isNotEmpty && pic!.startsWith('http');

  String? get encodedPicUrl => pic?.replaceAll(' ', '%20');

  @override
  Map<String, dynamic> toJson() => {
        'profileID': profileId,
        'memberName': memberName,
        'membermobile': memberMobile,
        'masterUID': masterUID,
        'pic': pic,
        'grpID': grpID,
        'club_name': clubName,
      };
}

/// Member detail with dynamic fields (personal, business, address).
/// API: District/GetMemberWithDynamicFields
/// Response: MemberListDetailResult → MemberDetails
class TBMemberDetailResult extends BaseModel {
  TBMemberDetailResult({
    this.status,
    this.message,
    this.detail,
  });

  final String? status;
  final String? message;
  final MemberDetailData? detail;

  factory TBMemberDetailResult.fromJson(Map<String, dynamic> json) {
    final memberDetails = json['MemberDetails'] as Map<String, dynamic>?;

    return TBMemberDetailResult(
      status: BaseModel.safeString(json['status']),
      message: BaseModel.safeString(json['message']),
      detail: memberDetails != null
          ? MemberDetailData.fromJson(memberDetails)
          : null,
    );
  }

  bool get isSuccess => status == '0';

  @override
  Map<String, dynamic> toJson() => {'status': status, 'message': message};
}

/// Detailed member data with personal/business/address sections.
class MemberDetailData extends BaseModel {
  MemberDetailData({
    this.profilePic,
    this.memberName,
    this.memberEmail,
    this.memberMobile,
    this.personalDetails,
    this.businessDetails,
    this.addresses,
  });

  final String? profilePic;
  final String? memberName;
  final String? memberEmail;
  final String? memberMobile;
  final List<KeyValueField>? personalDetails;
  final List<KeyValueField>? businessDetails;
  final List<AddressDetail>? addresses;

  factory MemberDetailData.fromJson(Map<String, dynamic> json) {
    return MemberDetailData(
      profilePic: BaseModel.safeString(json['profilePic']),
      memberName: BaseModel.safeString(json['memberName']),
      memberEmail: BaseModel.safeString(json['memberEmail']),
      memberMobile: BaseModel.safeString(json['memberMobile']),
      personalDetails:
          _parseKeyValueFields(json['personalMemberDetails']),
      businessDetails:
          _parseKeyValueFields(json['businessMemberDetails']),
      addresses: _parseAddresses(json['addressDetails']),
    );
  }

  /// iOS: parallel arrays key[] + value[] + uniquekey[]
  static List<KeyValueField>? _parseKeyValueFields(dynamic data) {
    if (data == null) return null;
    final map = data as Map<String, dynamic>;
    final keys = map['key'] as List<dynamic>? ?? [];
    final values = map['value'] as List<dynamic>? ?? [];

    final count = keys.length;
    return List.generate(count, (i) {
      return KeyValueField(
        key: i < keys.length ? keys[i]?.toString() : null,
        value: i < values.length ? values[i]?.toString() : null,
      );
    });
  }

  static List<AddressDetail>? _parseAddresses(dynamic data) {
    if (data == null) return null;
    final map = data as Map<String, dynamic>;
    final resultList = map['addressResult'] as List<dynamic>?;
    if (resultList == null) return null;

    return resultList
        .map((e) => AddressDetail.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  bool get hasValidPic =>
      profilePic != null &&
      profilePic!.isNotEmpty &&
      profilePic!.startsWith('http');

  String? get encodedPicUrl => profilePic?.replaceAll(' ', '%20');

  /// All phone numbers for contact actions
  List<String> get allPhoneNumbers {
    final numbers = <String>[];
    if (memberMobile != null && memberMobile!.trim().isNotEmpty) {
      numbers.add(memberMobile!.trim());
    }
    // Also check personal details for phone fields
    if (personalDetails != null) {
      for (final field in personalDetails!) {
        if (field.key != null &&
            (field.key!.toLowerCase().contains('telephone') ||
                field.key!.toLowerCase().contains('mobile')) &&
            field.value != null &&
            field.value!.trim().isNotEmpty) {
          if (!numbers.contains(field.value!.trim())) {
            numbers.add(field.value!.trim());
          }
        }
      }
    }
    return numbers;
  }

  /// All emails for contact actions
  List<String> get allEmails {
    final emails = <String>[];
    if (memberEmail != null && memberEmail!.trim().isNotEmpty) {
      emails.add(memberEmail!.trim());
    }
    if (personalDetails != null) {
      for (final field in personalDetails!) {
        if (field.key != null &&
            field.key!.toLowerCase().contains('email') &&
            field.value != null &&
            field.value!.trim().isNotEmpty) {
          if (!emails.contains(field.value!.trim())) {
            emails.add(field.value!.trim());
          }
        }
      }
    }
    return emails;
  }

  @override
  Map<String, dynamic> toJson() => {
        'profilePic': profilePic,
        'memberName': memberName,
        'memberEmail': memberEmail,
        'memberMobile': memberMobile,
      };
}

/// Key-value pair from personalMemberDetails / businessMemberDetails.
class KeyValueField {
  KeyValueField({this.key, this.value});

  final String? key;
  final String? value;

  bool get hasValue =>
      value != null && value!.trim().isNotEmpty && value != 'N/A';
}

/// Address detail from addressDetails.addressResult.
class AddressDetail extends BaseModel {
  AddressDetail({
    this.address,
    this.city,
    this.state,
    this.country,
    this.pincode,
    this.fax,
    this.phoneNo,
  });

  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? pincode;
  final String? fax;
  final String? phoneNo;

  factory AddressDetail.fromJson(Map<String, dynamic> json) {
    return AddressDetail(
      address: BaseModel.safeString(json['address']),
      city: BaseModel.safeString(json['city']),
      state: BaseModel.safeString(json['state']),
      country: BaseModel.safeString(json['country']),
      pincode: BaseModel.safeString(json['pincode']),
      fax: BaseModel.safeString(json['fax']),
      phoneNo: BaseModel.safeString(json['phoneNo']),
    );
  }

  String get fullAddress {
    final parts = <String>[];
    if (address != null && address!.isNotEmpty) parts.add(address!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (country != null && country!.isNotEmpty) parts.add(country!);
    if (pincode != null && pincode!.isNotEmpty) parts.add(pincode!);
    return parts.join(', ');
  }

  @override
  Map<String, dynamic> toJson() => {
        'address': address,
        'city': city,
        'state': state,
        'country': country,
        'pincode': pincode,
        'fax': fax,
        'phoneNo': phoneNo,
      };
}

/// Classification item from District/GetClassificationList_New.
class ClassificationItem {
  ClassificationItem({this.classificationName, this.count});

  final String? classificationName;
  final int? count;

  factory ClassificationItem.fromJson(Map<String, dynamic> json) {
    return ClassificationItem(
      classificationName: json['classification']?.toString(),
      count: json['count'] is int
          ? json['count'] as int
          : int.tryParse(json['count']?.toString() ?? '0'),
    );
  }
}

/// District club from District/GetClubs.
/// Response: ClubListResult → Clubs (parallel arrays)
class TBDistrictClubListResult extends BaseModel {
  TBDistrictClubListResult({
    this.status,
    this.message,
    this.clubs,
  });

  final String? status;
  final String? message;
  final List<DistrictClub>? clubs;

  factory TBDistrictClubListResult.fromJson(Map<String, dynamic> json) {
    final clubsData = json['Clubs'] as Map<String, dynamic>?;
    List<DistrictClub>? clubs;

    if (clubsData != null) {
      final grpIDs = clubsData['grpID'] as List<dynamic>? ?? [];
      final clubIds = clubsData['clubId'] as List<dynamic>? ?? [];
      final clubNames = clubsData['clubName'] as List<dynamic>? ?? [];
      final meetingDays = clubsData['meetingDay'] as List<dynamic>? ?? [];
      final meetingTimes = clubsData['meetingTime'] as List<dynamic>? ?? [];

      final count = grpIDs.length;
      clubs = List.generate(count, (i) {
        return DistrictClub(
          grpID: i < grpIDs.length ? grpIDs[i]?.toString() : null,
          clubId: i < clubIds.length ? clubIds[i]?.toString() : null,
          clubName: i < clubNames.length ? clubNames[i]?.toString() : null,
          meetingDay:
              i < meetingDays.length ? meetingDays[i]?.toString() : null,
          meetingTime:
              i < meetingTimes.length ? meetingTimes[i]?.toString() : null,
        );
      });
    }

    return TBDistrictClubListResult(
      status: BaseModel.safeString(json['status']),
      message: BaseModel.safeString(json['message']),
      clubs: clubs,
    );
  }

  bool get isSuccess => status == '0';

  @override
  Map<String, dynamic> toJson() => {'status': status, 'message': message};
}

/// Single district club.
class DistrictClub extends BaseModel {
  DistrictClub({
    this.grpID,
    this.clubId,
    this.clubName,
    this.meetingDay,
    this.meetingTime,
  });

  final String? grpID;
  final String? clubId;
  final String? clubName;
  final String? meetingDay;
  final String? meetingTime;

  String get displayMeetingInfo {
    final parts = <String>[];
    if (meetingDay != null && meetingDay!.isNotEmpty) parts.add(meetingDay!);
    if (meetingTime != null && meetingTime!.isNotEmpty) parts.add(meetingTime!);
    return parts.join(' | ');
  }

  @override
  Map<String, dynamic> toJson() => {
        'grpID': grpID,
        'clubId': clubId,
        'clubName': clubName,
        'meetingDay': meetingDay,
        'meetingTime': meetingTime,
      };
}
