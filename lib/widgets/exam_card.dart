import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/models/exam_model.dart'; // Ensure this path is correct

class ExamCard extends StatelessWidget {
  final Exam exam;

  const ExamCard({super.key, required this.exam});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      // Clip the inner content to the card's rounded corners
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- 1. NEW DATE HEADER ROW ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              color: theme.colorScheme.surface, // A slightly different background for the header
              child: Text(
                DateFormat('EE, MMM d').format(exam.date), // e.g., Friday, August 22, 2025
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            // --- 2. THE REST OF THE CARD CONTENT ---
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTimeSection(theme),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildDetailsSection(theme),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSection(ThemeData theme) {
    final startTimeString = exam.timeSlot.split(' to ')[0];
    final timeParts = startTimeString.split(' ');
    final time = timeParts.isNotEmpty ? timeParts[0] : '--:--';
    final period = timeParts.length > 1 ? timeParts[1].toUpperCase() : '??';

    return Container(
      width: 90,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            time,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            period,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  // --- 3. UPDATED DETAILS SECTION ---
  Widget _buildDetailsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            exam.subjectCode,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onTertiaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          exam.subjectName,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),
        // Date has been removed from here
        _buildInfoRow(
          theme,
          icon: Icons.schedule_outlined,
          text: exam.timeSlot,
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          theme,
          icon: Icons.location_on_outlined,
          text: 'Room: ${exam.roomCode ?? 'N/A'}',
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          theme,
          icon: Icons.chair_outlined,
          text: 'Seat: ${exam.seatNumber ?? 'N/A'}',
        ),
      ],
    );
  }

  Widget _buildInfoRow(ThemeData theme,
      {required IconData icon, required String text}) {
    // This helper method remains unchanged
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}