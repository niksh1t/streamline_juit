import 'package:flutter/material.dart';
import '../models/exam_schedule.dart';
import '../services/exam_service.dart';

class ExamProvider with ChangeNotifier {
  final ExamService _examService;

  ExamProvider(this._examService);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Exam> _exams = [];
  List<Exam> get exams => _exams;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadExams() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _exams = await _examService.fetchExams();
      // Sort exams by date for a chronological view
      _exams.sort((a, b) => a.date.compareTo(b.date));
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}