// lib/data/providers/captcha_provider.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/secure_storage_service.dart';

class CaptchaProvider with ChangeNotifier {
  // Dependencies
  final AuthService _authService;
  final SecureStorageService _secureStorage;

  CaptchaProvider(this._authService, this._secureStorage);

  // State variables
  bool _isLoading = false;
  String? _errorMessage;
  Uint8List? _captchaImageBytes;
  String _captchaHiddenValue = '';

  // Getters to expose state to the UI
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Uint8List? get captchaImageBytes => _captchaImageBytes;

  // --- ACTIONS ---

  // Called from LoginScreen to get the first captcha
  Future<void> fetchCaptcha() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final captchaData = await _authService.getCaptcha();
      _captchaImageBytes = base64Decode(captchaData['image']!);
      _captchaHiddenValue = captchaData['hidden']!;
    } catch (e) {
      _errorMessage = 'Failed to load captcha. Please go back and try again.';
      _captchaImageBytes = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Called from CaptchaScreen when the user submits
  Future<bool> performLogin({
    required String username,
    required String password,
    required String captchaSolution,
  }) async {
    if (captchaSolution.isEmpty) {
      _errorMessage = "Please enter the captcha solution.";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final sessionData = await _authService.login(
        username: username,
        password: password,
        captchaSolution: captchaSolution,
        captchaHiddenValue: _captchaHiddenValue,
        captchaImage: base64Encode(_captchaImageBytes!),
      );

      // Login Success! Save data.
      await _secureStorage.saveToken(sessionData['token']);

      _isLoading = false;
      notifyListeners();
      return true; // Signal success to the UI

    }on InvalidCredentialsException {
      // ✨ KEY CHANGE: Re-throw the specific exception for the UI to handle.
      rethrow;
    }on InvalidCaptchaException{
      rethrow; 
    }
    catch (e) {
      // Login Failed. Fetch a new captcha.
      _errorMessage = 'Login failed. Please try the new captcha.';
      await fetchCaptcha(); // This will set isLoading to false and notify
      return false; // Signal failure to the UI
    }
  }
}