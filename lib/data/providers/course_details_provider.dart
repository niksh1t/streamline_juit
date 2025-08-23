import 'package:flutter/foundation.dart';
import '../models/attendance_details_model.dart';
import '../models/attendance_model_fetched.dart';
import '../models/cached_course_details.dart'; // Import the new cache model
import '../services/attendance_details_service.dart';
import '../services/course_cache_service.dart'; // Import the new cache service
import 'attendance_provider.dart';

class CourseDetailsProvider with ChangeNotifier {
  final AttendanceDetailsService _service;
  final AttendanceProvider _attendanceProvider;
  final CourseCacheService _cacheService; // Add the cache service

  CourseDetailsProvider({
    required AttendanceProvider attendanceProvider,
    required AttendanceDetailsService service,
    required CourseCacheService cacheService, // Inject the cache service
  })  : _attendanceProvider = attendanceProvider,
        _service = service,
        _cacheService = cacheService;

  bool _isLoading = false;
  List<AttendanceLog> _attendanceLogs = [];
  String? _errorMessage;

  bool get isLoading => _isLoading;
  List<AttendanceLog> get attendanceLogs => _attendanceLogs;
  String? get errorMessage => _errorMessage;

  Future<void> fetchDetailsForCourse(String subjectId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Find the subject to get its code, which we'll use as the cache key.
      final SubjectAttendance subject = _attendanceProvider.subjects.firstWhere(
        (s) => s.subjectid == subjectId,
        orElse: () => throw Exception('Subject with ID $subjectId not found.'),
      );
      final String subjectCode = subject.individualsubjectcode;

      // --- CACHING LOGIC START ---

      // 1. Check for fresh data in the cache.
      final cachedData = await _cacheService.getCourseDetails(subjectCode);
      if (cachedData != null && DateTime.now().difference(cachedData.timestamp).inHours < 3) {
        if (kDebugMode) {
          print("✅ [CourseDetails] Using fresh cached data for $subjectCode.");
        }
        _attendanceLogs = cachedData.logs;
      } else {
        if (kDebugMode) {
          print("🚀 [CourseDetails] Cache stale or empty for $subjectCode. Fetching from network...");
        }
        // 2. If cache is stale or missing, fetch from the network.
        final freshLogs = await _service.fetchCourseAttendanceDetails(subject);
        _attendanceLogs = freshLogs;

        // 3. Save the newly fetched data and a timestamp to the cache.
        final dataToCache = CachedCourseDetails(
          timestamp: DateTime.now(),
          logs: freshLogs,
        );
        await _cacheService.saveCourseDetails(subjectCode, dataToCache);
        if (kDebugMode) {
          print("💾 [CourseDetails] Saved fresh data to cache for $subjectCode.");
        }
      }
      // --- CACHING LOGIC END ---

    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearDetails() {
    _attendanceLogs = [];
    _errorMessage = null;
    _isLoading = false;
  }
}