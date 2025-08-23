import 'package:flutter/material.dart';

class ScheduleBlock extends StatelessWidget {
  final String time;
  final String course;
  final int durationInHours;
  final String batch;
  final String coordinator;
  final String venue;
  final VoidCallback onTap;

  const ScheduleBlock({
    super.key,
    required this.time,
    required this.course,
    required this.durationInHours,
    required this.batch,
    required this.coordinator,
    required this.venue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isFreeSlot = course == 'Free Slot';
    final height = 120.0 * durationInHours + (durationInHours - 1) ;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time Column
            SizedBox(
              width: 70,
              child: Text(
                time,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                    ),
              ),
            ),
            // Event Card Column
            Expanded(
              child: Container(
                height: height,
                padding: const EdgeInsets.all(16.0),
                decoration: isFreeSlot
                    // Style for 'Free Slot' remains minimal and distinct.
                    ? BoxDecoration(
                        color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.1)),
                      )
                    // Style for regular schedule blocks with new effects.
                    : BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          // Softer, wider shadow for ambient effect
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                          // Sharper, closer shadow for edge definition
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                child: isFreeSlot
                    ? Center(
                        child: Text(
                          'Free Slot',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.5),
                                    fontStyle: FontStyle.italic,
                                  ),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Course Name
                          Text(
                            course,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          // Coordinator
                          if (coordinator.isNotEmpty)
                            _buildInfoRow(
                                Icons.person_outline, coordinator, context),
                          // Batch and Venue
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (batch.isNotEmpty)
                                _buildInfoRow(
                                    Icons.group_outlined, batch, context),
                              if (venue.isNotEmpty)
                                _buildInfoRow(Icons.location_on_outlined,
                                    venue, context),
                            ],
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon,
            size: 14,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
        const SizedBox(width: 6),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
        ),
      ],
    );
  }
}
