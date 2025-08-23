// models/class_details_model.dart
class ClassDetails {
  final String courseName;
  final String venue;
  final String batch;
  final String coordinator;
  final String attendance; // e.g., "85%"

  ClassDetails({
    required this.courseName,
    required this.venue,
    required this.batch,
    required this.coordinator,
    required this.attendance,
  });
}