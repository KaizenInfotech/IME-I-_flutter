/// Models for Gallery/GetYear and Gallery/GetMER_List API responses.
/// Matches iOS Year / YearTable / MERData / MERList structs.
/// Shared by MER(I) (Type/TransType "1") and iMelange (Type/TransType "2").
class YearResult {
  YearResult({this.years = const []});

  final List<YearItem> years;

  factory YearResult.fromJson(Map<String, dynamic> json) {
    // Response: { str: { Table: [ { FinanceYear: "2024-2025" }, ... ] } }
    final str = json['str'] as Map<String, dynamic>?;
    final table = str?['Table'] as List<dynamic>? ?? [];
    return YearResult(
      years: table
          .map((e) => YearItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class YearItem {
  YearItem({this.financeYear});

  final String? financeYear;

  factory YearItem.fromJson(Map<String, dynamic> json) {
    return YearItem(
      financeYear: json['FinanceYear']?.toString(),
    );
  }
}

class MerResult {
  MerResult({this.items = const []});

  final List<MerItem> items;

  factory MerResult.fromJson(Map<String, dynamic> json) {
    // Response: { Result: { Table: [...] } }
    final result = json['Result'] as Map<String, dynamic>?;
    final table = result?['Table'] as List<dynamic>? ?? [];
    return MerResult(
      items: table
          .map((e) => MerItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// iOS: MERList struct.
class MerItem {
  MerItem({
    this.grpId,
    this.merId,
    this.title,
    this.link,
    this.filePath,
    this.publishDate,
    this.expiryDate,
    this.financeYear,
  });

  final String? grpId;
  final String? merId;
  final String? title;
  final String? link;
  final String? filePath;
  final String? publishDate;
  final String? expiryDate;
  final String? financeYear;

  /// Returns the URL to display — link if available, else filePath.
  String? get displayUrl {
    if (link != null && link!.isNotEmpty) return link;
    if (filePath != null && filePath!.isNotEmpty) return filePath;
    return null;
  }

  factory MerItem.fromJson(Map<String, dynamic> json) {
    return MerItem(
      grpId: json['GrpID']?.toString(),
      merId: json['MER_ID']?.toString(),
      title: json['Title']?.toString(),
      link: json['Link']?.toString(),
      filePath: json['File_Path']?.toString(),
      publishDate: json['publish_date']?.toString(),
      expiryDate: json['expiry_date']?.toString(),
      financeYear: json['FinanceYear']?.toString(),
    );
  }
}
