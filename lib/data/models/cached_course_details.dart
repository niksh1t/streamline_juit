import 'attendance_details_model.dart';

/// A wrapper class to hold the attendance logs along with a timestamp for caching.
class CachedCourseDetails {
  final DateTime timestamp;
  final List<AttendanceLog> logs;

  CachedCourseDetails({required this.timestamp, required this.logs});

  /// Creates an object from a JSON map.
  factory CachedCourseDetails.fromJson(Map<String, dynamic> json) {
    final logList = (json['logs'] as List<dynamic>)
        .map((logJson) => AttendanceLog.fromJson(logJson))
        .toList();
    return CachedCourseDetails(
      timestamp: DateTime.parse(json['timestamp']),
      logs: logList,
    );
  }

  /// Converts the object to a JSON map for storing.
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'logs': logs.map((log) => log.toJson()).toList(),
    };
  }
}