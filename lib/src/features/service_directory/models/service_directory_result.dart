import '../../../core/models/base_model.dart';

/// Port of iOS TBGetServiceCategoriesDataList — categories + directory data.
/// API: ServiceDirectory/GetServiceCategoriesData
/// Response key: "TBGetServiceCategoriesDataList" → "Result" → "Category" + "DirectoryData"
class TBServiceCategoriesResult extends BaseModel {
  TBServiceCategoriesResult({
    this.status,
    this.message,
    this.categories,
    this.directoryData,
  });

  final String? status;
  final String? message;
  final List<ServiceCategory>? categories;
  final List<ServiceDirectoryItem>? directoryData;

  factory TBServiceCategoriesResult.fromJson(Map<String, dynamic> json) {
    final result = json['Result'] as Map<String, dynamic>?;

    List<ServiceCategory>? cats;
    List<ServiceDirectoryItem>? data;

    if (result != null) {
      final catList = result['Category'] as List<dynamic>?;
      final dataList = result['DirectoryData'] as List<dynamic>?;

      cats = catList
          ?.map((e) => ServiceCategory.fromJson(e as Map<String, dynamic>))
          .toList();
      data = dataList
          ?.map((e) =>
              ServiceDirectoryItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return TBServiceCategoriesResult(
      status: BaseModel.safeString(json['status']),
      message: BaseModel.safeString(json['message']),
      categories: cats,
      directoryData: data,
    );
  }

  bool get isSuccess => status == '0';

  @override
  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
      };
}

/// Service directory category with count.
/// iOS: Category array from GetServiceCategoriesData.
class ServiceCategory extends BaseModel {
  ServiceCategory({
    this.categoryName,
    this.id,
    this.totalCount,
  });

  final String? categoryName;
  final int? id;
  final int? totalCount;

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      categoryName: BaseModel.safeString(json['CategoryName']),
      id: BaseModel.safeInt(json['ID']),
      totalCount: BaseModel.safeInt(json['TotalCount']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'CategoryName': categoryName,
        'ID': id,
        'TotalCount': totalCount,
      };
}

/// Service directory item / provider.
/// iOS: DirectoryData from GetServiceCategoriesData, or SERVICE_DIRECTORY_DATA_MASTER SQLite.
class ServiceDirectoryItem extends BaseModel {
  ServiceDirectoryItem({
    this.serviceDirId,
    this.memberName,
    this.image,
    this.contactNo,
    this.contactNo2,
    this.description,
    this.paxNo,
    this.email,
    this.keywords,
    this.address,
    this.city,
    this.state,
    this.country,
    this.zip,
    this.latitude,
    this.longitude,
    this.categoryId,
    this.website,
    this.moduleId,
  });

  final String? serviceDirId;
  final String? memberName;
  final String? image;
  final String? contactNo;
  final String? contactNo2;
  final String? description;
  final String? paxNo;
  final String? email;
  final String? keywords;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? zip;
  final String? latitude;
  final String? longitude;
  final String? categoryId;
  final String? website;
  final String? moduleId;

  factory ServiceDirectoryItem.fromJson(Map<String, dynamic> json) {
    return ServiceDirectoryItem(
      serviceDirId: BaseModel.safeString(json['serviceDirId']),
      memberName: BaseModel.safeString(json['memberName']),
      image: BaseModel.safeString(json['image']),
      contactNo: BaseModel.safeString(json['contactNo']),
      contactNo2: BaseModel.safeString(json['contactNo2']),
      description: BaseModel.safeString(json['description']),
      paxNo: BaseModel.safeString(json['pax_no'] ?? json['paxNo']),
      email: BaseModel.safeString(json['email']),
      keywords: BaseModel.safeString(json['keywords']),
      address: BaseModel.safeString(json['address']),
      city: BaseModel.safeString(json['city']),
      state: BaseModel.safeString(json['state']),
      country: BaseModel.safeString(json['country']),
      zip: BaseModel.safeString(json['zip']),
      latitude: BaseModel.safeString(json['latitude']),
      longitude: BaseModel.safeString(json['longitude']),
      categoryId: BaseModel.safeString(json['categoryId']),
      website: BaseModel.safeString(json['website']),
      moduleId: BaseModel.safeString(json['moduleId']),
    );
  }

  bool get hasValidImage =>
      image != null && image!.isNotEmpty && image!.startsWith('http');

  String? get encodedImageUrl => image?.replaceAll(' ', '%20');

  /// Full formatted address
  String get fullAddress {
    final parts = <String>[];
    if (address != null && address!.isNotEmpty) parts.add(address!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (country != null && country!.isNotEmpty) parts.add(country!);
    if (zip != null && zip!.isNotEmpty) parts.add(zip!);
    return parts.join(', ');
  }

  bool get hasCoordinates {
    final lat = double.tryParse(latitude ?? '');
    final lng = double.tryParse(longitude ?? '');
    return lat != null && lng != null && lat != 0 && lng != 0;
  }

  bool get hasWebsite =>
      website != null && website!.trim().isNotEmpty;

  @override
  Map<String, dynamic> toJson() => {
        'serviceDirId': serviceDirId,
        'memberName': memberName,
        'image': image,
        'contactNo': contactNo,
        'contactNo2': contactNo2,
        'description': description,
        'pax_no': paxNo,
        'email': email,
        'keywords': keywords,
        'address': address,
        'city': city,
        'state': state,
        'country': country,
        'zip': zip,
        'latitude': latitude,
        'longitude': longitude,
        'categoryId': categoryId,
        'website': website,
        'moduleId': moduleId,
      };
}
