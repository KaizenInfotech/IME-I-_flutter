import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/web_link_result.dart';

class WebLinksProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<WebLinkItem> _webLinks = [];
  List<WebLinkItem> get webLinks => _webLinks;

  Future<void> fetchWebLinks({
    required String groupId,
    String searchText = '',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.webLinkGetList,
        body: {
          'GroupId': groupId,
          'searchText': searchText,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = TBGetWebLinkListResult.fromJson(jsonData);

        if (result.status == '0' && result.webLinks != null) {
          _webLinks = result.webLinks!;
        } else {
          _webLinks = [];
        }
      } else {
        _error = 'Something went wrong, Please try again later';
      }
    } catch (e) {
      _error = 'Something went wrong, Please try again later';
      debugPrint('fetchWebLinks error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
