import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/providers/attendance_provider.dart';
import '../screens/course_details_page.dart';
import '../widgets/attendance_card.dart';
import '../widgets/attendance_appbar.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  @override
  void initState() {
    super.initState();
    // ✨ 1. Simplified data fetching in initState.
    // This calls the provider's method right after the first frame is built.
    Future.microtask(() =>
        Provider.of<AttendanceProvider>(context, listen: false).fetchAttendanceData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AttendanceAppBar(
        onCalculatePressed: () {
          // You can add logic for the calculator button here
        },
      ),
      body: Consumer<AttendanceProvider>(
        builder: (context, provider, child) {
          // ✨ 2. Improved loading logic: show a centered indicator only on the initial load.
          if (provider.isLoading && provider.attendanceCards.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(provider.errorMessage!, textAlign: TextAlign.center),
              ),
            );
          }

          if (provider.attendanceCards.isEmpty) {
            return const Center(child: Text('No attendance data available.'));
          }

          // ✨ 3. Added RefreshIndicator for pull-to-refresh functionality.
          // This call respects your 1-hour cache rule.
          return RefreshIndicator(
            onRefresh: () => provider.fetchAttendanceData(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              // ✨ 4. Switched from .courses to .attendanceCards
              itemCount: provider.attendanceCards.length,
              itemBuilder: (context, index) {
                // The provider now gives us the ready-to-use card model
                final cardModel = provider.attendanceCards[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  // ✨ 5. Updated AttendanceCard to use the new model's properties
                  child: AttendanceCard(
                    courseName: cardModel.courseName,
                    courseType: cardModel.courseType,
                    lectureAttendance: cardModel.lectureAttendance,
                    practicalAttendance: cardModel.practicalAttendance,
                    tutorialAttendance: cardModel.tutorialAttendance, // Added tutorial
                    totalAttendance: cardModel.totalAttendance,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CourseDetailsPage(
                                subjectId: cardModel.subjectId,
                                courseName: cardModel.courseName,
                                ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}