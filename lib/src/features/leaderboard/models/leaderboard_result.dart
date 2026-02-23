/// Zone list response from Group/getZonelist.
class TBZoneListResult {
  TBZoneListResult({
    this.status,
    this.message,
    this.list,
  });

  final String? status;
  final String? message;
  final List<ZoneItem>? list;

  factory TBZoneListResult.fromJson(Map<String, dynamic> json) {
    final result = json['zonelistResult'] as Map<String, dynamic>? ?? json;
    final rawList = result['list'] as List<dynamic>? ?? [];
    return TBZoneListResult(
      status: result['status']?.toString(),
      message: result['message']?.toString(),
      list: rawList.map((e) => ZoneItem.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class ZoneItem {
  ZoneItem({this.pkZoneId, this.zoneName});

  final String? pkZoneId;
  final String? zoneName;

  factory ZoneItem.fromJson(Map<String, dynamic> json) {
    return ZoneItem(
      pkZoneId: json['PK_zoneID']?.toString(),
      zoneName: json['zoneName']?.toString(),
    );
  }
}

/// Leaderboard response from LeaderBoard/GetLeaderBoardDetails.
class TBLeaderBoardResult {
  TBLeaderBoardResult({
    this.status,
    this.membersCount,
    this.trfCount,
    this.totalProjects,
    this.projectCost,
    this.manHoursCount,
    this.beneficiaryCount,
    this.rotariansCount,
    this.rotaractorsCount,
    this.leaderBoardResult,
  });

  final String? status;
  final String? membersCount;
  final String? trfCount;
  final String? totalProjects;
  final String? projectCost;
  final String? manHoursCount;
  final String? beneficiaryCount;
  final String? rotariansCount;
  final String? rotaractorsCount;
  final List<LeaderBoardEntry>? leaderBoardResult;

  factory TBLeaderBoardResult.fromJson(Map<String, dynamic> json) {
    final result =
        json['TBLeaderBoardResult'] as Map<String, dynamic>? ?? json;

    final rawList = result['LeaderBoardResult'] as List<dynamic>? ?? [];
    final entries = rawList.map((e) {
      final map = e as Map<String, dynamic>;
      final inner =
          map['LeaderBoardResult'] as Map<String, dynamic>? ?? map;
      return LeaderBoardEntry.fromJson(inner);
    }).toList();

    return TBLeaderBoardResult(
      status: result['status']?.toString(),
      membersCount: result['MembersCount']?.toString(),
      trfCount: result['TRFCount']?.toString(),
      totalProjects: result['TotalProjects']?.toString(),
      projectCost: result['ProjectCost']?.toString(),
      manHoursCount: result['ManHoursCount']?.toString(),
      beneficiaryCount: result['BeneficiaryCount']?.toString(),
      rotariansCount: result['RotariansCount']?.toString(),
      rotaractorsCount: result['RotaractoresCount']?.toString(),
      leaderBoardResult: entries,
    );
  }

  /// Build the stats grid items matching iOS order:
  /// Members, TRF Contribution, Projects, Cost, Man Hours,
  /// Beneficiaries, Rotarians Involved, Rotaractors Involved.
  List<LeaderBoardStat> get statsItems {
    return [
      LeaderBoardStat(
        label: 'Members',
        value: _nonEmpty(membersCount, '0'),
      ),
      LeaderBoardStat(
        label: 'TRF\nContribution',
        value: '\$${_nonEmpty(trfCount, '0')}',
      ),
      LeaderBoardStat(
        label: 'Projects',
        value: _nonEmpty(totalProjects, '0'),
      ),
      LeaderBoardStat(
        label: 'Cost',
        value: _nonEmpty(projectCost, '0'),
      ),
      LeaderBoardStat(
        label: 'Man Hours',
        value: _nonEmpty(manHoursCount, '0'),
      ),
      LeaderBoardStat(
        label: 'Beneficiaries',
        value: _nonEmpty(beneficiaryCount, '0'),
      ),
      LeaderBoardStat(
        label: 'Rotarians\nInvolved',
        value: _nonEmpty(rotariansCount, '0'),
      ),
      LeaderBoardStat(
        label: 'Rotaractors\nInvolved',
        value: _nonEmpty(rotaractorsCount, '0'),
      ),
    ];
  }

  static String _nonEmpty(String? val, String fallback) {
    if (val == null || val.isEmpty) return fallback;
    return val;
  }
}

class LeaderBoardStat {
  LeaderBoardStat({required this.label, required this.value});
  final String label;
  final String value;
}

class LeaderBoardEntry {
  LeaderBoardEntry({this.clubName, this.points});

  final String? clubName;
  final String? points;

  factory LeaderBoardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderBoardEntry(
      clubName: json['clubName']?.toString(),
      points: json['Points']?.toString(),
    );
  }
}
