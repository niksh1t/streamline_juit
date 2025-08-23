import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../data/providers/schedule_provider.dart';
import '../data/models/schedule_item_model.dart';
import '../widgets/schedule_block.dart';
import '../widgets/week_view_appbar.dart';

// ✨ 1. Converted to a StatelessWidget
class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    // ✨ 2. Use a Consumer to get data and listen for changes
    return Consumer<ScheduleProvider>(
      builder: (context, provider, child) {
        // ✨ 3. All data now comes directly from the provider
        final schedule = provider.dailySchedule;

        return Scaffold(
          appBar: WeekViewAppBar(
            selectedDayIndex: provider.selectedDayIndex,
            weekDays: provider.weekDays,
            // ✨ 4. The callback now calls the provider's method
            onDaySelected: (index) {
              context.read<ScheduleProvider>().selectDay(index);
            },
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : schedule.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.event_busy_outlined, size: 60, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            'No classes scheduled for\n${DateFormat('EEEE, MMM d').format(provider.weekDays[provider.selectedDayIndex])}',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: schedule.length,
                      itemBuilder: (context, index) {
                        // ✨ 5. The item is now a strongly-typed ScheduleItem
                        final item = schedule[index];
                        return ScheduleBlock(
                          time: item.time,
                          course: item.course,
                          durationInHours: item.durationInHours,
                          batch: item.batch,
                          coordinator: item.coordinator,
                          venue: item.venue,
                          onTap: () {
                            _showClassDetailsBottomSheet(context, item);
                          },
                        );
                      },
                    ),
        );
      },
    );
  }

  // ✨ 6. Updated the method to accept a ScheduleItem object
  void _showClassDetailsBottomSheet(BuildContext context, ScheduleItem item) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Course Title
              Text(
                item.course,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Details now come from the item's properties
              _detailRow(Icons.location_on_outlined, 'Venue', item.venue, context),
              if (item.batch.isNotEmpty)
                _detailRow(Icons.group_outlined, 'Batch', item.batch, context),
              if (item.coordinator.isNotEmpty)
                _detailRow(Icons.person_outline, 'Coordinator', item.coordinator, context),
              // TODO: Fetch real attendance for this course
              _detailRow(Icons.bar_chart, 'Attendance', 'N/A', context), 

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(IconData icon, String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          Expanded( // Added Expanded to prevent overflow with long values
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}