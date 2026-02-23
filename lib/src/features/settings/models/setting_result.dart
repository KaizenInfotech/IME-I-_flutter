/// Response from setting/GetTouchbaseSetting.
/// iOS: TBSettingResult + SettingResult (Obj-C models).
class TBSettingResult {
  TBSettingResult({this.status, this.message, this.settings});

  final String? status;
  final String? message;
  final List<SettingItem>? settings;

  factory TBSettingResult.fromJson(Map<String, dynamic> json) {
    final result =
        json['TBSettingResult'] as Map<String, dynamic>? ?? json;
    final rawList =
        result['AllTBSettingResults'] as List<dynamic>? ?? [];

    final items = rawList.map((e) {
      final map = e as Map<String, dynamic>;
      final details =
          map['TBSettingResults'] as Map<String, dynamic>? ?? map;
      return SettingItem.fromJson(details);
    }).toList();

    return TBSettingResult(
      status: result['status']?.toString(),
      message: result['message']?.toString(),
      settings: items,
    );
  }
}

/// Individual group setting toggle.
/// iOS: SettingResult (grpId, grpVal, grpName).
class SettingItem {
  SettingItem({this.grpId, this.grpVal, this.grpName});

  final String? grpId;
  String? grpVal;
  final String? grpName;

  bool get isEnabled => grpVal == '1';

  factory SettingItem.fromJson(Map<String, dynamic> json) {
    return SettingItem(
      grpId: json['grpId']?.toString(),
      grpVal: json['grpVal']?.toString(),
      grpName: json['grpName']?.toString(),
    );
  }
}
