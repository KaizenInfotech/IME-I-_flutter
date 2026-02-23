/// Model for FindClub/GetCommitteelist API response.
/// Matches iOS SubCommittees / SubTable / SubTable1 structs.
class SubCommitteeResult {
  SubCommitteeResult({this.committees = const [], this.members = const []});

  final List<SubCommittee> committees;
  final List<SubCommitteeMember> members;

  factory SubCommitteeResult.fromJson(Map<String, dynamic> json) {
    // Response: { TBGetClubResult: { ClubResult: { Table: [...], Table1: [...] } } }
    final clubResult = json['TBGetClubResult'] as Map<String, dynamic>?;
    final inner = clubResult?['ClubResult'] as Map<String, dynamic>?;
    final table = inner?['Table'] as List<dynamic>? ?? [];
    final table1 = inner?['Table1'] as List<dynamic>? ?? [];

    return SubCommitteeResult(
      committees: table
          .map((e) => SubCommittee.fromJson(e as Map<String, dynamic>))
          .toList(),
      members: table1
          .map((e) => SubCommitteeMember.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// iOS: SubTable — committee list item.
class SubCommittee {
  SubCommittee({this.pkSubcommitteeId, this.committeName});

  final int? pkSubcommitteeId;
  final String? committeName;

  factory SubCommittee.fromJson(Map<String, dynamic> json) {
    return SubCommittee(
      pkSubcommitteeId: json['Pk_subcomittee_id'] as int?,
      committeName: json['committeName']?.toString(),
    );
  }
}

/// iOS: SubTable1 — committee member item.
class SubCommitteeMember {
  SubCommitteeMember({
    this.pkSubcommitteeId,
    this.committeName,
    this.membername,
    this.mobilenumber,
    this.emailId,
    this.designation,
    this.branch,
    this.othermobilenumber,
    this.otheremailid,
  });

  final int? pkSubcommitteeId;
  final String? committeName;
  final String? membername;
  final String? mobilenumber;
  final String? emailId;
  final String? designation;
  final String? branch;
  final String? othermobilenumber;
  final String? otheremailid;

  factory SubCommitteeMember.fromJson(Map<String, dynamic> json) {
    return SubCommitteeMember(
      pkSubcommitteeId: json['Pk_subcomittee_id'] as int?,
      committeName: json['committeName']?.toString(),
      membername: json['membername']?.toString(),
      mobilenumber: json['mobilenumber']?.toString(),
      emailId: json['EmailId']?.toString(),
      designation: json['designation']?.toString(),
      branch: json['branch']?.toString(),
      othermobilenumber: json['othermobilenumber']?.toString(),
      otheremailid: json['otheremailid']?.toString(),
    );
  }
}
