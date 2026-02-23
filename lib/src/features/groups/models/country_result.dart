/// Response from Group/GetAllCountriesAndCategories.
/// iOS: TBCountryResult — CountryLists + CategoryLists.
class TBCountryResult {
  TBCountryResult({this.status, this.message, this.countries, this.categories});

  final String? status;
  final String? message;
  final List<CountryItem>? countries;
  final List<CategoryItem>? categories;

  factory TBCountryResult.fromJson(Map<String, dynamic> json) {
    final rawCountries = json['CountryLists'] as List<dynamic>? ?? [];
    final rawCategories = json['CategoryLists'] as List<dynamic>? ?? [];

    final countryItems = rawCountries.map((e) {
      final map = e as Map<String, dynamic>;
      return CountryItem.fromJson(map);
    }).toList();

    final categoryItems = rawCategories.map((e) {
      final map = e as Map<String, dynamic>;
      return CategoryItem.fromJson(map);
    }).toList();

    return TBCountryResult(
      status: json['status']?.toString(),
      message: json['message']?.toString(),
      countries: countryItems,
      categories: categoryItems,
    );
  }
}

/// Country entry for group creation.
/// iOS: GrpCountryList (countryId, countryCode, countryName).
class CountryItem {
  CountryItem({this.countryId, this.countryCode, this.countryName});

  final String? countryId;
  final String? countryCode;
  final String? countryName;

  factory CountryItem.fromJson(Map<String, dynamic> json) {
    return CountryItem(
      countryId: json['countryId']?.toString(),
      countryCode: json['countryCode']?.toString(),
      countryName: json['countryName']?.toString(),
    );
  }
}

/// Category entry for group creation/categorization.
/// iOS: GrpCatList (catId, catName).
class CategoryItem {
  CategoryItem({this.catId, this.catName});

  final String? catId;
  final String? catName;

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      catId: json['catId']?.toString(),
      catName: json['catName']?.toString(),
    );
  }
}
