class AttendanceDetails {
  final List<AttendanceLog> logs;

  AttendanceDetails({required this.logs});

  factory AttendanceDetails.fromJson(Map<String, dynamic> json) {
    // The response contains a list under the key 'studentAttdsummarylist'
    final logList = json['studentAttdsummarylist'] as List<dynamic>? ?? [];
    return AttendanceDetails(
      logs: logList.map((logJson) => AttendanceLog.fromJson(logJson)).toList(),
    );
  }
}

class AttendanceLog {
  final String attendanceBy;
  final String attendanceStatus;
  final String classType;
  final String dateTime;
  final String status; // 'Present' or 'Absent'

  AttendanceLog({
    required this.attendanceBy,
    required this.attendanceStatus,
    required this.classType,
    required this.dateTime,
    required this.status,
  });

  factory AttendanceLog.fromJson(Map<String, dynamic> json) {
    return AttendanceLog(
      attendanceBy: json['attendanceby'] ?? 'N/A',
      attendanceStatus: json['attendancestatus'] ?? 'N/A',
      classType: json['classtype'] ?? 'N/A',
      dateTime: json['datetime'] ?? 'Unknown Date',
      status: json['present'] ?? 'N/A',
    );
  }

  /// Converts the AttendanceLog object into a JSON map for caching.
  Map<String, dynamic> toJson() {
    return {
      'attendanceby': attendanceBy,
      'attendancestatus': attendanceStatus,
      'classtype': classType,
      'datetime': dateTime,
      'present': status,
    };
  }
}