import '../../../core/models/base_model.dart';

/// Port of iOS dashboard data — response from Group/GetNewDashboard.
/// Contains banner/slider data and dashboard configuration.
class TBDashboardResult extends BaseModel {
  final String? status;
  final String? message;
  final List<DashboardBanner>? bannerList;
  final List<DashboardBanner>? sliderList;

  TBDashboardResult({
    this.status,
    this.message,
    this.bannerList,
    this.sliderList,
  });

  factory TBDashboardResult.fromJson(Map<String, dynamic> json) {
    return TBDashboardResult(
      status: BaseModel.safeString(json['status']),
      message: BaseModel.safeString(json['message']),
      bannerList: BaseModel.safeList(
        json['BannerList'] ?? json['bannerList'],
        DashboardBanner.fromJson,
      ),
      sliderList: BaseModel.safeList(
        json['SliderList'] ?? json['sliderList'],
        DashboardBanner.fromJson,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'BannerList': bannerList?.map((e) => e.toJson()).toList(),
        'SliderList': sliderList?.map((e) => e.toJson()).toList(),
      };

  bool get isSuccess => status == '0';
}

/// Individual banner/slider item.
class DashboardBanner extends BaseModel {
  final String? bannerId;
  final String? bannerImage;
  final String? bannerTitle;
  final String? bannerDescription;
  final String? bannerUrl;
  final String? bannerType;

  DashboardBanner({
    this.bannerId,
    this.bannerImage,
    this.bannerTitle,
    this.bannerDescription,
    this.bannerUrl,
    this.bannerType,
  });

  factory DashboardBanner.fromJson(Map<String, dynamic> json) {
    return DashboardBanner(
      bannerId: BaseModel.safeString(json['bannerId'] ?? json['BannerId']),
      bannerImage:
          BaseModel.safeString(json['bannerImage'] ?? json['BannerImage']),
      bannerTitle:
          BaseModel.safeString(json['bannerTitle'] ?? json['BannerTitle']),
      bannerDescription: BaseModel.safeString(
          json['bannerDescription'] ?? json['BannerDescription']),
      bannerUrl: BaseModel.safeString(json['bannerUrl'] ?? json['BannerUrl']),
      bannerType:
          BaseModel.safeString(json['bannerType'] ?? json['BannerType']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'bannerId': bannerId,
        'bannerImage': bannerImage,
        'bannerTitle': bannerTitle,
        'bannerDescription': bannerDescription,
        'bannerUrl': bannerUrl,
        'bannerType': bannerType,
      };
}

/// Notification count response.
class NotificationCountResult extends BaseModel {
  final String? status;
  final String? message;
  final String? notificationCount;

  NotificationCountResult({
    this.status,
    this.message,
    this.notificationCount,
  });

  factory NotificationCountResult.fromJson(Map<String, dynamic> json) {
    return NotificationCountResult(
      status: BaseModel.safeString(json['status']),
      message: BaseModel.safeString(json['message']),
      notificationCount: BaseModel.safeString(
          json['notificationCount'] ?? json['NotificationCount']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'notificationCount': notificationCount,
      };

  int get count => int.tryParse(notificationCount ?? '') ?? 0;
}
