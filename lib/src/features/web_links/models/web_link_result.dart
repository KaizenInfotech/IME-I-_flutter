/// Response from WebLink/GetWebLinksList.
/// iOS parses parallel arrays: WeblinkId[], GroupId[], Title[], fullDesc[], LinkUrl[].
class TBGetWebLinkListResult {
  TBGetWebLinkListResult({this.status, this.webLinks});

  final String? status;
  final List<WebLinkItem>? webLinks;

  factory TBGetWebLinkListResult.fromJson(Map<String, dynamic> json) {
    final result =
        json['TBGetWebLinkListResult'] as Map<String, dynamic>? ?? json;
    final listResult =
        result['WebLinkListResult'] as Map<String, dynamic>? ?? {};

    final ids = listResult['WeblinkId'] as List<dynamic>? ?? [];
    final groupIds = listResult['GroupId'] as List<dynamic>? ?? [];
    final titles = listResult['Title'] as List<dynamic>? ?? [];
    final descs = listResult['fullDesc'] as List<dynamic>? ?? [];
    final urls = listResult['LinkUrl'] as List<dynamic>? ?? [];

    final count = ids.length;
    final items = List.generate(count, (i) {
      return WebLinkItem(
        weblinkId: i < ids.length ? ids[i]?.toString() : null,
        groupId: i < groupIds.length ? groupIds[i]?.toString() : null,
        title: i < titles.length ? titles[i]?.toString() : null,
        fullDesc: i < descs.length ? descs[i]?.toString() : null,
        linkUrl: i < urls.length ? urls[i]?.toString() : null,
      );
    });

    return TBGetWebLinkListResult(
      status: result['status']?.toString(),
      webLinks: items,
    );
  }
}

class WebLinkItem {
  WebLinkItem({
    this.weblinkId,
    this.groupId,
    this.title,
    this.fullDesc,
    this.linkUrl,
  });

  final String? weblinkId;
  final String? groupId;
  final String? title;
  final String? fullDesc;
  final String? linkUrl;

  bool get hasUrl =>
      linkUrl != null && linkUrl!.isNotEmpty;

  bool get hasDescription =>
      fullDesc != null && fullDesc!.isNotEmpty;
}
