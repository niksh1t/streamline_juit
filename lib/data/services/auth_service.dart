// lib/services/auth_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'crypto_service.dart';
import 'preferences_service.dart';

class AuthService {
  final String _baseUrl = "https://webportal.juit.ac.in:6011/StudentPortalAPI";
  final CryptoService _cryptoService = CryptoService();
  final PreferencesService _prefsService;

  // ✨ 2. INITIALIZE IN THE CONSTRUCTOR
  // This was also missing. It allows you to pass in the service when you create AuthService.
  AuthService(this._prefsService);
  // STEP 1: Get Captcha
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
    if (kDebugMode) {
      print("📋 Request Headers: $headers");
    }

    final response = await http.get(uri, headers: headers);
    if (kDebugMode) {
      print("🚦 Response Status Code: ${response.statusCode}");
    }
    if (kDebugMode) {
      print("📦 Response Body: ${response.body}");
    }

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

  // Main login function orchestrating STEP 2 and 3
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
    required String captchaSolution,
    required String captchaHiddenValue,
    required String captchaImage,
  }) async {
    // Get fresh crypto values for this session
    final dailyKey = _cryptoService.generateDailyKey();
    final encryptedLocalName = _cryptoService.generateEncryptedLocalName();
    
    // --- STEP 2: Pre-token Check ---
    final randomValue = await _performPreTokenCheck(
      username: username,
      captchaSolution: captchaSolution,
      captchaHiddenValue: captchaHiddenValue,
      captchaImage: captchaImage,
      dailyKey: dailyKey,
      encryptedLocalName: encryptedLocalName,
    );

    // --- STEP 3: Generate Token ---
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
    
    // Create pre-token payload
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
    if (kDebugMode) {
      print("📦 Pre-token Payload (raw): $payloadJsonString");
    }
    
    final encryptedPayload = _cryptoService.encryptPayload(utf8.encode(payloadJsonString), dailyKey);
    if (kDebugMode) {
      print("🔒 Pre-token Payload (encrypted): $encryptedPayload");
    }

    final uri = Uri.parse("$_baseUrl/token/pretoken-check");
    final headers = {
      "accept": "application/json, text/plain, */*",
      "authorization": "Bearer",
      "content-type": "application/json",
      "localname": encryptedLocalName,
    };
    
    if (kDebugMode) {
      print("🌐 Requesting URL: $uri");
    }
    if (kDebugMode) {
      print("📋 Request Headers: $headers");
    }
    if (kDebugMode) {
      print("📦 Request Body: $encryptedPayload");
    }

    final response = await http.post(uri, headers: headers, body: jsonEncode(encryptedPayload));
    if (kDebugMode) {
      print("🚦 Response Status Code: ${response.statusCode}");
    }
    if (kDebugMode) {
      print("📦 Response Body: ${response.body}");
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final randomValue = data['response']['random'] as String;
      if (kDebugMode) {
        print("✅ Pre-token check successful. Got 'random' value: $randomValue");
      }
      return randomValue;
    } else {
      if (kDebugMode) {
        print("❌ FAILED pre-token check.");
      }
      throw Exception('Pre-token check failed');
    }
  }

  Future<Map<String, dynamic>> _generateToken({
    required String username,
    required String password,
    required String randomValue,
    required Uint8List dailyKey,
    required String encryptedLocalName,
  }) async {
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
    if (kDebugMode) {
      print("📦 Generate-token Payload (raw): $payloadJsonString");
    }

    final encryptedPayload = _cryptoService.encryptPayload(utf8.encode(payloadJsonString), dailyKey);
    if (kDebugMode) {
      print("🔒 Generate-token Payload (encrypted): $encryptedPayload");
    }

    final uri = Uri.parse("$_baseUrl/token/generate-token1");
    final headers = {
      "accept": "application/json, text/plain, */*",
      "authorization": "Bearer",
      "content-type": "application/json",
      "localname": encryptedLocalName,
    };

    if (kDebugMode) {
      print("🌐 Requesting URL: $uri");
    }
    if (kDebugMode) {
      print("📋 Request Headers: $headers");
    }
    if (kDebugMode) {
      print("📦 Request Body: $encryptedPayload");
    }

    final response = await http.post(uri, headers: headers, body: jsonEncode(encryptedPayload));
    if (kDebugMode) {
      print("🚦 Response Status Code: ${response.statusCode}");
    }
    if (kDebugMode) {
      print("📦 Response Body: ${response.body}");
    }

 if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final regdata = data['response']['regdata'] as Map<String, dynamic>;
      
      if (kDebugMode) {
        print("✅ Token generation successful.");
      }

      // ✨ 4. Extract and save the user details
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
      throw Exception('Failed to generate token');
    }
  }
}