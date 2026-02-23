/// Response from Member/GetBODList.
/// Android: TBGetBODResult → { status, message, BODResult: [...] }
class TBBodListResult {
  TBBodListResult({this.status, this.message, this.members});

  final String? status;
  final String? message;
  final List<BodMember>? members;

  factory TBBodListResult.fromJson(Map<String, dynamic> json) {
    // Android response root key: TBGetBODResult
    final root = json['TBGetBODResult'] as Map<String, dynamic>? ??
        json['TBBODListResult'] as Map<String, dynamic>? ??
        json;
    // Android list key: BODResult
    final rawList = root['BODResult'] as List<dynamic>? ??
        root['Result'] as List<dynamic>? ??
        [];

    final items = rawList.map((e) {
      final map = e as Map<String, dynamic>;
      return BodMember.fromJson(map);
    }).toList();

    return TBBodListResult(
      status: root['status']?.toString(),
      message: root['message']?.toString(),
      members: items,
    );
  }
}

/// Individual BOD member entry.
/// Android: ExecutiveCommitteeDataModel fields:
/// masterUID, grpID, profileID, memberName, pic, membermobile, MemberDesignation, Email
class BodMember {
  BodMember({
    this.memberName,
    this.profileId,
    this.groupId,
    this.masterUID,
    this.mobile,
    this.designation,
    this.pic,
    this.clubName,
    this.email,
  });

  final String? memberName;
  final String? profileId;
  final String? groupId;
  final String? masterUID;
  final String? mobile;
  final String? designation;
  final String? pic;
  final String? clubName;
  final String? email;

  factory BodMember.fromJson(Map<String, dynamic> json) {
    return BodMember(
      memberName: json['memberName']?.toString(),
      profileId: json['profileID']?.toString() ?? json['profileId']?.toString(),
      groupId: json['grpID']?.toString() ?? json['groupID']?.toString(),
      masterUID: json['masterUID']?.toString(),
      mobile: json['membermobile']?.toString() ?? json['mobile']?.toString(),
      // Android key: MemberDesignation
      designation: json['MemberDesignation']?.toString() ??
          json['designation']?.toString() ??
          json['distDesignation']?.toString(),
      pic: json['pic']?.toString(),
      clubName: json['clubName']?.toString(),
      email: json['Email']?.toString() ?? json['email']?.toString(),
    );
  }
}

/// Response from PastPresidents/getPastPresidentsList.
/// iOS response: { TBPastPresidentListResult: { status, TBPastPresidentList: { newRecords: [...] } } }
class TBPastPresidentsResult {
  TBPastPresidentsResult({this.status, this.message, this.presidents});

  final String? status;
  final String? message;
  final List<PastPresident>? presidents;

  factory TBPastPresidentsResult.fromJson(Map<String, dynamic> json) {
    final root =
        json['TBPastPresidentListResult'] as Map<String, dynamic>? ?? json;
    final status = root['status']?.toString();

    // iOS: TBPastPresidentList.newRecords
    final ppList =
        root['TBPastPresidentList'] as Map<String, dynamic>?;
    final newRecords = ppList?['newRecords'] as List<dynamic>? ?? [];

    final items = newRecords.map((e) {
      final map = e as Map<String, dynamic>;
      return PastPresident.fromJson(map);
    }).toList();

    return TBPastPresidentsResult(
      status: status,
      message: root['message']?.toString(),
      presidents: items,
    );
  }
}

/// Individual past president entry.
/// iOS: NewRecord struct with CodingKeys: PastPresidentId, MemberName, PhotoPath, TenureYear.
class PastPresident {
  PastPresident({
    this.pastPresidentId,
    this.memberName,
    this.pic,
    this.year,
    this.designation,
  });

  final String? pastPresidentId;
  final String? memberName;
  final String? pic;
  final String? year;
  final String? designation;

  factory PastPresident.fromJson(Map<String, dynamic> json) {
    return PastPresident(
      pastPresidentId: json['PastPresidentId']?.toString(),
      memberName: json['MemberName']?.toString() ??
          json['memberName']?.toString(),
      pic: json['PhotoPath']?.toString() ??
          json['pic']?.toString(),
      year: json['TenureYear']?.toString() ??
          json['year']?.toString(),
      designation: json['designation']?.toString(),
    );
  }
}

/// Response from FindRotarian/GetCategoryList.
/// iOS: Gradessssss → Str → GradessTable[].
class TBCategoryListResult {
  TBCategoryListResult({this.status, this.message, this.categories});

  final String? status;
  final String? message;
  final List<CategoryItem>? categories;

  factory TBCategoryListResult.fromJson(Map<String, dynamic> json) {
    List<CategoryItem> items = [];
    final str = json['str'] as Map<String, dynamic>?;
    if (str != null) {
      final table = (str['Table'] ?? str['table']) as List<dynamic>? ?? [];
      items = table.map((e) {
        final map = e as Map<String, dynamic>;
        return CategoryItem.fromJson(map);
      }).toList();
    }
    return TBCategoryListResult(
      status: json['status']?.toString(),
      message: json['message']?.toString(),
      categories: items,
    );
  }
}

/// Category item for change request dropdown.
/// iOS: GradessTable (id, name).
class CategoryItem {
  CategoryItem({this.id, this.name});

  final String? id;
  final String? name;

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
    );
  }
}

/// Response from Member/Saveprofile (change request).
class SaveProfileResult {
  SaveProfileResult({this.status, this.message, this.serverError});

  final String? status;
  final String? message;
  final String? serverError;

  bool get isSuccess => status == '0' && serverError == null;

  factory SaveProfileResult.fromJson(Map<String, dynamic> json) {
    final result = json['result'] as Map<String, dynamic>?;
    return SaveProfileResult(
      status: json['status']?.toString(),
      message: json['message']?.toString(),
      serverError: result?['serverError']?.toString(),
    );
  }
}
