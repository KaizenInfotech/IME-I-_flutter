import '../../../core/models/base_model.dart';
import 'celebration_result.dart';

/// Port of iOS TBMemberListResult for birthday/anniversary — today's birthday list.
/// API: Celebrations/GetTodaysBirthday
/// Response key: "TBMemberListResult"
/// iOS uses parallel arrays: memberName[], msg[], memberMobile[], profileId[], relation[]
class TodaysBirthdayResult extends BaseModel {
  TodaysBirthdayResult({
    this.status,
    this.message,
    this.birthdays,
  });

  final String? status;
  final String? message;
  final List<BirthdayItem>? birthdays;

  factory TodaysBirthdayResult.fromJson(Map<String, dynamic> json) {
    final status = BaseModel.safeString(json['status']);
    final message = BaseModel.safeString(json['message']);

    List<BirthdayItem>? items;
    final rawResult = json['Result'];

    if (rawResult is List) {
      // API returns Result as List of objects:
      // [{"profileId":"...", "memberName":"...", "msg":"Anniversary", ...}]
      items = rawResult
          .map((e) => BirthdayItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (rawResult is Map<String, dynamic>) {
      // iOS parallel arrays format under Result
      final memberNames = rawResult['memberName'] as List<dynamic>?;
      final msgs = rawResult['msg'] as List<dynamic>?;
      final mobiles = rawResult['memberMobile'] as List<dynamic>?;
      final emails = rawResult['memberEmail'] as List<dynamic>?;
      final profileIds = rawResult['profileId'] as List<dynamic>?;
      final relations = rawResult['relation'] as List<dynamic>?;
      final groupIds = rawResult['groupID'] as List<dynamic>?;

      if (memberNames != null) {
        items = [];
        for (int i = 0; i < memberNames.length; i++) {
          items.add(BirthdayItem(
            memberName: memberNames[i]?.toString(),
            msg: msgs != null && i < msgs.length
                ? msgs[i]?.toString()
                : null,
            memberMobile: mobiles != null && i < mobiles.length
                ? mobiles[i]?.toString()
                : null,
            memberEmail: emails != null && i < emails.length
                ? emails[i]?.toString()
                : null,
            profileId: profileIds != null && i < profileIds.length
                ? profileIds[i]?.toString()
                : null,
            relation: relations != null && i < relations.length
                ? relations[i]?.toString()
                : null,
            groupID: groupIds != null && i < groupIds.length
                ? groupIds[i]?.toString()
                : null,
            // Parallel arrays format doesn't include MobileNo/EmailIds arrays,
            // so hasPhone/hasEmail will fall through to memberMobile/memberEmail.
          ));
        }
      }
    }

    return TodaysBirthdayResult(
      status: status,
      message: message,
      birthdays: items,
    );
  }

  bool get isSuccess => status == '0';

  /// iOS: filter by msg == "BirthDay"
  List<BirthdayItem> get birthdayOnly =>
      birthdays?.where((b) => b.isBirthday).toList() ?? [];

  /// iOS: filter by msg == "Anniversary"
  List<BirthdayItem> get anniversaryOnly =>
      birthdays?.where((b) => b.isAnniversary).toList() ?? [];

  @override
  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
      };
}

/// Single birthday/anniversary item parsed from API response.
/// Android BirthdayFragment parses: MobileNo (JSONArray), EmailIds (JSONArray),
/// ContactNumber, and uses array contents to control button visibility.
class BirthdayItem extends BaseModel {
  BirthdayItem({
    this.memberName,
    this.msg,
    this.memberMobile,
    this.memberEmail,
    this.profileId,
    this.relation,
    this.groupID,
    this.contactNumber,
    this.mobileNos,
    this.emailIds,
    this.hideWhatsnum,
    this.hideNum,
    this.hideMail,
  });

  final String? memberName;
  final String? msg;
  final String? memberMobile;
  final String? memberEmail;
  final String? profileId;
  final String? relation;
  final String? groupID;
  final String? contactNumber;
  /// Android: MobileNo JSONArray — determines call/sms/WhatsApp button visibility.
  final List<CelebrationMobileItem>? mobileNos;
  /// Android: EmailIds JSONArray — determines email button visibility.
  final List<CelebrationEmailItem>? emailIds;
  /// hide_whatsnum: "1" = visible, "0" = hidden
  final String? hideWhatsnum;
  /// hide_num: "1" = visible, "0" = hidden
  final String? hideNum;
  /// hide_mail: "1" = visible, "0" = hidden
  final String? hideMail;

  factory BirthdayItem.fromJson(Map<String, dynamic> json) {
    final mobile = BaseModel.safeString(json['memberMobile']);
    final email = BaseModel.safeString(json['memberEmail'] ?? json['EmailId']);
    final contact = BaseModel.safeString(json['ContactNumber']);
    final mobileNos = BaseModel.safeList(
        json['MobileNo'], CelebrationMobileItem.fromJson);
    final emailIds = BaseModel.safeList(
        json['EmailIds'], CelebrationEmailItem.fromJson);

    // Try multiple key variations for hide flags
    String? hideWhatsnum = BaseModel.safeString(json['hide_whatsnum'] ??
        json['hideWhatsnum'] ??
        json['HideWhatsnum'] ??
        json['Hide_whatsnum']);
    String? hideNum = BaseModel.safeString(json['hide_num'] ??
        json['hideNum'] ??
        json['HideNum'] ??
        json['Hide_num']);
    String? hideMail = BaseModel.safeString(json['hide_mail'] ??
        json['hideMail'] ??
        json['HideMail'] ??
        json['Hide_mail']);

    // Birthday API doesn't return hide flags — derive from available contact data.
    // If phone/email data exists, the server has chosen to expose it → treat as visible ("1").
    // If no data, treat as hidden ("0").
    final hasAnyPhone = (mobileNos != null && mobileNos.isNotEmpty) ||
        (contact != null && contact.isNotEmpty) ||
        (mobile != null && mobile.isNotEmpty);
    final hasAnyEmail = (emailIds != null && emailIds.isNotEmpty) ||
        (email != null && email.isNotEmpty);

    hideWhatsnum ??= hasAnyPhone ? '1' : '0';
    hideNum ??= hasAnyPhone ? '1' : '0';
    hideMail ??= hasAnyEmail ? '1' : '0';

    return BirthdayItem(
      memberName: BaseModel.safeString(json['memberName']),
      msg: BaseModel.safeString(json['msg']),
      memberMobile: mobile,
      memberEmail: email,
      profileId: BaseModel.safeString(json['profileId']),
      relation: BaseModel.safeString(json['relation']),
      groupID: BaseModel.safeString(json['groupID']),
      contactNumber: contact,
      mobileNos: mobileNos,
      emailIds: emailIds,
      hideWhatsnum: hideWhatsnum,
      hideNum: hideNum,
      hideMail: hideMail,
    );
  }

  /// iOS: msg == "BirthDay"
  bool get isBirthday => msg == 'BirthDay';

  /// iOS: msg == "Anniversary"
  bool get isAnniversary => msg == 'Anniversary';

  /// Phone buttons enabled.
  /// Checks hide flags first, then MobileNo array, then ContactNumber,
  /// then memberMobile fallback.
  bool get hasPhone {
    if (hideWhatsnum != null || hideNum != null) {
      return hideWhatsnum == '1' || hideNum == '1';
    }
    if (mobileNos != null && mobileNos!.isNotEmpty) return true;
    if (contactNumber != null && contactNumber!.isNotEmpty) return true;
    return memberMobile != null && memberMobile!.isNotEmpty;
  }

  /// Email button enabled.
  /// Checks hide flag first, then EmailIds array, then memberEmail fallback.
  bool get hasEmail {
    if (hideMail != null) return hideMail == '1';
    if (emailIds != null && emailIds!.isNotEmpty) return true;
    return memberEmail != null && memberEmail!.isNotEmpty;
  }

  /// First phone from MobileNo array, ContactNumber, or memberMobile fallback.
  String? get firstPhone {
    if (mobileNos != null && mobileNos!.isNotEmpty) {
      return mobileNos!.first.mobileNo;
    }
    if (contactNumber != null && contactNumber!.isNotEmpty) {
      return contactNumber;
    }
    return memberMobile;
  }

  /// First email from EmailIds array, or memberEmail fallback.
  String? get firstEmail {
    if (emailIds != null && emailIds!.isNotEmpty) {
      return emailIds!.first.emailId;
    }
    return memberEmail;
  }

  /// Create a copy with hide flags applied (for current user's events).
  BirthdayItem withHideFlags({
    required String hideWhatsnum,
    required String hideNum,
    required String hideMail,
  }) {
    return BirthdayItem(
      memberName: memberName,
      msg: msg,
      memberMobile: memberMobile,
      memberEmail: memberEmail,
      profileId: profileId,
      relation: relation,
      groupID: groupID,
      contactNumber: contactNumber,
      mobileNos: mobileNos,
      emailIds: emailIds,
      hideWhatsnum: hideWhatsnum,
      hideNum: hideNum,
      hideMail: hideMail,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'memberName': memberName,
        'msg': msg,
        'memberMobile': memberMobile,
        'memberEmail': memberEmail,
        'profileId': profileId,
        'relation': relation,
        'groupID': groupID,
        'ContactNumber': contactNumber,
        'MobileNo': mobileNos?.map((e) => e.toJson()).toList(),
        'EmailIds': emailIds?.map((e) => e.toJson()).toList(),
        'hide_whatsnum': hideWhatsnum,
        'hide_num': hideNum,
        'hide_mail': hideMail,
      };
}
