/// Response from setting/GetGroupSetting.
/// iOS: TBGroupSettingResult + GRpSettingDetails (Obj-C models).
class TBGroupSettingResult {
  TBGroupSettingResult({
    this.status,
    this.message,
    this.isMob,
    this.isEmail,
    this.isPersonal,
    this.isFamily,
    this.isBusiness,
    this.settings,
  });

  final String? status;
  final String? message;
  final String? isMob;
  final String? isEmail;
  final String? isPersonal;
  final String? isFamily;
  final String? isBusiness;
  final List<GroupSettingItem>? settings;

  factory TBGroupSettingResult.fromJson(Map<String, dynamic> json) {
    final result =
        json['TBGroupSettingResult'] as Map<String, dynamic>? ?? json;
    final rawList =
        result['GRpSettingResult'] as List<dynamic>? ?? [];

    final items = rawList.map((e) {
      final map = e as Map<String, dynamic>;
      final details =
          map['GRpSettingDetails'] as Map<String, dynamic>? ?? map;
      return GroupSettingItem.fromJson(details);
    }).toList();

    return TBGroupSettingResult(
      status: result['status']?.toString(),
      message: result['message']?.toString(),
      isMob: result['isMob']?.toString(),
      isEmail: result['isEmail']?.toString(),
      isPersonal: result['isPersonal']?.toString(),
      isFamily: result['isFamily']?.toString(),
      isBusiness: result['isBusiness']?.toString(),
      settings: items,
    );
  }
}

/// Individual module setting toggle.
/// iOS: GRpSettingDetails (moduleId, modVal, modName).
class GroupSettingItem {
  GroupSettingItem({this.moduleId, this.modVal, this.modName});

  final String? moduleId;
  String? modVal;
  final String? modName;

  bool get isEnabled => modVal == '1';

  factory GroupSettingItem.fromJson(Map<String, dynamic> json) {
    return GroupSettingItem(
      moduleId: json['moduleId']?.toString(),
      modVal: json['modVal']?.toString(),
      modName: json['modName']?.toString(),
    );
  }
}
