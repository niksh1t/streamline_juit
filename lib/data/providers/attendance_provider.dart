// lib/data/providers/attendance_provider.dart

import 'package:flutter/foundation.dart';
import '../models/attendance_card_model.dart';
import '../models/attendance_model_fetched.dart'; // You need this import
import '../services/attendance_service.dart';
import '../services/preferences_service.dart';

class AttendanceProvider with ChangeNotifier {
  final AttendanceService _attendanceService;
  final PreferencesService _prefsService;

  AttendanceProvider(this._attendanceService, this._prefsService);

  bool _isLoading = false;
  List<AttendanceCardModel> _attendanceCards = [];
  String? _errorMessage;
  DateTime? _lastFetched;
  
  // ✨ ADDED: A new variable to store the raw subject data for other providers.
  // This does not change any of the existing variable names.
  List<SubjectAttendance> _subjects = [];

  bool get isLoading => _isLoading;
  List<AttendanceCardModel> get attendanceCards => _attendanceCards;
  String? get errorMessage => _errorMessage;
  DateTime? get lastFetched => _lastFetched;
  
  // ✨ ADDED: A public getter for the raw subject data.
  List<SubjectAttendance> get subjects => _subjects;


  Future<void> fetchAttendanceData() async {
    // Start loading and notify the UI immediately
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final cachedData = await _prefsService.getCachedAttendanceData();

      if (cachedData != null && DateTime.now().difference(cachedData.timestamp).inHours < 6) {
        if (kDebugMode) {
          print("✅ Using fresh cached attendance data. No API call needed.");
        }
        // Populate both the raw list and the UI card list from the cache
        _subjects = cachedData.subjects;
        _attendanceCards = _subjects
            .map((subject) => AttendanceCardModel.fromSubject(subject))
            .toList();
        _lastFetched = cachedData.timestamp;
      } else {
        if (kDebugMode) {
          print("🚀 Cache is stale or empty. Fetching from network...");
        }
        final freshAttendanceData = await _attendanceService.fetchAttendance();
        await _prefsService.saveAttendanceData(freshAttendanceData);

        // Populate both the raw list and the UI card list from the API
        _subjects = freshAttendanceData.subjects;
        _attendanceCards = _subjects
            .map((subject) => AttendanceCardModel.fromSubject(subject))
            .toList();
        _lastFetched = freshAttendanceData.timestamp;
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error fetching attendance: $e");
      }
      _errorMessage = "Failed to load attendance. Please try again.";
      _attendanceCards = []; // Clear data on error
      _subjects = []; // Also clear the raw data on error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearAttendance() {
    _attendanceCards = [];
    _subjects = []; // Also clear the raw data list
    _errorMessage = null;
    _lastFetched = null;
    if (kDebugMode) {
      print("🧹 Attendance provider in-memory state cleared.");
    }
    notifyListeners();
  }
}