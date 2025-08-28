import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/exam_model.dart';
import 'crypto_service.dart';
import 'preferences_service.dart';
import 'secure_storage_service.dart';
import '../../config/app_constants.dart'; 

class ExamService {
  final String _baseUrl = "https://webportal.juit.ac.in:6011/StudentPortalAPI";
  final CryptoService _cryptoService;
  final PreferencesService _prefsService;
  final SecureStorageService _storageService;

  ExamService(this._cryptoService, this._prefsService, this._storageService);

  /// Orchestrates the two-step process to fetch the final exam schedule.
  Future<List<Exam>> getExamSchedule() async {
    try {
      // Step 1: Get the latest exam event ID.
      if (kDebugMode) print("--- 🏁 STEP 1: Fetching Exam Events ---");
      final eventId = await _fetchLatestExamEventId();
      if (eventId == null) {
        throw Exception("No upcoming exam events found.");
      }
      if (kDebugMode) print("✅ Got latest exam event ID: $eventId");

      // Step 2: Use the event ID to fetch the detailed schedule.
      if (kDebugMode) print("\n--- 🏁 STEP 2: Fetching Exam Schedule ---");
      final schedule = await _fetchScheduleForEvent(eventId);
      if (kDebugMode) print("✅ Successfully fetched exam schedule.");
      
      return schedule;

    } catch (e) {
      if (kDebugMode) print("❌ An error occurred while fetching exam schedule: $e");
      // Re-throw the exception to be handled by the UI layer.
      rethrow;
    }
  }
  
  /// Fetches all exam events and returns the ID of the first one in the list.
  Future<String?> _fetchLatestExamEventId() async {
    final instituteId = AppConstants.instituteId ; 
    final registrationId = await _prefsService.getRegistrationId();

    if (registrationId == null) {
      throw Exception("User session data (instituteId/registrationId) not found.");
    }

    final payload = {
      "instituteid": instituteId,
      "registationid": registrationId,
    };

    final uri = Uri.parse("$_baseUrl/studentcommonsontroller/getstudentexamevents");
    final response = await _makeAuthenticatedPostRequest(uri, payload);
    
    final examEvents = response['response']['eventcode']['examevent'] as List<dynamic>;

    if (examEvents.isNotEmpty) {
      // The first event is the latest one.
      return examEvents.first['exameventid'] as String?;
    }
    return null;
  }

  /// Fetches the detailed exam schedule for a given event ID.
  Future<List<Exam>> _fetchScheduleForEvent(String eventId) async {
    final instituteId = AppConstants.instituteId;
    final registrationId = await _prefsService.getRegistrationId();

    if (registrationId == null) {
        throw Exception("User session data not found for schedule fetch.");
    }
    
    final payload = {
      "instituteid": instituteId,
      "exameventid": eventId,
      "registrationid": registrationId,
    };
    
    final uri = Uri.parse("$_baseUrl/studentsttattview/getstudent-examschedule");
    final response = await _makeAuthenticatedPostRequest(uri, payload);

    final subjectInfoList = response['response']['subjectinfo'] as List<dynamic>;

    // Map the raw JSON list to a list of strongly-typed Exam objects.
    return subjectInfoList.map((json) => Exam.fromJson(json)).toList();
  }

  /// A generic helper to make authenticated POST requests.
  Future<Map<String, dynamic>> _makeAuthenticatedPostRequest(Uri uri, Map<String, dynamic> payload) async {
    final token = await _storageService.getToken();
    if (token == null) throw Exception("Authentication token not found.");
    
    final dailyKey = _cryptoService.generateDailyKey();
    final encryptedLocalName = _cryptoService.generateEncryptedLocalName();
    final encryptedPayload = _cryptoService.encryptPayload(utf8.encode(jsonEncode(payload)), dailyKey);

    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
      "LocalName": encryptedLocalName,
      // Add other necessary headers from your example if needed.
    };

    if (kDebugMode) print("🌐 Requesting URL: $uri");
    if (kDebugMode) print("📦 Encrypted Payload: $encryptedPayload");

    final response = await http.post(uri, headers: headers, body: jsonEncode(encryptedPayload));

    if (kDebugMode) print("🚦 Response Status Code: ${response.statusCode}");
    if (kDebugMode) print("📦 Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status']['responseStatus'] == 'Success') {
        return data;
      } else {
        // Handle API-level errors (e.g., "Failure" status)
        final errors = data['status']['errors']?.toString() ?? 'Unknown API error';
        throw Exception("API Error: $errors");
      }
    } else {
      // Handle HTTP-level errors (e.g., 401, 404, 500)
      throw Exception("Failed to fetch data. Status code: ${response.statusCode}");
    }
  }
}