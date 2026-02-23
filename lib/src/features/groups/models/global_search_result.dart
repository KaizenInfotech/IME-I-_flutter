/// Response from Group/GlobalSearchGroup.
/// iOS: TBGlobalSearchGroupResult.
class TBGlobalSearchGroupResult {
  TBGlobalSearchGroupResult({
    this.status,
    this.message,
    this.memberName,
    this.memberMobile,
    this.profilePicPath,
    this.groups,
  });

  final String? status;
  final String? message;
  final String? memberName;
  final String? memberMobile;
  final String? profilePicPath;
  final List<GlobalGroupItem>? groups;

  factory TBGlobalSearchGroupResult.fromJson(Map<String, dynamic> json) {
    final rawList =
        json['AllGlobalGroupListResults'] as List<dynamic>? ?? [];

    final items = rawList.map((e) {
      final map = e as Map<String, dynamic>;
      return GlobalGroupItem.fromJson(map);
    }).toList();

    return TBGlobalSearchGroupResult(
      status: json['status']?.toString(),
      message: json['message']?.toString(),
      memberName: json['membername']?.toString(),
      memberMobile: json['membermobile']?.toString(),
      profilePicPath: json['profilepicpath']?.toString(),
      groups: items,
    );
  }
}

/// Global search group result item.
/// iOS: GlobalGroupResult (grpId, grpName, grpImg, grpProfileId, isMygrp).
class GlobalGroupItem {
  GlobalGroupItem({
    this.grpId,
    this.grpName,
    this.grpImg,
    this.grpProfileId,
    this.isMyGroup,
  });

  final String? grpId;
  final String? grpName;
  final String? grpImg;
  final String? grpProfileId;
  final String? isMyGroup;

  bool get isMember => isMyGroup == '1';

  factory GlobalGroupItem.fromJson(Map<String, dynamic> json) {
    return GlobalGroupItem(
      grpId: json['grpId']?.toString(),
      grpName: json['grpName']?.toString(),
      grpImg: json['grpImg']?.toString(),
      grpProfileId: json['grpProfileId']?.toString(),
      isMyGroup: json['isMygrp']?.toString(),
    );
  }
}
