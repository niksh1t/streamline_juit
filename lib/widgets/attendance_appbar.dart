import 'package:flutter/material.dart';

class AttendanceAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onCalculatePressed;

  const AttendanceAppBar({
    super.key,
    required this.onCalculatePressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Container(
        // Use a container to precisely control padding and color
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12), // Padding matches the visual style
        color: colorScheme.surface,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Title with the exact same text style
            Text(
              'Your Attendance',
              style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            // Action button
            InkWell(
    // 1. The action now goes in the onTap callback.
      onTap: onCalculatePressed, 
    // 2. Make the ripple effect circular to match the icon's shape.
      customBorder: CircleBorder(),
      child: Padding(
      // 3. Add padding to increase the tappable area around the icon.
        padding: const EdgeInsets.all(12.0), 
        child: Icon(
          Icons.calculate_outlined,
          color: colorScheme.onSurfaceVariant,
          size: 28,
        // The tooltip should be on the InkWell if needed, or removed.
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Set the preferred height for this custom AppBar
  @override
  Size get preferredSize => const Size.fromHeight(72);
}