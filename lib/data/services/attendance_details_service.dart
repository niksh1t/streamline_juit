import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/attendance_details_model.dart';
import '../models/attendance_model_fetched.dart';
import '../../config/app_constants.dart';
import 'crypto_service.dart';
import 'preferences_service.dart'; // ✨ 1. Import the PreferencesService
import 'secure_storage_service.dart';

class AttendanceDetailsService {
  final CryptoService _cryptoService;
  final SecureStorageService _secureStorage;
  final PreferencesService _prefsService; // ✨ 2. Add the service as a dependency

  AttendanceDetailsService(
      this._cryptoService, this._secureStorage, this._prefsService);

  final String _baseUrl = "https://webportal.juit.ac.in:6011/StudentPortalAPI";

  Future<List<AttendanceLog>> fetchCourseAttendanceDetails(
      SubjectAttendance subject) async {
    final url =
        Uri.parse("$_baseUrl/StudentClassAttendance/getstudentsubjectpersentage");

    // ✨ 3. Get registration details dynamically from preferences
    final registrationId = await _prefsService.getRegistrationId();
    final registrationCode = await _prefsService.getRegistrationCode();

    // ✨ 4. Add a check to ensure the data was found
    if (registrationId == null || registrationCode == null) {
      throw Exception("Could not find registration details in storage.");
    }

    final payload = {
      "instituteid": AppConstants.instituteId,
      "subjectid": subject.subjectid,
      "registrationid": registrationId,
      "cmpidkey": [
        {"subjectcomponentid": subject.lectureComponent.subjectcomponentid},
        {"subjectcomponentid": subject.tutorialComponent.subjectcomponentid},
        {"subjectcomponentid": subject.practicalComponent.subjectcomponentid},
      ],
      "subjectcode": subject.individualsubjectcode,
      "registrationcode": registrationCode,
    };
    final payloadString = jsonEncode(payload);

    if (kDebugMode) {
      print("📦 [AttendanceDetails] Raw Payload: $payloadString");
    }

    final dailyKey = _cryptoService.generateDailyKey();
    final encryptedPayload =
        _cryptoService.encryptPayload(utf8.encode(payloadString), dailyKey);
    final encryptedLocalName = _cryptoService.generateEncryptedLocalName();
    final jwtToken = await _secureStorage.getToken();

    if (kDebugMode) {
      print("➡️ [AttendanceDetails] Sending POST request to: $url");
      print("   - Authorization: Bearer ${jwtToken?.substring(0, 15)}...");
      print("   - localname: $encryptedLocalName");
    }

    final response = await http.post(
      url,
      headers: {
        'accept': 'application/json, text/plain, */*',
        'authorization': 'Bearer $jwtToken',
        'content-type': 'application/json',
        'localname': encryptedLocalName,
      },
      body: jsonEncode(encryptedPayload),
    );

    if (kDebugMode) {
      print("⬅️ [AttendanceDetails] Received Response:");
      print("   - Status Code: ${response.statusCode}");
      print("   - Body: ${response.body}");
    }

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['status']['responseStatus'] == 'Success') {
        if (kDebugMode) {
          print("✅ [AttendanceDetails] API call successful. Parsing data.");
        }
        final details = AttendanceDetails.fromJson(data['response']);
        return details.logs;
      } else {
        final errorMessage = data['status']['errors'];
        if (kDebugMode) {
          print("❌ [AttendanceDetails] API returned an error: $errorMessage");
        }
        throw Exception('API returned an error: $errorMessage');
      }
    } else {
      if (kDebugMode) {
        print("❌ [AttendanceDetails] HTTP Error: Request failed.");
      }
      throw Exception(
          'Failed to load attendance details. Status code: ${response.statusCode}');
    }
  }
}