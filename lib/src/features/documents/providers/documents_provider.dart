import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/add_document_result.dart';
import '../models/document_list_result.dart';

/// Port of iOS DocumentListViewControlller + DocumentsDetailController logic.
/// Matches: getDocumentList, addDocument, updateDocumentIsRead, download.
class DocumentsProvider extends ChangeNotifier {
  // ─── STATE ──────────────────────────────────────────────
  List<DocumentItem> _documents = [];
  List<DocumentItem> get documents => _documents;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isDownloading = false;
  bool get isDownloading => _isDownloading;

  double _downloadProgress = 0.0;
  double get downloadProgress => _downloadProgress;

  String? _error;
  String? get error => _error;

  // ─── iOS: getDocumentList → POST DocumentSafe/GetDocumentList ──
  /// type: "0"=All, "1"=Published, "2"=Scheduled, "3"=Expired
  Future<bool> fetchDocuments({
    required String groupId,
    required String memberProfileId,
    String type = '1',
    String isAdmin = '0',
    String searchText = '',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConstants.documentGetList,
        body: {
          'grpID': groupId,
          'memberProfileID': memberProfileId,
          'type': type,
          'isAdmin': isAdmin,
          'searchText': searchText,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final result = TBDocumentListResult.fromJson(
            jsonData['TBDocumentistResult'] as Map<String, dynamic>? ??
                jsonData);

        if (result.isSuccess) {
          _documents = result.documents ?? [];
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _error = result.message ?? 'Failed to load documents';
        }
      } else {
        _error = 'Server error';
      }
    } catch (e) {
      _error = 'Error loading documents: $e';
      debugPrint('fetchDocuments error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ─── iOS: addDocument → POST DocumentSafe/AddDocument ──
  Future<TBAddDocumentResult?> addDocument({
    required String groupId,
    required String profileId,
    required String docTitle,
    required String docType,
    required List<int> fileBytes,
    String filename = 'document',
  }) async {
    try {
      final uri = Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.documentAdd}');

      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ=='
        ..fields['grpID'] = groupId
        ..fields['profileID'] = profileId
        ..fields['docTitle'] = docTitle
        ..files.add(http.MultipartFile.fromBytes(
          'userfile',
          fileBytes,
          filename: '$filename.$docType',
        ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return TBAddDocumentResult.fromJson(
            jsonData['TBAddDocumentResult'] as Map<String, dynamic>? ??
                jsonData);
      }
    } catch (e) {
      debugPrint('addDocument error: $e');
    }
    return null;
  }

  // ─── iOS: updateDocumentIsRead → POST DocumentSafe/UpdateDocumentIsRead ──
  Future<bool> updateDocumentIsRead({
    required String docId,
    required String memberProfileId,
  }) async {
    try {
      final response = await ApiClient.instance.post(
        ApiConstants.documentUpdateIsRead,
        body: {
          'DocID': docId,
          'memberProfileID': memberProfileId,
        },
      );

      if (response.statusCode == 200) {
        // Update local state
        final index = _documents.indexWhere((d) => d.docID == docId);
        if (index >= 0) {
          _documents[index] = DocumentItem(
            docID: _documents[index].docID,
            docTitle: _documents[index].docTitle,
            docType: _documents[index].docType,
            docURL: _documents[index].docURL,
            createDateTime: _documents[index].createDateTime,
            docAccessType: _documents[index].docAccessType,
            isRead: '1',
          );
          notifyListeners();
        }
        return true;
      }
    } catch (e) {
      debugPrint('updateDocumentIsRead error: $e');
    }
    return false;
  }

  // ─── iOS: SDDownloadManager pattern → streamed download with progress ──
  Future<String?> downloadDocument({
    required String url,
    required String docId,
    required String docType,
  }) async {
    _isDownloading = true;
    _downloadProgress = 0.0;
    notifyListeners();

    try {
      // Check cache first (iOS: NSSearchPathForDirectoriesInDomains(.cachesDirectory))
      final cacheDir = await getTemporaryDirectory();
      final filePath = '${cacheDir.path}/$docId.$docType';
      final file = File(filePath);

      if (await file.exists()) {
        _isDownloading = false;
        _downloadProgress = 1.0;
        notifyListeners();
        return filePath;
      }

      // Download with progress
      final request = http.Request('GET', Uri.parse(url));
      final streamedResponse = await request.send();

      final totalBytes = streamedResponse.contentLength ?? 0;
      int receivedBytes = 0;
      final List<int> bytes = [];

      await for (final chunk in streamedResponse.stream) {
        bytes.addAll(chunk);
        receivedBytes += chunk.length;
        if (totalBytes > 0) {
          _downloadProgress = receivedBytes / totalBytes;
          notifyListeners();
        }
      }

      await file.writeAsBytes(bytes);

      _isDownloading = false;
      _downloadProgress = 1.0;
      notifyListeners();
      return filePath;
    } catch (e) {
      debugPrint('downloadDocument error: $e');
    }

    _isDownloading = false;
    _downloadProgress = 0.0;
    notifyListeners();
    return null;
  }

  // ─── iOS: deleteDataWebservice → POST Group/DeleteByModuleName ──
  Future<bool> deleteDocument({
    required String docId,
    required String profileId,
  }) async {
    try {
      final response = await ApiClient.instance.post(
        ApiConstants.groupDeleteByModuleName,
        body: {
          'typeID': docId,
          'type': 'Document',
          'profileID': profileId,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final status = jsonData['status']?.toString();
        if (status == '0') {
          _documents.removeWhere((d) => d.docID == docId);
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      debugPrint('deleteDocument error: $e');
    }
    return false;
  }

  void clearAll() {
    _documents = [];
    _isLoading = false;
    _isDownloading = false;
    _downloadProgress = 0.0;
    _error = null;
    notifyListeners();
  }
}
