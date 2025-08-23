import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeekViewAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int selectedDayIndex;
  final List<DateTime> weekDays;
  final Function(int) onDaySelected;

  const WeekViewAppBar({
    super.key,
    required this.selectedDayIndex,
    required this.weekDays,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        color: colorScheme.surface, // AppBar background color
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Schedule',
                  style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                //Icon(Icons.calendar_today_outlined, color: colorScheme.onSurfaceVariant),
              ],
            ),
            const SizedBox(height: 12),
            // Day Toggles
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final day = weekDays[index];
                final isSelected = index == selectedDayIndex;

                return GestureDetector(
                  onTap: () => onDaySelected(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? colorScheme.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        Text(
                          DateFormat('E').format(day), // "Mon", "Tue"
                          style: textTheme.bodySmall?.copyWith(
                            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('d').format(day), // "15", "16"
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(130);
}