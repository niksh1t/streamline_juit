// lib/services/auth_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'crypto_service.dart';
import 'preferences_service.dart';

// Custom exception for clear error handling in the UI
class InvalidCredentialsException implements Exception {
  final String message;
  InvalidCredentialsException(this.message);

  @override
  String toString() => message;
}
class InvalidCaptchaException implements Exception{
  final String message; 
  InvalidCaptchaException(this.message); 
  
  @override
  String toString() => message; 
}

class AuthService {
  final String _baseUrl = "https://webportal.juit.ac.in:6011/StudentPortalAPI";
  final CryptoService _cryptoService = CryptoService();
  final PreferencesService _prefsService;

  AuthService(this._prefsService);

  // No changes needed in getCaptcha or login methods...
  Future<Map<String, String>> getCaptcha() async {
    if (kDebugMode) {
      print("\n--- 🏁 STEP 1: GETTING CAPTCHA ---");
    }
    final encryptedLocalName = _cryptoService.generateEncryptedLocalName();
    final headers = {
      "accept": "application/json, text/plain, */*",
      "authorization": "Bearer",
      "content-type": "application/json",
      "localname": encryptedLocalName,
    };
    final uri = Uri.parse("$_baseUrl/token/getcaptcha");
    
    if (kDebugMode) {
      print("🌐 Requesting URL: $uri");
    }

    final response = await http.get(uri, headers: headers);
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final captchaData = data['response']['captcha'];
      if (kDebugMode) {
        print("✅ Captcha received successfully.");
      }
      return {
        'image': captchaData['image'] as String,
        'hidden': captchaData['hidden'] as String,
      };
    } else {
      if (kDebugMode) {
        print("❌ FAILED to load captcha.");
      }
      throw Exception('Failed to load captcha from API');
    }
  }

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
    required String captchaSolution,
    required String captchaHiddenValue,
    required String captchaImage,
  }) async {
    final dailyKey = _cryptoService.generateDailyKey();
    final encryptedLocalName = _cryptoService.generateEncryptedLocalName();
    
    final randomValue = await _performPreTokenCheck(
      username: username,
      captchaSolution: captchaSolution,
      captchaHiddenValue: captchaHiddenValue,
      captchaImage: captchaImage,
      dailyKey: dailyKey,
      encryptedLocalName: encryptedLocalName,
    );

    final sessionData = await _generateToken(
      username: username,
      password: password,
      randomValue: randomValue,
      dailyKey: dailyKey,
      encryptedLocalName: encryptedLocalName,
    );
    
    if (kDebugMode) {
      print("\n🎉🎉🎉 LOGIN SUCCESSFUL! 🎉🎉🎉");
    }
    return sessionData;
  }

  Future<String> _performPreTokenCheck({
    required String username,
    required String captchaSolution,
    required String captchaHiddenValue,
    required String captchaImage,
    required Uint8List dailyKey,
    required String encryptedLocalName,
  }) async {
    if (kDebugMode) {
      print("\n--- 🏁 STEP 2: PRE-TOKEN CHECK ---");
    }
    
    final payload = {
      'username': username,
      'usertype': 'S',
      'captcha': {
        'captcha': captchaSolution,
        'hidden': captchaHiddenValue,
        'image': captchaImage,
      }
    };
    final payloadJsonString = jsonEncode(payload);
    final encryptedPayload = _cryptoService.encryptPayload(utf8.encode(payloadJsonString), dailyKey);

    final uri = Uri.parse("$_baseUrl/token/pretoken-check");
    final headers = {
      "accept": "application/json, text/plain, */*",
      "authorization": "Bearer",
      "content-type": "application/json",
      "localname": encryptedLocalName,
    };

    final response = await http.post(uri, headers: headers, body: jsonEncode(encryptedPayload));
    
    if (kDebugMode) {
      print("🚦 Response Status Code: ${response.statusCode}");
      print("📦 Response Body: ${response.body}");
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final randomValue = data['response']['random'] as String;
      if (kDebugMode) {
        print("✅ Pre-token check successful.");
      }
      return randomValue;
    } else {
      // ✨ FIXED: Updated to parse the correct error structure from the API response.
      if (response.statusCode == 404) {
       
          final responseBody = jsonDecode(response.body);
          // Check the new error structure: status -> errors -> [list]
          if (responseBody['status'] != null &&
              responseBody['status']['errors'] is List &&
              (responseBody['status']['errors'] as List).isNotEmpty) {
                
            final errorMessage = (responseBody['status']['errors'][0] ?? '').toString().toLowerCase();
            if(kDebugMode){
              print(errorMessage);
            }
            
            if (errorMessage.contains('invalid login credential!')) {
               throw InvalidCredentialsException('Invalid username. Please try again.');
            }
            if(errorMessage.contains('invalid captcha submitted..')){
              throw InvalidCaptchaException("Invalid captcha. Please try again."); 
            }
          }
      }
      // For all other errors, throw a generic exception
      throw Exception('login failed with status: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> _generateToken({
    required String username,
    required String password,
    required String randomValue,
    required Uint8List dailyKey,
    required String encryptedLocalName,
  }) async {
    // ... (no changes in this method)
    if (kDebugMode) {
      print("\n--- 🏁 STEP 3: GENERATE TOKEN ---");
    }

    final payload = {
      "otppwd": "PWD",
      "username": username,
      "passwordotpvalue": password,
      "Modulename": "STUDENTMODULE",
      "random": randomValue
    };
    final payloadJsonString = jsonEncode(payload);
    final encryptedPayload = _cryptoService.encryptPayload(utf8.encode(payloadJsonString), dailyKey);

    final uri = Uri.parse("$_baseUrl/token/generate-token1");
    final headers = {
      "accept": "application/json, text/plain, */*",
      "authorization": "Bearer",
      "content-type": "application/json",
      "localname": encryptedLocalName,
    };
    
    final response = await http.post(uri, headers: headers, body: jsonEncode(encryptedPayload));
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final regdata = data['response']['regdata'] as Map<String, dynamic>;
      
      if (kDebugMode) {
        print("✅ Token generation successful.");
      }

      try {
        final String name = regdata['name'];
        final String enrollmentNo = regdata['enrollmentno'];
        await _prefsService.saveUserSession(name: name, enrollmentNo: enrollmentNo);
      } catch (e) {
        if (kDebugMode) {
          print("🚨 Could not parse or save user details from login response: $e");
        }
      }
      
      return regdata;
    } else {
      if (kDebugMode) {
        print("❌ FAILED token generation.");
      }
        throw InvalidCredentialsException('Invalid Password. Please try again.');
    }
  }
}

