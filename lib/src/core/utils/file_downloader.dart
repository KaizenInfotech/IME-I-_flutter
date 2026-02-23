import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Port of iOS HttpDownloader.swift (Downloader class).
/// Downloads files with progress tracking using http streamed request.
class FileDownloader {
  FileDownloader._();

  static final FileDownloader instance = FileDownloader._();

  /// Download a file from [url] and save to [savePath].
  /// If [savePath] is null, saves to documents directory with original filename.
  /// [onProgress] callback provides download progress (0.0 to 1.0).
  /// Returns the saved file path on success, null on failure.
  Future<String?> downloadFile({
    required String url,
    String? savePath,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final uri = Uri.parse(url);
      final request = http.Request('GET', uri);
      final response = await http.Client().send(request);

      if (response.statusCode != 200) {
        debugPrint('Download failed with status: ${response.statusCode}');
        return null;
      }

      // Determine save path
      final filePath = savePath ?? await _defaultSavePath(uri);
      final file = File(filePath);

      // iOS Downloader: tracks totalBytesWritten / totalBytesExpectedToWrite
      final totalBytes = response.contentLength ?? -1;
      int receivedBytes = 0;

      final sink = file.openWrite();

      await for (final chunk in response.stream) {
        sink.add(chunk);
        receivedBytes += chunk.length;

        if (onProgress != null && totalBytes > 0) {
          onProgress(receivedBytes / totalBytes);
        }
      }

      await sink.flush();
      await sink.close();

      debugPrint('Download complete: $filePath');
      return filePath;
    } catch (e) {
      debugPrint('Download error: $e');
      return null;
    }
  }

  /// Get default save path in documents directory.
  /// iOS: documentsUrl.appendingPathComponent(url.lastPathComponent)
  Future<String> _defaultSavePath(Uri uri) async {
    final dir = await getApplicationDocumentsDirectory();
    final filename = uri.pathSegments.isNotEmpty
        ? uri.pathSegments.last
        : 'downloaded_file';
    return p.join(dir.path, filename);
  }

  /// Check if a file already exists at the given path.
  Future<bool> fileExists(String path) async {
    return File(path).exists();
  }

  /// Delete a downloaded file.
  Future<bool> deleteFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting file: $e');
      return false;
    }
  }
}
