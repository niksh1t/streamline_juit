// Make sure this path points to the file with your updated models
import 'attendance_model_fetched.dart'; 

class AttendanceCardModel {
  final String courseName;
  final String courseType;
  final String subjectId; 
  final String lectureAttendance;
  final String practicalAttendance;
  final String tutorialAttendance;
  final String totalAttendance;

  AttendanceCardModel({
    required this.courseName,
    required this.courseType,
    required this.subjectId,
    required this.lectureAttendance,
    required this.practicalAttendance,
    required this.tutorialAttendance,
    required this.totalAttendance,
  });

  /// Factory to map the raw [SubjectAttendance] data model to a display-ready model.
  factory AttendanceCardModel.fromSubject(SubjectAttendance subject) {
    
    String formatAttendance(double attended, double total) {
      if (total == 0) return '';
      return '${attended.toInt()}/${total.toInt()}';
    }

    String determineCourseType(SubjectAttendance sub) {
      // Use the new field name 'subjectcode'
      if (sub.subjectcode.toLowerCase().contains('lab')) return 'Practical';
      // Access practical and tutorial data from the component models
      if (sub.practicalComponent.totalclass > 0) return 'Practical';
      if (sub.tutorialComponent.totalclass > 0) return 'Tutorial';
      return 'Lecture';
    }

    String formatCourseName(String rawName) {
      int parenIndex = rawName.indexOf('(');
      String namePart = (parenIndex != -1 ? rawName.substring(0, parenIndex) : rawName).trim();
      
      String titleCasedName = namePart.split(' ').map((word) {
        if (word.isEmpty) return '';
        if (word.length <= 1) return word.toUpperCase();
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      }).join(' ');
      
      return titleCasedName;
    }

    return AttendanceCardModel(
      // Use the updated field names from the new model
      courseName: formatCourseName(subject.subjectcode),
      courseType: determineCourseType(subject),
      subjectId: subject.subjectid,
      totalAttendance: '${subject.LTpercantage.toStringAsFixed(1)}%',
      lectureAttendance: formatAttendance(
        subject.lectureComponent.totalpres, 
        subject.lectureComponent.totalclass
      ),
      practicalAttendance: formatAttendance(
        subject.practicalComponent.totalpres,
        subject.practicalComponent.totalclass
      ),
      tutorialAttendance: formatAttendance(
        subject.tutorialComponent.totalpres,
        subject.tutorialComponent.totalclass
      ),
    );
  }
}