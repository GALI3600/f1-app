import 'package:f1sync/core/theme/f1_colors.dart';
import 'package:f1sync/features/sessions/data/models/session.dart';
import 'package:f1sync/shared/widgets/live_indicator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Session Schedule List Widget
/// Displays sessions with:
/// - Name, date/time, type icon
/// - Status: Upcoming, Live, Completed
/// - Tap → Session detail
class SessionScheduleList extends StatelessWidget {
  final List<Session> sessions;
  final Function(Session)? onSessionTap;

  const SessionScheduleList({
    super.key,
    required this.sessions,
    this.onSessionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'No sessions scheduled',
            style: TextStyle(
              color: F1Colors.textSecondary,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: sessions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final session = sessions[index];
        return SessionListItem(
          session: session,
          onTap: onSessionTap != null ? () => onSessionTap!(session) : null,
        );
      },
    );
  }
}

/// Individual session list item
class SessionListItem extends StatelessWidget {
  final Session session;
  final VoidCallback? onTap;

  const SessionListItem({
    super.key,
    required this.session,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = _getSessionStatus(session);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Session Type Icon
              _buildSessionIcon(session.sessionType, status),

              const SizedBox(width: 16),

              // Session Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Session Name with Live Indicator
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            session.sessionName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: F1Colors.textPrimary,
                            ),
                          ),
                        ),
                        if (status == SessionStatus.live) ...[
                          const SizedBox(width: 8),
                          const LiveIndicator(),
                          const SizedBox(width: 8),
                          const Text(
                            'LIVE',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: F1Colors.vermelho,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Date and Time
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: _getStatusColor(status),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatSessionTime(session.dateStart, session.dateEnd),
                          style: TextStyle(
                            fontSize: 14,
                            color: _getStatusColor(status),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Status Text
                    Text(
                      _getStatusText(status, session.dateStart),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getStatusColor(status),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Status Badge
              _buildStatusBadge(status),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionIcon(String sessionType, SessionStatus status) {
    IconData icon;
    Color color;

    switch (sessionType.toLowerCase()) {
      case 'practice':
        icon = Icons.settings;
        color = F1Colors.ciano;
        break;
      case 'qualifying':
        icon = Icons.flag;
        color = F1Colors.dourado;
        break;
      case 'race':
        icon = Icons.emoji_events;
        color = F1Colors.vermelho;
        break;
      default:
        icon = Icons.event;
        color = F1Colors.textSecondary;
    }

    // Dim icon if session is completed
    if (status == SessionStatus.completed) {
      color = color.withValues(alpha: 0.5);
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: color,
        size: 24,
      ),
    );
  }

  Widget _buildStatusBadge(SessionStatus status) {
    if (status == SessionStatus.upcoming) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: F1Colors.ciano.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Upcoming',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: F1Colors.ciano,
          ),
        ),
      );
    }

    if (status == SessionStatus.completed) {
      return const Icon(
        Icons.check_circle,
        color: F1Colors.success,
        size: 24,
      );
    }

    return const SizedBox.shrink();
  }

  SessionStatus _getSessionStatus(Session session) {
    final now = DateTime.now();

    if (now.isAfter(session.dateEnd)) {
      return SessionStatus.completed;
    }

    if (now.isAfter(session.dateStart) && now.isBefore(session.dateEnd)) {
      return SessionStatus.live;
    }

    return SessionStatus.upcoming;
  }

  Color _getStatusColor(SessionStatus status) {
    switch (status) {
      case SessionStatus.live:
        return F1Colors.vermelho;
      case SessionStatus.upcoming:
        return F1Colors.ciano;
      case SessionStatus.completed:
        return F1Colors.textSecondary;
    }
  }

  String _getStatusText(SessionStatus status, DateTime startTime) {
    switch (status) {
      case SessionStatus.live:
        return 'In Progress';
      case SessionStatus.upcoming:
        final timeUntil = startTime.difference(DateTime.now());
        return _formatTimeUntil(timeUntil);
      case SessionStatus.completed:
        return 'Completed';
    }
  }

  String _formatSessionTime(DateTime start, DateTime end) {
    final dateFormat = DateFormat('EEE, MMM dd • HH:mm');
    return dateFormat.format(start);
  }

  String _formatTimeUntil(Duration duration) {
    if (duration.inDays > 0) {
      return 'In ${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return 'In ${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return 'In ${duration.inMinutes}m';
    } else {
      return 'Starting soon';
    }
  }
}

/// Session status enum
enum SessionStatus {
  upcoming,
  live,
  completed,
}
