import '../../../core/models/base_model.dart';
import 'service_directory_result.dart';

/// Port of iOS TBServiceDirectoryListResult — service detail response.
/// API: ServiceDirectory/GetServiceDirectoryDetails
/// Response key: "TBServiceDirectoryListResult" → "ServiceDirListResult"
class TBServiceDirectoryListResult extends BaseModel {
  TBServiceDirectoryListResult({
    this.status,
    this.message,
    this.detail,
  });

  final String? status;
  final String? message;
  final ServiceDirectoryItem? detail;

  factory TBServiceDirectoryListResult.fromJson(Map<String, dynamic> json) {
    final resultList = json['ServiceDirListResult'] as List<dynamic>?;
    ServiceDirectoryItem? detail;

    if (resultList != null && resultList.isNotEmpty) {
      detail = ServiceDirectoryItem.fromJson(
          resultList[0] as Map<String, dynamic>);
    }

    return TBServiceDirectoryListResult(
      status: BaseModel.safeString(json['status']),
      message: BaseModel.safeString(json['message']),
      detail: detail,
    );
  }

  bool get isSuccess => status == '0';

  @override
  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
      };
}

/// Port of iOS TBServiceDirectoryResult — service directory sync response.
/// API: OfflineData/GetServiceDirectoryListSync
/// Response key: "TBServiceDirectoryResult" → "ServiceDirectoryResult"
class TBServiceDirectoryResult extends BaseModel {
  TBServiceDirectoryResult({
    this.status,
    this.message,
    this.date,
    this.services,
  });

  final String? status;
  final String? message;
  final String? date;
  final List<ServiceDirectoryItem>? services;

  factory TBServiceDirectoryResult.fromJson(Map<String, dynamic> json) {
    final resultList = json['ServiceDirectoryResult'] as List<dynamic>?;

    return TBServiceDirectoryResult(
      status: BaseModel.safeString(json['status']),
      message: BaseModel.safeString(json['message']),
      date: BaseModel.safeString(json['Date']),
      services: resultList
          ?.map((e) =>
              ServiceDirectoryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  bool get isSuccess => status == '0';

  @override
  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'Date': date,
      };
}
