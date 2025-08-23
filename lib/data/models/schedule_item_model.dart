// models/schedule_item_model.dart
class ScheduleItem {
  final String id; // A unique ID for each class event
  final String type;
  final String time;
  final String course;
  final int durationInHours;
  final String batch;
  final String coordinator;
  final String venue;

  ScheduleItem({
    required this.id,
    required this.time,
    required this.type,
    required this.course,
    required this.durationInHours,
    required this.batch,
    required this.coordinator,
    required this.venue,
  });
}