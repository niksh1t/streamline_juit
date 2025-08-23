import 'package:flutter/material.dart';

/// Returns the appropriate color for an attendance percentage string.
///
/// Safely parses the string, returns the theme's `error` color for
/// percentages below 80, a green color for those at or above 80,
/// and a default color if the string is not a valid number.
Color getAttendanceColor(BuildContext context, {required String percentageString}) {
  final theme = Theme.of(context);

  // 1. Sanitize the string by removing the '%' sign and whitespace,
  //    then try to parse it into a double.
  final percentage = double.tryParse(percentageString.replaceAll('%', '').trim());

  // 2. If parsing fails (e.g., the string is "N/A"), return the default text color.
  if (percentage == null) {
    return theme.colorScheme.onSurface;
  }

  // 3. Apply the same color logic as before to the parsed number.
  if (percentage < 80) {
    return theme.colorScheme.error;
  } else {
    final isDarkMode = theme.brightness == Brightness.dark;
    return isDarkMode ? Colors.green.shade300 : Colors.green.shade700;
  }
}