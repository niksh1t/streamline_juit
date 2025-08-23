// lib/services/secure_storage_service.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  // Define keys
  static const _usernameKey = 'username';
  static const _passwordKey = 'password';
  static const _tokenKey = 'jwt_token'; // New key for the token

  // --- Credentials ---
  Future<void> saveCredentials(String username, String password) async {
    await _storage.write(key: _usernameKey, value: username);
    await _storage.write(key: _passwordKey, value: password);
    if (kDebugMode) {
      print("💾 Credentials saved to Secure Storage.");
    }
  }

  Future<Map<String, String?>> getCredentials() async {
    final username = await _storage.read(key: _usernameKey);
    final password = await _storage.read(key: _passwordKey);
    return {'username': username, 'password': password};
  }

  // --- JWT Token ---
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
    if (kDebugMode) {
      print("💾 JWT Token saved to Secure Storage.");
    }
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }
  
  // --- Delete All ---
  Future<void> deleteAll() async {
    await _storage.delete(key: _usernameKey);
    await _storage.delete(key: _passwordKey);
    await _storage.delete(key: _tokenKey);
    if (kDebugMode) {
      print("🗑️ All data deleted from Secure Storage.");
    }
  }
  // debug 
  Future<Map<String, String>> readAll() async {
    return await _storage.readAll();
  }
}