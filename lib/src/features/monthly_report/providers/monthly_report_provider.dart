import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Port of iOS MontlyPDFListViewControllerViewController logic.
/// Scans the app documents directory for downloaded PDF/document files.
class MonthlyReportProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<FileSystemEntity> _reports = [];
  List<FileSystemEntity> get reports => _reports;

  /// iOS: functionForGetAllDownloadedDocumentFromDirectory()
  /// Reads local Documents directory, filters out system/db files.
  Future<void> fetchDownloadedDocuments() async {
    _isLoading = true;
    notifyListeners();

    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = directory.listSync();

      // iOS exclusions: .DS_Store, .sqlite, .db, .sqlite-wal,
      // .sqlite-shm, NewMembers, .zip
      final excluded = {
        '.DS_Store',
        '.sqlite',
        '.db',
        '.sqlite-wal',
        '.sqlite-shm',
      };

      _reports = files.where((f) {
        if (f is! File) return false;
        final name = f.path.split('/').last;
        if (name.contains('NewMembers')) return false;
        for (final ext in excluded) {
          if (name.endsWith(ext)) return false;
        }
        return true;
      }).toList();

      // Sort by name
      _reports.sort((a, b) {
        final nameA = a.path.split('/').last.toLowerCase();
        final nameB = b.path.split('/').last.toLowerCase();
        return nameA.compareTo(nameB);
      });
    } catch (e) {
      debugPrint('fetchDownloadedDocuments error: $e');
      _reports = [];
    }

    _isLoading = false;
    notifyListeners();
  }
}
