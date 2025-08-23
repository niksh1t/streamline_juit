// providers/schedule_provider.dart
import 'package:flutter/material.dart';
import '../models/schedule_item_model.dart';

class ScheduleProvider with ChangeNotifier {
  int _selectedDayIndex = DateTime.now().weekday - 1;
  late List<DateTime> _weekDays;
  List<ScheduleItem> _dailySchedule = [];
  bool _isLoading = false;

  int get selectedDayIndex => _selectedDayIndex;
  List<DateTime> get weekDays => _weekDays;
  List<ScheduleItem> get dailySchedule => _dailySchedule;
  bool get isLoading => _isLoading;

  // In a real app, this would come from an API
  final Map<int, List<ScheduleItem>> _masterSchedule = {
  // Monday
   0: [
      ScheduleItem(id: '20B1WCI531', time: '9:00 AM', course: 'Foundation For Data Science and Visualization', type: 'L', durationInHours: 1, batch: 'ALL_BATCHES', coordinator: 'RBT', venue: 'CR10'),
      ScheduleItem(id: '18B11CI514', time: '10:00 AM', course: 'Computer Organization and Architecture', type: 'L', durationInHours: 1, batch: '23A14,23A15,23A16', coordinator: 'KTS', venue: 'CR9'),
      ScheduleItem(id: '18B17CI575', time: '11:00 AM', course: 'Computer Graphics Lab', type: 'P', durationInHours: 2, batch: '23A16', coordinator: 'ATA', venue: 'CL9_2'),
      ScheduleItem(id: '18B11HS511', time: '2:00 PM', course: 'Project Management and Entrepreneurship', type: 'L', durationInHours: 1, batch: '23A11,23A12,23A13', coordinator: 'ANU', venue: 'LT2'),
    ],
};

  ScheduleProvider() {
    _generateWeekDays();
    selectDay(_selectedDayIndex); // Load today's schedule initially
  }

  void _generateWeekDays() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    _weekDays = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
  }

  Future<void> selectDay(int index) async {
    _selectedDayIndex = index;
    _isLoading = true;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    _dailySchedule = _masterSchedule[index] ?? [];
    _isLoading = false;
    notifyListeners();
  }
}