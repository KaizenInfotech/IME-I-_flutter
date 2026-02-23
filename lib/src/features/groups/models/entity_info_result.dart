/// Response from Group/GetEntityInfo.
/// iOS: TBEntityInfoResult.
class TBEntityInfoResult {
  TBEntityInfoResult({
    this.status,
    this.message,
    this.groupName,
    this.groupImg,
    this.contactNo,
    this.address,
    this.email,
    this.entityInfoItems,
    this.adminInfoItems,
  });

  final String? status;
  final String? message;
  final String? groupName;
  final String? groupImg;
  final String? contactNo;
  final String? address;
  final String? email;
  final List<EntityInfoItem>? entityInfoItems;
  final List<AdminInfoItem>? adminInfoItems;

  factory TBEntityInfoResult.fromJson(Map<String, dynamic> json) {
    final rawEntity = json['EntityInfoResult'] as List<dynamic>? ?? [];
    final rawAdmin = json['AdminInfoResult'] as List<dynamic>? ?? [];

    final entityItems = rawEntity.map((e) {
      final map = e as Map<String, dynamic>;
      return EntityInfoItem.fromJson(map);
    }).toList();

    final adminItems = rawAdmin.map((e) {
      final map = e as Map<String, dynamic>;
      return AdminInfoItem.fromJson(map);
    }).toList();

    return TBEntityInfoResult(
      status: json['status']?.toString(),
      message: json['message']?.toString(),
      groupName: json['groupName']?.toString(),
      groupImg: json['groupImg']?.toString(),
      contactNo: json['contactNo']?.toString(),
      address: json['address']?.toString(),
      email: json['email']?.toString(),
      entityInfoItems: entityItems,
      adminInfoItems: adminItems,
    );
  }
}

/// Entity info row item.
class EntityInfoItem {
  EntityInfoItem({this.key, this.value});

  final String? key;
  final String? value;

  factory EntityInfoItem.fromJson(Map<String, dynamic> json) {
    return EntityInfoItem(
      key: json['key']?.toString(),
      value: json['value']?.toString(),
    );
  }
}

/// Admin info row item.
class AdminInfoItem {
  AdminInfoItem({
    this.memberName,
    this.designation,
    this.mobile,
    this.email,
    this.pic,
    this.profileId,
  });

  final String? memberName;
  final String? designation;
  final String? mobile;
  final String? email;
  final String? pic;
  final String? profileId;

  factory AdminInfoItem.fromJson(Map<String, dynamic> json) {
    return AdminInfoItem(
      memberName: json['memberName']?.toString(),
      designation: json['designation']?.toString(),
      mobile: json['mobile']?.toString() ?? json['mobileNo']?.toString(),
      email: json['email']?.toString() ?? json['emailID']?.toString(),
      pic: json['pic']?.toString(),
      profileId: json['profileId']?.toString() ??
          json['profileID']?.toString(),
    );
  }
}

/// Response from Group/GetGroupDetail.
/// iOS: TBGetGroupResult.
class TBGetGroupDetailResult {
  TBGetGroupDetailResult({this.status, this.message, this.details});

  final String? status;
  final String? message;
  final List<GroupDetailItem>? details;

  factory TBGetGroupDetailResult.fromJson(Map<String, dynamic> json) {
    final rawList =
        json['getGroupDetailResult'] as List<dynamic>? ?? [];

    final items = rawList.map((e) {
      final map = e as Map<String, dynamic>;
      return GroupDetailItem.fromJson(map);
    }).toList();

    return TBGetGroupDetailResult(
      status: json['status']?.toString(),
      message: json['message']?.toString(),
      details: items,
    );
  }
}

/// Group detail data entry.
class GroupDetailItem {
  GroupDetailItem({
    this.grpId,
    this.grpName,
    this.grpImg,
    this.grpType,
    this.grpCategory,
    this.address1,
    this.address2,
    this.city,
    this.state,
    this.pincode,
    this.country,
    this.email,
    this.mobile,
    this.website,
    this.totalMembers,
  });

  final String? grpId;
  final String? grpName;
  final String? grpImg;
  final String? grpType;
  final String? grpCategory;
  final String? address1;
  final String? address2;
  final String? city;
  final String? state;
  final String? pincode;
  final String? country;
  final String? email;
  final String? mobile;
  final String? website;
  final String? totalMembers;

  String get formattedAddress {
    final parts = <String>[
      if (address1 != null && address1!.isNotEmpty) address1!,
      if (address2 != null && address2!.isNotEmpty) address2!,
      if (city != null && city!.isNotEmpty) city!,
      if (state != null && state!.isNotEmpty) state!,
      if (pincode != null && pincode!.isNotEmpty) pincode!,
      if (country != null && country!.isNotEmpty) country!,
    ];
    return parts.join(', ');
  }

  factory GroupDetailItem.fromJson(Map<String, dynamic> json) {
    return GroupDetailItem(
      grpId: json['grpId']?.toString(),
      grpName: json['grpName']?.toString(),
      grpImg: json['grpImg']?.toString(),
      grpType: json['grpType']?.toString(),
      grpCategory: json['grpCategory']?.toString(),
      address1: json['addrss1']?.toString(),
      address2: json['addrss2']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      pincode: json['pincode']?.toString(),
      country: json['country']?.toString(),
      email: json['emailid']?.toString(),
      mobile: json['mobile']?.toString(),
      website: json['website']?.toString(),
      totalMembers: json['totalMembers']?.toString(),
    );
  }
}
