import '../../../core/models/base_model.dart';

/// Port of iOS MemberListDetailResult.h — response from Member/GetMember.
/// Contains detailed member profile with personal, business, family, and address sections.
class MemberListDetailResult extends BaseModel {
  final String? status;
  final String? message;
  final List<MemberDetail>? memberDetails;

  MemberListDetailResult({
    this.status,
    this.message,
    this.memberDetails,
  });

  factory MemberListDetailResult.fromJson(Map<String, dynamic> json) {
    return MemberListDetailResult(
      status: BaseModel.safeString(json['status']),
      message: BaseModel.safeString(json['message']),
      memberDetails: BaseModel.safeList(
        json['MemberDetails'] ?? json['memberDetails'],
        MemberDetail.fromJson,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'MemberDetails': memberDetails?.map((e) => e.toJson()).toList(),
      };

  bool get isSuccess => status == '0';

  /// Get first member detail (convenience).
  MemberDetail? get firstMember =>
      memberDetails != null && memberDetails!.isNotEmpty
          ? memberDetails!.first
          : null;
}

/// Port of iOS MemberListDetail.h (ProfileView) — detailed member profile.
/// Contains personal, business, family details and addresses.
class MemberDetail extends BaseModel {
  final String? masterID;
  final String? grpID;
  final String? profileID;
  final String? isAdmin;
  final String? memberName;
  final String? memberEmail;
  final String? memberMobile;
  final String? memberCountry;
  final String? profilePic;
  final String? isPersonalDetVisible;
  final String? isBusinDetVisible;
  final String? isFamilDetailVisible;
  final List<PersonalMemberDetail>? personalMemberDetails;
  final List<PersonalMemberDetail>? businessMemberDetails;
  final List<FamilyMemberDetail>? familyMemberDetails;
  final List<AddressDetail>? addressDetails;

  MemberDetail({
    this.masterID,
    this.grpID,
    this.profileID,
    this.isAdmin,
    this.memberName,
    this.memberEmail,
    this.memberMobile,
    this.memberCountry,
    this.profilePic,
    this.isPersonalDetVisible,
    this.isBusinDetVisible,
    this.isFamilDetailVisible,
    this.personalMemberDetails,
    this.businessMemberDetails,
    this.familyMemberDetails,
    this.addressDetails,
  });

  factory MemberDetail.fromJson(Map<String, dynamic> json) {
    return MemberDetail(
      masterID: BaseModel.safeString(json['masterID']),
      grpID: BaseModel.safeString(json['grpID']),
      profileID: BaseModel.safeString(json['profileID']),
      isAdmin: BaseModel.safeString(json['isAdmin']),
      memberName: BaseModel.safeString(json['memberName']),
      memberEmail: BaseModel.safeString(json['memberEmail']),
      memberMobile: BaseModel.safeString(json['memberMobile']),
      memberCountry: BaseModel.safeString(json['memberCountry']),
      profilePic: BaseModel.safeString(json['profilePic']),
      isPersonalDetVisible:
          BaseModel.safeString(json['isPersonalDetVisible']),
      isBusinDetVisible: BaseModel.safeString(json['isBusinDetVisible']),
      isFamilDetailVisible:
          BaseModel.safeString(json['isFamilDetailVisible']),
      personalMemberDetails: BaseModel.safeList(
        json['personalMemberDetails'],
        PersonalMemberDetail.fromJson,
      ),
      businessMemberDetails: BaseModel.safeList(
        json['BusinessMemberDetails'] ?? json['businessMemberDetails'],
        PersonalMemberDetail.fromJson,
      ),
      familyMemberDetails: BaseModel.safeList(
        json['familyMemberDetails'],
        FamilyMemberDetail.fromJson,
      ),
      addressDetails: BaseModel.safeList(
        json['addressDetails'],
        AddressDetail.fromJson,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'masterID': masterID,
        'grpID': grpID,
        'profileID': profileID,
        'isAdmin': isAdmin,
        'memberName': memberName,
        'memberEmail': memberEmail,
        'memberMobile': memberMobile,
        'memberCountry': memberCountry,
        'profilePic': profilePic,
        'isPersonalDetVisible': isPersonalDetVisible,
        'isBusinDetVisible': isBusinDetVisible,
        'isFamilDetailVisible': isFamilDetailVisible,
        'personalMemberDetails':
            personalMemberDetails?.map((e) => e.toJson()).toList(),
        'BusinessMemberDetails':
            businessMemberDetails?.map((e) => e.toJson()).toList(),
        'familyMemberDetails':
            familyMemberDetails?.map((e) => e.toJson()).toList(),
        'addressDetails': addressDetails?.map((e) => e.toJson()).toList(),
      };

  bool get hasValidProfilePic =>
      profilePic != null &&
      profilePic!.isNotEmpty &&
      profilePic != 'profile_photo.png';

  bool get showPersonalDetails =>
      isPersonalDetVisible?.toLowerCase() == 'true' ||
      isPersonalDetVisible == '1';

  bool get showBusinessDetails =>
      isBusinDetVisible?.toLowerCase() == 'true' ||
      isBusinDetVisible == '1';

  bool get showFamilyDetails =>
      isFamilDetailVisible?.toLowerCase() == 'true' ||
      isFamilDetailVisible == '1';
}

/// Port of iOS PersonalMemberDetil.h / BusinessMemberDetail.h — key-value profile field.
/// Used for both personal and business details sections.
class PersonalMemberDetail extends BaseModel {
  final String? key;
  final String? value;
  final String? uniquekey;
  final String? colType;

  PersonalMemberDetail({
    this.key,
    this.value,
    this.uniquekey,
    this.colType,
  });

  factory PersonalMemberDetail.fromJson(Map<String, dynamic> json) {
    return PersonalMemberDetail(
      key: BaseModel.safeString(json['key']),
      value: BaseModel.safeString(json['value']),
      uniquekey: BaseModel.safeString(json['uniquekey']),
      colType: BaseModel.safeString(json['colType']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'key': key,
        'value': value,
        'uniquekey': uniquekey,
        'colType': colType,
      };
}

/// Port of iOS FamilyMemberDetil.h — family member detail.
class FamilyMemberDetail extends BaseModel {
  final String? familyMemberId;
  final String? memberName;
  final String? relationship;
  final String? dOB;
  final String? emailID;
  final String? anniversary;
  final String? contactNo;
  final String? particulars;
  final String? bloodGroup;

  FamilyMemberDetail({
    this.familyMemberId,
    this.memberName,
    this.relationship,
    this.dOB,
    this.emailID,
    this.anniversary,
    this.contactNo,
    this.particulars,
    this.bloodGroup,
  });

  factory FamilyMemberDetail.fromJson(Map<String, dynamic> json) {
    return FamilyMemberDetail(
      familyMemberId: BaseModel.safeString(json['familyMemberId']),
      memberName: BaseModel.safeString(json['memberName']),
      relationship: BaseModel.safeString(json['relationship']),
      dOB: BaseModel.safeString(json['dOB']),
      emailID: BaseModel.safeString(json['emailID']),
      anniversary: BaseModel.safeString(json['anniversary']),
      contactNo: BaseModel.safeString(json['contactNo']),
      particulars: BaseModel.safeString(json['particulars']),
      bloodGroup: BaseModel.safeString(json['bloodGroup']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'familyMemberId': familyMemberId,
        'memberName': memberName,
        'relationship': relationship,
        'dOB': dOB,
        'emailID': emailID,
        'anniversary': anniversary,
        'contactNo': contactNo,
        'particulars': particulars,
        'bloodGroup': bloodGroup,
      };
}

/// Port of iOS Address.h — address detail.
class AddressDetail extends BaseModel {
  final String? addressID;
  final String? addressType;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? pincode;
  final String? phoneNo;
  final String? fax;

  AddressDetail({
    this.addressID,
    this.addressType,
    this.address,
    this.city,
    this.state,
    this.country,
    this.pincode,
    this.phoneNo,
    this.fax,
  });

  factory AddressDetail.fromJson(Map<String, dynamic> json) {
    return AddressDetail(
      addressID: BaseModel.safeString(json['addressID']),
      addressType: BaseModel.safeString(json['addressType']),
      address: BaseModel.safeString(json['address']),
      city: BaseModel.safeString(json['city']),
      state: BaseModel.safeString(json['state']),
      country: BaseModel.safeString(json['country']),
      pincode: BaseModel.safeString(json['pincode']),
      phoneNo: BaseModel.safeString(json['phoneNo']),
      fax: BaseModel.safeString(json['fax']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'addressID': addressID,
        'addressType': addressType,
        'address': address,
        'city': city,
        'state': state,
        'country': country,
        'pincode': pincode,
        'phoneNo': phoneNo,
        'fax': fax,
      };

  /// Formatted full address string.
  String get fullAddress {
    final parts = <String>[];
    if (address != null && address!.isNotEmpty) parts.add(address!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (country != null && country!.isNotEmpty) parts.add(country!);
    if (pincode != null && pincode!.isNotEmpty) parts.add(pincode!);
    return parts.join(', ');
  }
}
