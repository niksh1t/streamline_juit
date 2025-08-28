import 'package:flutter/material.dart';
import '../models/exam_model.dart';
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

  // ✨ FIXED: Switched to DateFormat for more robust date parsing.

  Future<void> loadExams() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _exams = await _examService.getExamSchedule();
      
      // The sorting logic here is already correct and doesn't need to change.
      _exams.sort((a, b) => a.date.compareTo(b.date));

    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}