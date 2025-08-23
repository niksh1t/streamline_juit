// providers/schedule_details_provider.dart
import 'package:flutter/material.dart';
import '../models/class_details_model.dart';
import '../models/schedule_item_model.dart';

class ScheduleDetailsProvider with ChangeNotifier {
  ClassDetails? _classDetails;
  bool _isLoading = false;
  String? _error;

  ClassDetails? get classDetails => _classDetails;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // This simulates a data store where details are looked up by ID
  final Map<String, Map<String, dynamic>> _detailsStore = {
    'CN1': {'attendance': '85%'},
    'OS1': {'attendance': '92%'},
    'DS1': {'attendance': '78%'},
    'DBL1': {'attendance': '95%'},
  };

  Future<void> fetchDetails(ScheduleItem item) async {
    _isLoading = true;
    _classDetails = null; // Clear previous details
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    final detailsData = _detailsStore[item.id];
    if (detailsData != null) {
      _classDetails = ClassDetails(
        courseName: item.course,
        venue: item.venue,
        batch: item.batch,
        coordinator: item.coordinator,
        attendance: detailsData['attendance'] ?? 'N/A',
      );
    } else {
      _error = "Details not found.";
    }

    _isLoading = false;
    notifyListeners();
  }
}