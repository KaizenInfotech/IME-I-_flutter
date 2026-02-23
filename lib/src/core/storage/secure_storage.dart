import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wrapper around flutter_secure_storage for sensitive data.
/// Stores auth tokens, device token, and other secrets.
/// All returns nullable. No force unwraps.
class SecureStorage {
  SecureStorage._();

  static SecureStorage? _instance;
  static SecureStorage get instance => _instance ??= SecureStorage._();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // ─── KEY CONSTANTS ────────────────────────────────────
  static const String _keyAuthToken = 'auth_token';
  static const String _keyDeviceToken = 'device_token';
  static const String _keySessionToken = 'session_auth_token';

  // ─── AUTH TOKEN ───────────────────────────────────────

  Future<void> saveToken(String token) async {
    await _storage.write(key: _keyAuthToken, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _keyAuthToken);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _keyAuthToken);
  }

  // ─── DEVICE TOKEN (FCM) ──────────────────────────────

  Future<void> saveDeviceToken(String token) async {
    await _storage.write(key: _keyDeviceToken, value: token);
  }

  Future<String?> getDeviceToken() async {
    return await _storage.read(key: _keyDeviceToken);
  }

  // ─── SESSION TOKEN ────────────────────────────────────

  Future<void> saveSessionToken(String token) async {
    await _storage.write(key: _keySessionToken, value: token);
  }

  Future<String?> getSessionToken() async {
    return await _storage.read(key: _keySessionToken);
  }

  // ─── GENERIC READ/WRITE ──────────────────────────────

  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  /// Clear all secure storage data (used on logout).
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
