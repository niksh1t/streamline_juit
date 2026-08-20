
// 1. TOP-LEVEL MODEL
class AttendanceData {
  final DateTime timestamp;
  final List<SubjectAttendance> subjects;

  AttendanceData({
    required this.timestamp,
    required this.subjects,
  });

  factory AttendanceData.fromJson(Map<String, dynamic> json) {
    final subjectsList = json['studentattendancelist'] as List<dynamic>? ?? [];
    return AttendanceData(
      timestamp: DateTime.parse(json['timestamp']),
      subjects: List<SubjectAttendance>.from(
        subjectsList.map((s) => SubjectAttendance.fromJson(s)),
      ),
    );
  }

  // ✨ ADDED THIS METHOD ✨
  /// Converts the object to a JSON map, suitable for caching.
  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'studentattendancelist': subjects.map((s) => s.toJson()).toList(),
      };
}

// 2. INDIVIDUAL SUBJECT MODEL
class SubjectAttendance {
  // ignore: non_constant_identifier_names
  final double LTpercantage;
  final String individualsubjectcode;
  final int slno;
  final String subjectcode;
  final String subjectid;
  final double abseent;
  final AttendanceComponent lectureComponent;
  final AttendanceComponent practicalComponent;
  final AttendanceComponent tutorialComponent;

  SubjectAttendance({
    // ignore: non_constant_identifier_names
    required this.LTpercantage,
    required this.individualsubjectcode,
    required this.slno,
    required this.subjectcode,
    required this.subjectid,
    required this.abseent,
    required this.lectureComponent,
    required this.practicalComponent,
    required this.tutorialComponent,
  });

  factory SubjectAttendance.fromJson(Map<String, dynamic> json) {
    // ... fromJson factory remains the same
    double safeParseDouble(dynamic value) {
      if (value == null || value.toString().isEmpty) return 0.0;
      return double.tryParse(value.toString()) ?? 0.0;
    }
    int safeParseInt(dynamic value) {
      if (value == null) return 0;
      return int.tryParse(value.toString()) ?? 0;
    }
    return SubjectAttendance(
      LTpercantage: safeParseDouble(json['LTpercantage']),
      individualsubjectcode: json['individualsubjectcode'] ?? 'N/A',
      slno: safeParseInt(json['slno']),
      subjectcode: json['subjectcode'] ?? 'Unknown Subject',
      subjectid: json['subjectid'] ?? 'N/A',
      abseent: safeParseDouble(json['abseent']),
      lectureComponent: AttendanceComponent.fromJson(json, 'L'),
      practicalComponent: AttendanceComponent.fromJson(json, 'P'),
      tutorialComponent: AttendanceComponent.fromJson(json, 'T'),
    );
  }

  // ✨ ADDED THIS METHOD ✨
  /// Converts the object back to a flat JSON map, mirroring the API structure.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'LTpercantage': LTpercantage,
      'individualsubjectcode': individualsubjectcode,
      'slno': slno,
      'subjectcode': subjectcode,
      'subjectid': subjectid,
      'abseent': abseent,
    };
    data.addAll(lectureComponent.toJsonWithPrefix('L'));
    data.addAll(practicalComponent.toJsonWithPrefix('P'));
    data.addAll(tutorialComponent.toJsonWithPrefix('T'));
    return data;
  }
}

// 3. REUSABLE COMPONENT MODEL
class AttendanceComponent {
  final double percentage;
  final double prepercentage;
  final double pretotalclass;
  final double pretotalpres;
  final String subjectcomponentcode;
  final String subjectcomponentid;
  final double totalclass;
  final double totalpres;

  AttendanceComponent({
    required this.percentage,
    required this.prepercentage,
    required this.pretotalclass,
    required this.pretotalpres,
    required this.subjectcomponentcode,
    required this.subjectcomponentid,
    required this.totalclass,
    required this.totalpres,
  });
  
  factory AttendanceComponent.fromJson(Map<String, dynamic> json, String prefix) {
    // ... fromJson factory remains the same
    double safeParseDouble(dynamic value) {
      if (value == null || value.toString().isEmpty) return 0.0;
      return double.tryParse(value.toString()) ?? 0.0;
    }
    return AttendanceComponent(
      percentage: safeParseDouble(json['${prefix}percentage']),
      prepercentage: safeParseDouble(json['${prefix}prepercentage']),
      pretotalclass: safeParseDouble(json['${prefix}pretotalclass']),
      pretotalpres: safeParseDouble(json['${prefix}pretotalpres']),
      subjectcomponentcode: json['${prefix}subjectcomponentcode'] ?? '',
      subjectcomponentid: json['${prefix}subjectcomponentid'] ?? '',
      totalclass: safeParseDouble(json['${prefix}totalclass']),
      totalpres: safeParseDouble(json['${prefix}totalpres']),
    );
  }

  // ✨ ADDED THIS HELPER METHOD ✨
  /// Converts the component's data to a map with the correct 'L', 'P', or 'T' prefix.
  Map<String, dynamic> toJsonWithPrefix(String prefix) {
    return {
      '${prefix}percentage': percentage,
      '${prefix}prepercentage': prepercentage,
      '${prefix}pretotalclass': pretotalclass,
      '${prefix}pretotalpres': pretotalpres,
      '${prefix}subjectcomponentcode': subjectcomponentcode,
      '${prefix}subjectcomponentid': subjectcomponentid,
      '${prefix}totalclass': totalclass,
      '${prefix}totalpres': totalpres,
    };
  }
}