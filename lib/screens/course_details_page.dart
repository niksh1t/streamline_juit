import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/models/attendance_details_model.dart';
import '../data/providers/course_details_provider.dart';

class CourseDetailsPage extends StatefulWidget {
  // ✨ FIX 1: The page now accepts the subject's ID and its display name.
  final String subjectId;
  final String courseName;

  const CourseDetailsPage({
    super.key,
    required this.subjectId,
    required this.courseName, // You must pass this from the previous screen.
  });

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ✨ FIX 2: Call the provider with the subjectId string.
      Provider.of<CourseDetailsProvider>(context, listen: false)
          .fetchDetailsForCourse(widget.subjectId);
    });
  }

  @override
  void dispose() {
    // Clean up the provider's state when the page is closed.
    WidgetsBinding.instance.addPostFrameCallback((_) {
       if (mounted) {
        Provider.of<CourseDetailsProvider>(context, listen: false).clearDetails();
       }
    });
    super.dispose();
  }

  // Helper to format the course name for the title
  String _formatCourseName(String rawName) {
    int parenIndex = rawName.indexOf('(');
    String namePart = (parenIndex != -1 ? rawName.substring(0, parenIndex) : rawName).trim();
    return namePart.split(' ').map((word) {
      if (word.isEmpty) return '';
      if (word.length <= 1) return word.toUpperCase();
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // ✨ FIX 3: Use the courseName passed to the widget for an immediate, clean title.
        title: Text(_formatCourseName(widget.courseName),
        ),
      ),
      body: Consumer<CourseDetailsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  provider.errorMessage!,
                  textAlign: TextAlign.center,
                  ),
              ),
            );
          }
          // The rest of the logic correctly uses 'provider.attendanceLogs'.
          if (provider.attendanceLogs.isEmpty) {
            return const Center(child: Text("No attendance log found."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20.0),
            itemCount: provider.attendanceLogs.length,
            itemBuilder: (context, index) {
              final log = provider.attendanceLogs[index];
              return _AttendanceTimelineTile(
                log: log,
                serialNumber: index + 1,
                isFirst: index == 0,
                isLast: index == provider.attendanceLogs.length - 1,
              );
            },
          );
        },
      ),
    );
  }
}

// No changes are needed for the _AttendanceTimelineTile widget.
class _AttendanceTimelineTile extends StatelessWidget {
  final AttendanceLog log;
  final int serialNumber;
  final bool isFirst;
  final bool isLast;

  const _AttendanceTimelineTile({
    required this.log,
    required this.serialNumber,
    required this.isFirst,
    required this.isLast,
  });
  
  // ... The rest of the widget code remains the same
  @override
  Widget build(BuildContext context) {
    final bool isPresent = log.status == 'Present';
    final statusColor = isPresent ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
    final statusIcon = isPresent ? Icons.check_circle_outline : Icons.highlight_off_outlined;

    final String date = log.dateTime.substring(0, 10);
    final String time = log.dateTime.substring(12, log.dateTime.length - 1);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTimelineColumn(context, serialNumber),
          const SizedBox(width: 20),
          Expanded(
            child: _buildContentCard(context, date, time, statusColor, statusIcon),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineColumn(BuildContext context, int sno) {
    return Column(
      children: [
        Expanded(child: Container(width: 2, color: isFirst ? Colors.transparent : Theme.of(context).colorScheme.outline.withOpacity(0.3))),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            border: Border.all(color: Theme.of(context).colorScheme.primary),
          ),
          child: Center(child: Text(sno.toString(), style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary))),
        ),
        Expanded(child: Container(width: 2, color: isLast ? Colors.transparent : Theme.of(context).colorScheme.outline.withOpacity(0.3))),
      ],
    );
  }

  Widget _buildContentCard(BuildContext context, String date, String time, Color statusColor, IconData statusIcon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(date, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const Spacer(),
              Text(time, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          Text('Marked by: ${log.attendanceBy}', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text('Class Type: ${log.classType}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20.0)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(statusIcon, color: statusColor, size: 16),
                  const SizedBox(width: 6),
                  Text(log.status, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: statusColor, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}