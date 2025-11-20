import 'package:flutter/material.dart';
import '../../../race_control/data/models/race_control.dart';
import '../../../drivers/data/models/driver.dart';
import '../../../../core/theme/f1_colors.dart';

/// Feed of race control messages displayed chronologically
class RaceControlFeed extends StatefulWidget {
  final List<RaceControl> messages;
  final List<Driver>? drivers;
  final RaceControlFilter filter;
  final ValueChanged<RaceControlFilter>? onFilterChanged;

  const RaceControlFeed({
    super.key,
    required this.messages,
    this.drivers,
    this.filter = RaceControlFilter.all,
    this.onFilterChanged,
  });

  @override
  State<RaceControlFeed> createState() => _RaceControlFeedState();
}

class _RaceControlFeedState extends State<RaceControlFeed> {
  @override
  Widget build(BuildContext context) {
    // Filter messages based on selected filter
    final filteredMessages = _filterMessages(widget.messages);

    // Sort by date (newest first)
    filteredMessages.sort((a, b) => b.date.compareTo(a.date));

    return Column(
      children: [
        // Filter chips
        if (widget.onFilterChanged != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: RaceControlFilter.values.map((filter) {
                  final isSelected = filter == widget.filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter.label),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          widget.onFilterChanged?.call(filter);
                        }
                      },
                      selectedColor: F1Colors.ciano.withOpacity(0.3),
                      checkmarkColor: F1Colors.ciano,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        // Messages list
        Expanded(
          child: filteredMessages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.message_outlined,
                        size: 48,
                        color: F1Colors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No messages',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: F1Colors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredMessages.length,
                  itemBuilder: (context, index) {
                    final message = filteredMessages[index];
                    final driver = widget.drivers?.firstWhere(
                      (d) => d.driverNumber == message.driverNumber,
                      orElse: () => null as Driver,
                    );

                    return _RaceControlMessageCard(
                      message: message,
                      driver: driver,
                    );
                  },
                ),
        ),
      ],
    );
  }

  List<RaceControl> _filterMessages(List<RaceControl> messages) {
    switch (widget.filter) {
      case RaceControlFilter.all:
        return messages;
      case RaceControlFilter.flags:
        return messages.where((m) => m.category == 'Flag').toList();
      case RaceControlFilter.penalties:
        return messages
            .where((m) =>
                m.category == 'CarEvent' && m.message.contains('PENALTY'))
            .toList();
      case RaceControlFilter.drs:
        return messages
            .where((m) => m.message.contains('DRS'))
            .toList();
    }
  }
}

/// Individual race control message card
class _RaceControlMessageCard extends StatelessWidget {
  final RaceControl message;
  final Driver? driver;

  const _RaceControlMessageCard({
    required this.message,
    this.driver,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Flag/Category icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getCategoryColor().withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getCategoryIcon(),
                color: _getCategoryColor(),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            // Message content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Category badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getCategoryColor().withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: _getCategoryColor()),
                        ),
                        child: Text(
                          message.category.toUpperCase(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: _getCategoryColor(),
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Flag badge (if applicable)
                      if (message.flag != null) _buildFlagBadge(context),
                      const Spacer(),
                      // Timestamp
                      Text(
                        _formatTime(message.date),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: F1Colors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Message text
                  Text(
                    message.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  // Driver info and lap number
                  if (driver != null || message.lapNumber != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (driver != null) ...[
                          Text(
                            driver!.nameAcronym,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: F1Colors.ciano,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(#${driver!.driverNumber})',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: F1Colors.textSecondary,
                                ),
                          ),
                        ],
                        if (driver != null && message.lapNumber != null)
                          const SizedBox(width: 8),
                        if (message.lapNumber != null)
                          Text(
                            'Lap ${message.lapNumber}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: F1Colors.textSecondary,
                                ),
                          ),
                        if (message.sector != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            'Sector ${message.sector}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: F1Colors.textSecondary,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlagBadge(BuildContext context) {
    final flagColor = _getFlagColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: flagColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: flagColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.flag,
            size: 12,
            color: flagColor,
          ),
          const SizedBox(width: 4),
          Text(
            message.flag!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: flagColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor() {
    switch (message.category) {
      case 'Flag':
        return _getFlagColor();
      case 'SafetyCar':
        return F1Colors.warning;
      case 'CarEvent':
        return F1Colors.vermelho;
      case 'Drs':
        return F1Colors.ciano;
      default:
        return F1Colors.textSecondary;
    }
  }

  Color _getFlagColor() {
    switch (message.flag?.toUpperCase()) {
      case 'GREEN':
        return F1Colors.success;
      case 'YELLOW':
        return F1Colors.warning;
      case 'RED':
        return F1Colors.error;
      case 'BLUE':
        return Colors.blue;
      case 'BLACK':
        return Colors.white;
      default:
        return F1Colors.textSecondary;
    }
  }

  IconData _getCategoryIcon() {
    switch (message.category) {
      case 'Flag':
        return Icons.flag;
      case 'SafetyCar':
        return Icons.car_rental;
      case 'CarEvent':
        return Icons.warning;
      case 'Drs':
        return Icons.flight;
      default:
        return Icons.info;
    }
  }

  String _formatTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}

/// Filter options for race control messages
enum RaceControlFilter {
  all,
  flags,
  penalties,
  drs;

  String get label {
    switch (this) {
      case RaceControlFilter.all:
        return 'All';
      case RaceControlFilter.flags:
        return 'Flags';
      case RaceControlFilter.penalties:
        return 'Penalties';
      case RaceControlFilter.drs:
        return 'DRS';
    }
  }
}
