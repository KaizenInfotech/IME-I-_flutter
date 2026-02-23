import 'dart:convert';

/// Merged iOS NotificaionModel + NotificationModel into one clean model.
/// Matches exact Notification_Table schema:
/// MsgID, Title, Details, Type, ClubDistrictType, NotifyDate, ExpiryDate, SortDate, ReadStatus
class NotificationItem {
  NotificationItem({
    this.msgId,
    this.title,
    this.details,
    this.type,
    this.clubDistrictType,
    this.notifyDate,
    this.expiryDate,
    this.sortDate,
    this.readStatus,
  });

  final String? msgId;
  final String? title;
  final String? details;
  final String? type;
  final String? clubDistrictType;
  final String? notifyDate;
  final String? expiryDate;
  final String? sortDate;
  final String? readStatus;

  bool get isUnread => readStatus == 'UnRead';

  /// Parse the JSON details string to extract notification payload fields.
  Map<String, dynamic>? get detailsJson {
    if (details == null || details!.isEmpty) return null;
    try {
      final cleaned = details!.replaceAll(r'\', '');
      return json.decode(cleaned) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Extract display message from details JSON.
  String get displayMessage {
    final json = detailsJson;
    if (json == null) return title ?? '';

    if (type == 'PopupNoti') {
      return (json['title'] as String?) ?? title ?? '';
    }

    final message = (json['Message'] as String?) ?? '';
    return message
        .replaceAll('<br />', '')
        .replaceAll('<br>', '')
        .replaceAll('<p>', '')
        .replaceAll('</p>', '');
  }

  /// Extract entity name from details JSON.
  String get entityName {
    final json = detailsJson;
    return (json?['entityName'] as String?) ?? '';
  }

  /// Build from SQLite row map.
  factory NotificationItem.fromMap(Map<String, dynamic> map) {
    return NotificationItem(
      msgId: map['MsgID']?.toString(),
      title: map['Title']?.toString(),
      details: map['Details']?.toString(),
      type: map['Type']?.toString(),
      clubDistrictType: map['ClubDistrictType']?.toString(),
      notifyDate: map['NotifyDate']?.toString(),
      expiryDate: map['ExpiryDate']?.toString(),
      sortDate: map['SortDate']?.toString(),
      readStatus: map['ReadStatus']?.toString(),
    );
  }

  /// Convert to map for SQLite insertion.
  Map<String, dynamic> toMap() {
    return {
      'MsgID': msgId ?? '',
      'Title': title ?? '',
      'Details': details ?? '',
      'Type': type ?? '',
      'ClubDistrictType': clubDistrictType ?? '',
      'NotifyDate': notifyDate ?? '',
      'ExpiryDate': expiryDate ?? '',
      'SortDate': sortDate ?? DateTime.now().toIso8601String(),
      'ReadStatus': readStatus ?? 'UnRead',
    };
  }
}

/// Response model for notification settings (Setting/GetGroupSetting).
class TBGroupSettingResult {
  TBGroupSettingResult({
    this.status,
    this.isMobileSelf,
    this.isMobileOther,
    this.isEmailSelf,
    this.isEmailOther,
    this.settings,
  });

  final String? status;
  final String? isMobileSelf;
  final String? isMobileOther;
  final String? isEmailSelf;
  final String? isEmailOther;
  final List<NotificationSettingItem>? settings;

  factory TBGroupSettingResult.fromJson(Map<String, dynamic> json) {
    final result =
        json['TBGroupSettingResult'] as Map<String, dynamic>? ?? json;
    final settingsList =
        result['GRpSettingResult'] as List<dynamic>? ?? [];

    final items = settingsList.map((e) {
      final map = e as Map<String, dynamic>;
      final details =
          map['GRpSettingDetails'] as Map<String, dynamic>? ?? {};
      return NotificationSettingItem(
        moduleId: details['moduleId']?.toString(),
        modName: details['modName']?.toString(),
        modVal: details['modVal']?.toString(),
      );
    }).toList();

    return TBGroupSettingResult(
      status: result['status']?.toString(),
      isMobileSelf: result['isMobileSelf']?.toString(),
      isMobileOther: result['isMobileOther']?.toString(),
      isEmailSelf: result['isEmailSelf']?.toString(),
      isEmailOther: result['isEmailOther']?.toString(),
      settings: items,
    );
  }
}

class NotificationSettingItem {
  NotificationSettingItem({
    this.moduleId,
    this.modName,
    this.modVal,
  });

  final String? moduleId;
  final String? modName;
  String? modVal;

  bool get isEnabled => modVal == '1';
}
