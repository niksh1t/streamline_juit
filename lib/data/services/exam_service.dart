import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/exam_schedule.dart'; // You'll create this model next

class ExamService {
  // Mocks an API call to fetch exam data from a local asset.
  Future<List<Exam>> fetchExams() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    try {
      final String response = await rootBundle.loadString('assets/mock_exams.json');
      final data = json.decode(response);
      
      if (data['status']['responseStatus'] == 'Success') {
        final List<dynamic> subjectInfo = data['response']['subjectinfo'];
        return subjectInfo.map((json) => Exam.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load exams: Invalid response status');
      }
    } catch (e) {
      throw Exception('Error fetching exams: $e');
    }
  }
}