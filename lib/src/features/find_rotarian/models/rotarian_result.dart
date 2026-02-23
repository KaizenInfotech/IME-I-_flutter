import 'package:intl/intl.dart';

import '../../../core/models/base_model.dart';

/// Port of iOS ZoneChapterResult — zone and chapter dropdown data.
/// API: FindRotarian/GetZonechapterlist
/// Response key: "ZoneChapterResult" → Table (zones) + Table1 (chapters)
class TBZoneChapterResult extends BaseModel {
  TBZoneChapterResult({
    this.status,
    this.message,
    this.zones,
    this.chapters,
  });

  final String? status;
  final String? message;
  final List<ZoneItem>? zones;
  final List<ChapterItem>? chapters;

  factory TBZoneChapterResult.fromJson(Map<String, dynamic> json) {
    final result =
        json['ZoneChapterResult'] as Map<String, dynamic>? ?? json;

    // iOS: Table = zones, Table1 = chapters
    final zoneList = result['Table'] as List<dynamic>?;
    final chapterList = result['Table1'] as List<dynamic>?;

    return TBZoneChapterResult(
      status: BaseModel.safeString(json['status']),
      message: BaseModel.safeString(json['message']),
      zones: zoneList
          ?.map((e) => ZoneItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      chapters: chapterList
          ?.map((e) => ChapterItem.fromJson(e as Map<String, dynamic>))
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

/// Zone item from GetZonechapterlist Table array.
class ZoneItem extends BaseModel {
  ZoneItem({
    this.zoneID,
    this.zoneName,
  });

  final String? zoneID;
  final String? zoneName;

  factory ZoneItem.fromJson(Map<String, dynamic> json) {
    return ZoneItem(
      zoneID: BaseModel.safeString(json['ZoneID']),
      zoneName: BaseModel.safeString(json['ZoneName']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'ZoneID': zoneID,
        'ZoneName': zoneName,
      };
}

/// Chapter item from GetZonechapterlist Table1 array.
/// Each chapter belongs to a zone (ZoneID).
class ChapterItem extends BaseModel {
  ChapterItem({
    this.chapterID,
    this.chapterName,
    this.zoneID,
  });

  final String? chapterID;
  final String? chapterName;
  final String? zoneID;

  factory ChapterItem.fromJson(Map<String, dynamic> json) {
    return ChapterItem(
      chapterID: BaseModel.safeString(json['ChapterID']),
      chapterName: BaseModel.safeString(json['ChapterName']),
      zoneID: BaseModel.safeString(json['ZoneID']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'ChapterID': chapterID,
        'ChapterName': chapterName,
        'ZoneID': zoneID,
      };
}

/// Port of iOS TBGetRotarianResult — rotarian search list response.
/// API: FindRotarian/GetRotarianList
/// Response key: "TBGetRotarianResult"
class TBGetRotarianResult extends BaseModel {
  TBGetRotarianResult({
    this.status,
    this.message,
    this.rotarians,
  });

  final String? status;
  final String? message;
  final List<RotarianItem>? rotarians;

  factory TBGetRotarianResult.fromJson(Map<String, dynamic> json) {
    final result = json['RotarianResult'] as List<dynamic>?;

    return TBGetRotarianResult(
      status: BaseModel.safeString(json['status']),
      message: BaseModel.safeString(json['message']),
      rotarians: result
          ?.map((e) => RotarianItem.fromJson(e as Map<String, dynamic>))
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

/// Single rotarian from search results.
/// iOS: RotarianResult struct — CodingKeys: masterUID, groupID,
/// member_Name, memberMobile, mem_Category, Grade, clubName, pic.
class RotarianItem extends BaseModel {
  RotarianItem({
    this.masterUID,
    this.groupID,
    this.profileID,
    this.clubName,
    this.memberMobile,
    this.memberName,
    this.memCategory,
    this.grade,
    this.pic,
  });

  final String? masterUID;
  final String? groupID;
  final String? profileID;
  final String? clubName;
  final String? memberMobile;
  final String? memberName;
  final String? memCategory;
  final String? grade;
  final String? pic;

  factory RotarianItem.fromJson(Map<String, dynamic> json) {
    return RotarianItem(
      masterUID: BaseModel.safeString(json['masterUID']),
      groupID: BaseModel.safeString(json['groupID']),
      // iOS: extracted via KVC from raw NSDictionary (not in Codable struct)
      profileID: BaseModel.safeString(json['profileID']),
      clubName: BaseModel.safeString(json['clubName']),
      memberMobile: BaseModel.safeString(json['memberMobile']),
      // iOS CodingKey: memberName = "member_Name"
      memberName: BaseModel.safeString(json['member_Name']),
      // iOS CodingKey: memCategory = "mem_Category"
      memCategory: BaseModel.safeString(json['mem_Category']),
      // iOS CodingKey: grade = "Grade"
      grade: BaseModel.safeString(json['Grade']),
      pic: BaseModel.safeString(json['pic']),
    );
  }

  /// iOS: check if pic URL is valid
  bool get hasValidPic =>
      pic != null && pic!.isNotEmpty && pic!.startsWith('http');

  /// iOS: URL-encode spaces in image URL
  String? get encodedPicUrl => pic?.replaceAll(' ', '%20');

  @override
  Map<String, dynamic> toJson() => {
        'masterUID': masterUID,
        'groupID': groupID,
        'clubName': clubName,
        'memberMobile': memberMobile,
        'member_Name': memberName,
        'mem_Category': memCategory,
        'Grade': grade,
        'pic': pic,
      };
}

/// Port of iOS TBGetRotarianResult — rotarian detail response.
/// API: FindRotarian/GetRotarianDetails
/// iOS response: { TBGetRotarianResult: { status, message, Result: { Table: [...] } } }
class TBRotarianDetailResult extends BaseModel {
  TBRotarianDetailResult({
    this.status,
    this.message,
    this.detail,
  });

  final String? status;
  final String? message;
  final RotarianDetail? detail;

  factory TBRotarianDetailResult.fromJson(Map<String, dynamic> json) {
    // iOS: JitoProfileViewController uses lowercase "result",
    // MemberSearchProfileViewController uses uppercase "Result"
    final result = json['Result'] ?? json['result'];
    Map<String, dynamic>? profileData;

    if (result is Map<String, dynamic>) {
      // iOS structure: Result.Table[0]
      final table = result['Table'] as List<dynamic>?;
      if (table != null && table.isNotEmpty) {
        profileData = table.first as Map<String, dynamic>;
      } else {
        // Fallback: Result is a flat map
        profileData = result;
      }
    } else if (result is List<dynamic> && result.isNotEmpty) {
      // Fallback: Result is directly a list
      profileData = result.first as Map<String, dynamic>;
    }

    return TBRotarianDetailResult(
      status: BaseModel.safeString(json['status']),
      message: BaseModel.safeString(json['message']),
      detail:
          profileData != null ? RotarianDetail.fromJson(profileData) : null,
    );
  }

  bool get isSuccess => status == '0';

  @override
  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
      };
}

/// Detailed rotarian profile.
/// iOS: MemberSearchProfileTable from GetRotarianDetails Result.Table[0].
/// Also supports flat Result map for backward compat.
class RotarianDetail extends BaseModel {
  RotarianDetail({
    this.memberName,
    this.pic,
    this.masterUID,
    this.memberMobile,
    this.secondaryMobile,
    this.memberEmail,
    this.email,
    this.businessAddress,
    this.city,
    this.state,
    this.country,
    this.pincode,
    this.businessName,
    this.designation,
    this.phoneNo,
    this.fax,
    this.classification,
    this.clubName,
    this.clubDesignation,
    this.bloodGroup,
    this.donorRecognition,
    this.keywords,
    this.chaptrBrnchName,
    this.membershipNo,
    this.membershipGrade,
    this.categoryName,
    this.dob,
    this.doa,
    this.anniversary,
    this.whatsappNum,
    this.hideWhatsnum,
    this.hideMail,
    this.hideNum,
    this.address,
    this.companyName,
  });

  final String? memberName;
  final String? pic;
  final String? masterUID;
  final String? memberMobile;
  final String? secondaryMobile;
  final String? memberEmail;
  final String? email;
  final String? businessAddress;
  final String? city;
  final String? state;
  final String? country;
  final String? pincode;
  final String? businessName;
  final String? designation;
  final String? phoneNo;
  final String? fax;
  final String? classification;
  final String? clubName;
  final String? clubDesignation;
  final String? bloodGroup;
  final String? donorRecognition;
  final String? keywords;
  // MemberSearchProfileTable fields (profile.PNG)
  final String? chaptrBrnchName;
  final String? membershipNo;
  final String? membershipGrade;
  final String? categoryName;
  final String? dob;
  final String? doa;
  final String? anniversary;
  final String? whatsappNum;
  final String? hideWhatsnum;
  final String? hideMail;
  final String? hideNum;
  final String? address;
  final String? companyName;

  factory RotarianDetail.fromJson(Map<String, dynamic> json) {
    return RotarianDetail(
      // Try both key naming conventions (flat Result vs Table[0])
      memberName: BaseModel.safeString(json['memberName'] ??
          json['member_name']),
      pic: BaseModel.safeString(json['pic'] ??
          json['member_profile_photo_path']),
      masterUID: BaseModel.safeString(json['masterUID']),
      memberMobile: BaseModel.safeString(json['memberMobile'] ??
          json['Whatsapp_num']),
      secondaryMobile: BaseModel.safeString(json['SecondaryMobile'] ??
          json['Secondry_num']),
      memberEmail: BaseModel.safeString(json['memberEmail'] ??
          json['member_email_id']),
      email: BaseModel.safeString(json['Email']),
      businessAddress: BaseModel.safeString(json['BusinessAddress']),
      city: BaseModel.safeString(json['city'] ?? json['City']),
      state: BaseModel.safeString(json['state'] ?? json['State']),
      country: BaseModel.safeString(json['country'] ?? json['Country']),
      pincode: BaseModel.safeString(json['pincode']),
      businessName: BaseModel.safeString(json['BusinessName']),
      designation: BaseModel.safeString(json['designation']),
      phoneNo: BaseModel.safeString(json['phoneNo']),
      fax: BaseModel.safeString(json['Fax']),
      classification: BaseModel.safeString(json['Classification']),
      clubName: BaseModel.safeString(json['clubName'] ??
          json['Chaptr_Brnch_Name']),
      clubDesignation: BaseModel.safeString(json['clubDesignation']),
      bloodGroup: BaseModel.safeString(json['blood_Group']),
      donorRecognition: BaseModel.safeString(json['Donor_Recognition']),
      keywords: BaseModel.safeString(json['Keywords']),
      // MemberSearchProfileTable fields
      chaptrBrnchName: BaseModel.safeString(json['Chaptr_Brnch_Name']),
      membershipNo: BaseModel.safeString(json['IMEI_Membership_Id']),
      membershipGrade: BaseModel.safeString(json['Membership_Grade']),
      categoryName: BaseModel.safeString(json['CategoryName']),
      dob: BaseModel.safeString(json['DOB']),
      doa: BaseModel.safeString(json['DOA']),
      anniversary: BaseModel.safeString(json['annivarsary'] ??
          json['anniversary'] ??
          json['member_date_of_wedding']),
      whatsappNum: BaseModel.safeString(json['Whatsapp_num']),
      hideWhatsnum: BaseModel.safeString(json['hide_whatsnum']),
      hideMail: BaseModel.safeString(json['hide_mail']),
      hideNum: BaseModel.safeString(json['hide_num']),
      address: BaseModel.safeString(json['Address']),
      companyName: BaseModel.safeString(json['Company_name']),
    );
  }

  /// iOS: pic URL with spaces encoded
  bool get hasValidPic =>
      pic != null && pic!.isNotEmpty && pic!.startsWith('http');

  String? get encodedPicUrl => pic?.replaceAll(' ', '%20');

  /// iOS: formatted full address from business fields
  String get fullAddress {
    final parts = <String>[];
    if (businessAddress != null && businessAddress!.isNotEmpty) {
      parts.add(businessAddress!);
    }
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (country != null && country!.isNotEmpty) parts.add(country!);
    if (pincode != null && pincode!.isNotEmpty) parts.add(pincode!);
    return parts.join(', ');
  }

  /// All phone numbers available for contact actions
  List<String> get allPhoneNumbers {
    final numbers = <String>[];
    if (memberMobile != null && memberMobile!.trim().isNotEmpty) {
      numbers.add(memberMobile!.trim());
    }
    if (secondaryMobile != null && secondaryMobile!.trim().isNotEmpty) {
      numbers.add(secondaryMobile!.trim());
    }
    if (phoneNo != null && phoneNo!.trim().isNotEmpty) {
      numbers.add(phoneNo!.trim());
    }
    return numbers;
  }

  /// All email addresses available for contact actions
  List<String> get allEmails {
    final emails = <String>[];
    if (memberEmail != null && memberEmail!.trim().isNotEmpty) {
      emails.add(memberEmail!.trim());
    }
    if (email != null && email!.trim().isNotEmpty) {
      emails.add(email!.trim());
    }
    return emails;
  }

  /// Profile key-value pairs for display (iOS: JitoProfileViewController fields)
  /// Matches profile.PNG: Chapter/Branch Name, Membership No., Membership Grade,
  /// Category, Email, Date of Birth, Date of Anniversary.
  /// Check if a date string is a valid displayable date
  /// (filters out SQL Server placeholder dates like 01/01/1753)
  bool _isValidDate(String? value) {
    if (value == null || value.trim().isEmpty) return false;
    return true;
  }

  /// Format date from API format (dd/MM/yyyy) to display format (d MMM yyyy)
  /// e.g. "26/07/2002" → "26 Jul 2002"
  String? _formatDate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    try {
      final parsed = DateFormat('dd/MM/yyyy').parse(value.trim());
      return DateFormat('d MMM yyyy').format(parsed);
    } catch (_) {
      return value;
    }
  }

  List<MapEntry<String, String>> get profileFields {
    final fields = <MapEntry<String, String>>[];
    void add(String key, String? value) {
      if (value != null && value.trim().isNotEmpty) {
        fields.add(MapEntry(key, value.trim()));
      }
    }

    add('Chapter/Branch Name', chaptrBrnchName ?? clubName);
    add('Membership No.', membershipNo);
    add('Membership Grade', membershipGrade);
    add('Category', categoryName);
    add('Email', memberEmail ?? email);
    final dobValue = _isValidDate(dob) ? _formatDate(dob) : null;
    add('Date of Birth', dobValue);
    final annivValue = _isValidDate(doa)
        ? _formatDate(doa)
        : (_isValidDate(anniversary) ? _formatDate(anniversary) : null);
    add('Date of Anniversary', annivValue);
    add('Company Name', companyName);
    add('Address', address);
    add('Pincode', pincode);
    add('Country', country);
    return fields;
  }

  @override
  Map<String, dynamic> toJson() => {
        'memberName': memberName,
        'pic': pic,
        'masterUID': masterUID,
        'memberMobile': memberMobile,
        'SecondaryMobile': secondaryMobile,
        'memberEmail': memberEmail,
        'Email': email,
        'BusinessAddress': businessAddress,
        'city': city,
        'state': state,
        'country': country,
        'pincode': pincode,
        'BusinessName': businessName,
        'designation': designation,
        'phoneNo': phoneNo,
        'Fax': fax,
        'Classification': classification,
        'clubName': clubName,
        'clubDesignation': clubDesignation,
        'blood_Group': bloodGroup,
        'Donor_Recognition': donorRecognition,
        'Keywords': keywords,
      };
}
