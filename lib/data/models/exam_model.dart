import 'package:intl/intl.dart';

class Exam {
  final String subjectName;
  final String subjectCode;
  final DateTime date;
  final String timeSlot;
  final String? roomCode;
  final String? seatNumber;

  Exam({
    required this.subjectName,
    required this.subjectCode,
    required this.date,
    required this.timeSlot,
    this.roomCode,
    this.seatNumber,

  });

  // Factory constructor to parse the JSON map into an Exam object
  factory Exam.fromJson(Map<String, dynamic> json) {
    // Helper to clean the subject description string
    String cleanSubjectDesc(String desc, String code) {
      return desc.replaceAll('($code)', '').trim();
    }
    
    return Exam(
      subjectName: cleanSubjectDesc(json['subjectdesc'], json['subjectcode']),
      subjectCode: json['subjectcode'],
      date: DateFormat('dd/MM/yyyy').parse(json['datetime']),
      timeSlot: json['datetimeupto'],
      roomCode: json['roomcode'],
      seatNumber: json['seatno'],
    );
  }
}