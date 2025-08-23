import 'package:flutter/material.dart';
import '../utils/color_helper.dart';
class AttendanceCard extends StatelessWidget {
  final String courseName;
  final String courseType;
  final String lectureAttendance;
  final String practicalAttendance;
  final String tutorialAttendance;
  final String totalAttendance;
  final VoidCallback onTap;

  const AttendanceCard({
    super.key,
    required this.courseName,
    required this.courseType,
    required this.lectureAttendance,
    required this.practicalAttendance,
    required this.tutorialAttendance,
    required this.totalAttendance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> attendanceRows = [
      if (lectureAttendance.isNotEmpty)
        _buildAttendanceRow('Lecture:', lectureAttendance, context),
      if (practicalAttendance.isNotEmpty)
        _buildAttendanceRow('Practical:', practicalAttendance, context),
      if (tutorialAttendance.isNotEmpty)
        _buildAttendanceRow('Tutorial:', tutorialAttendance, context),
    ];

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.0),
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          // 1. Use a color with more contrast against the background.
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(20.0),
          // 2. Use a two-layer shadow for a softer, more modern lift.
          boxShadow: [
            // Softer, wider shadow for ambient effect
            BoxShadow(
              color: Colors.black.withOpacity(0.09),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
            // Sharper, closer shadow for edge definition
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              courseName,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w500),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            for (var i = 0; i < attendanceRows.length; i++) ...[
              attendanceRows[i],
              if (i < attendanceRows.length - 1) const SizedBox(height: 8),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                    ),
                    Text(
                      totalAttendance,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                            color: getAttendanceColor(context, percentageString: totalAttendance),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    courseType,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceRow(String label, String value, BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
