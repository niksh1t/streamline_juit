import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cached_course_details.dart';

class CourseCacheService {
  /// Saves the course details and a timestamp to SharedPreferences.
  Future<void> saveCourseDetails(String subjectCode, CachedCourseDetails data) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(data.toJson());
    await prefs.setString(subjectCode, jsonString);
  }

  /// Retrieves cached course details from SharedPreferences.
  Future<CachedCourseDetails?> getCourseDetails(String subjectCode) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(subjectCode);
    if (jsonString != null) {
      try {
        final jsonMap = jsonDecode(jsonString);
        return CachedCourseDetails.fromJson(jsonMap);
      } catch (e) {
        // If decoding fails, the cache is corrupt. Return null.
        return null;
      }
    }
    return null;
  }
}
// TODO Implement this library.