import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/attendance_model_fetched.dart';

class PreferencesService {
  // Keys for your preferences
  static const String _darkModeKey = 'isDarkMode';
  static const String _userNameKey = 'userName';
  static const String _tokenExpiryKey = 'tokenExpiry';
  static const String _attendanceDataKey = 'attendanceData';
  static const String _enrollmentNoKey = 'enrollmentNo';
  static const String _registrationIdKey = 'registrationId';
  static const String _registrationCodeKey = 'registrationCode';
  static const String _styNumberKey = 'styNumber';

  // --- Theme ---
  Future<void> saveThemePreference(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, isDarkMode);
  }

  Future<bool> getThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false;
  }

  // --- User Session Data ---
  // ✨ This method now only saves the user's name and enrollment number.
  Future<void> saveUserSession({
    required String name,
    required String enrollmentNo,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final expiryTime = DateTime.now().add(const Duration(hours: 24));
    
    await prefs.setString(_userNameKey, name);
    await prefs.setString(_enrollmentNoKey, enrollmentNo);
    await prefs.setString(_tokenExpiryKey, expiryTime.toIso8601String());
    if (kDebugMode) {
      print("💾 User name and enrollment number saved to SharedPreferences.");
    }
  }

  // ✨ New, separate method for registration details.
  Future<void> saveRegistrationDetails({
    required String registrationId,
    required String registrationCode,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_registrationIdKey, registrationId);
    await prefs.setString(_registrationCodeKey, registrationCode);
    if (kDebugMode) {
      print("💾 Registration ID and Code saved to SharedPreferences.");
    }
  }

  // ✨ Separate method for styNumber remains.
  Future<void> saveStyNumber(String styNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_styNumberKey, styNumber);
    if (kDebugMode) {
      print("💾 styNumber saved to SharedPreferences.");
    }
  }

  // --- Getters for all session data ---
  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  Future<String?> getEnrollmentNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_enrollmentNoKey);
  }

  Future<String?> getRegistrationId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_registrationIdKey);
  }

  Future<String?> getRegistrationCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_registrationCodeKey);
  }

  Future<String?> getStyNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_styNumberKey);
  }
  
  Future<DateTime?> getTokenExpiry() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryString = prefs.getString(_tokenExpiryKey);
    if (expiryString == null) return null;
    return DateTime.tryParse(expiryString);
  }
  
  // --- Clear Session ---
  Future<void> clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userNameKey);
    await prefs.remove(_tokenExpiryKey);
    await prefs.remove(_enrollmentNoKey);
    await prefs.remove(_registrationIdKey);
    await prefs.remove(_registrationCodeKey);
    await prefs.remove(_styNumberKey);
    await prefs.remove(_attendanceDataKey);
    if (kDebugMode) {
      print("🗑️ User session and all caches cleared from SharedPreferences.");
    }
  }
  
  // --- Caching Methods ---
  Future<void> saveAttendanceData(AttendanceData data) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(data.toJson());
    await prefs.setString(_attendanceDataKey, jsonString);
    if (kDebugMode) {
      print("💾 Attendance data cached successfully with timestamp: ${data.timestamp}");
    }
  }

  Future<AttendanceData?> getCachedAttendanceData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_attendanceDataKey);

    if (jsonString != null) {
      final data = AttendanceData.fromJson(jsonDecode(jsonString));
      if (kDebugMode) {
        print("✅ Found cached attendance data from: ${data.timestamp}");
      }
      return data;
    }
    
    if (kDebugMode) {
      print("🤷 No cached attendance data found.");
    }
    return null;
  }
}