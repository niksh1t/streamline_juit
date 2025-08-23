import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../config/app_constants.dart';
import 'crypto_service.dart';
import 'preferences_service.dart'; // ✨ 1. Import the PreferencesService
import 'secure_storage_service.dart';
import '../models/attendance_model_fetched.dart';

class AttendanceService {
  final CryptoService _cryptoService;
  final SecureStorageService _secureStorage;
  final PreferencesService _prefsService; // ✨ 2. Add the service as a dependency

  // Dependencies are injected for testability
  AttendanceService(this._cryptoService, this._secureStorage, this._prefsService);

  final String _baseUrl = "https://webportal.juit.ac.in:6011/StudentPortalAPI/StudentClassAttendance";
  final String _instituteId = "INID2201J000001"; // Hardcoded as per API doc

  Future<AttendanceData> fetchAttendance() async {
    if (kDebugMode) {
      print("--- 🚀 STARTING ATTENDANCE FETCH ---");
    }
    final token = await _secureStorage.getToken();
    if (token == null) throw Exception("Authentication token not found.");

    // --- STEP 1: Get Registration Info to find the current semester ---
    final regInfo = await _getRegistrationInfo(token);
    final styNumber = regInfo['styNumber'];
    final semester = regInfo['semester'];

    if (styNumber == null || semester == null) {
      throw Exception("Could not determine current semester information.");
    }

    // --- STEP 2: Get the detailed attendance data for that semester ---
    final attendanceList = await _getAttendanceDetails(token, styNumber, semester);
    
    // --- STEP 3: Package the data with a timestamp ---
    final attendanceData = AttendanceData(
      timestamp: DateTime.now(),
      subjects: attendanceList,
    );

    if (kDebugMode) {
      print("--- ✅ ATTENDANCE FETCH SUCCESSFUL ---");
    }
    return attendanceData;
  }

  Future<Map<String, dynamic>> _getRegistrationInfo(String token) async {
    if (kDebugMode) {
      print("---  fetching registration info ---");
    }
    final encryptedLocalName = _cryptoService.generateEncryptedLocalName();
    final headers = _getHeaders(token, encryptedLocalName);
    final body = jsonEncode({"instituteid": _instituteId});
    final uri = Uri.parse("$_baseUrl/getstudentInforegistrationforattendence");
    
    final response = await http.post(uri, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['response'];
      final headerList = data['headerlist'][0];
      final semList = data['semlist'][0];
      final styNumber = headerList['stynumber'];

      // ✨ 3. Save the details using the separate setter methods
      await _prefsService.saveStyNumber(styNumber);
      await _prefsService.saveRegistrationDetails(
        registrationId: semList['registrationid'],
        registrationCode: semList['registrationcode'],
      );
      
      return {
        'styNumber': styNumber,
        'semester': {
          'registrationid': semList['registrationid'],
          'registrationcode': semList['registrationcode'],
        }
      };
    } else {
      throw Exception("Failed to get registration info: ${response.body}");
    }
  }

  Future<List<SubjectAttendance>> _getAttendanceDetails(String token, String styNumber, Map<String, dynamic> semester) async {
    if (kDebugMode) {
      print("--- fetching attendance details ---");
    }
    final encryptedLocalName = _cryptoService.generateEncryptedLocalName();
    final headers = _getHeaders(token, encryptedLocalName);
    
    final payload = {
      "instituteid": AppConstants.instituteId,
      "stynumber": styNumber,
      "registrationid": semester['registrationid'],
      "registrationcode": semester['registrationcode'],
    };

    final encryptedBody = _cryptoService.encryptPayload(
      utf8.encode(jsonEncode(payload)),
      _cryptoService.generateDailyKey(),
    );

    final uri = Uri.parse("$_baseUrl/getstudentattendancedetail");
    final response = await http.post(uri, headers: headers, body: jsonEncode(encryptedBody));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['response'];
      final List<dynamic> subjectListJson = data['studentattendancelist'];
      
      // Map the JSON list to our strongly-typed model list
      return subjectListJson.map((json) => SubjectAttendance.fromJson(json)).toList();
    } else {
      throw Exception("Failed to get attendance details: ${response.body}");
    }
  }

  Map<String, String> _getHeaders(String token, String localName) {
    return {
      "accept": "application/json, text/plain, */*",
      "authorization": "Bearer $token",
      "content-type": "application/json",
      "localname": localName,
    };
  }
}