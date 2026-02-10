import 'package:f1sync/core/theme/f1_colors.dart';
import 'package:f1sync/core/theme/f1_text_styles.dart';
import 'package:f1sync/features/sessions/data/models/session.dart';
import 'package:f1sync/shared/widgets/live_indicator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Session Schedule List Widget
/// Displays sessions with:
/// - Type-specific icon & accent color
/// - Name, date/time, status
/// - Vermelho accent strip
/// - Status badges: Upcoming, Live, Completed
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
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'No sessions scheduled',
            style: F1TextStyles.bodyMedium.copyWith(
              color: F1Colors.textSecondary,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: sessions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
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
    final accentColor = _getSessionAccentColor(session.sessionType);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: F1Colors.navy,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: F1Colors.border, width: 1),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Accent strip (color by session type)
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      bottomLeft: Radius.circular(14),
                    ),
                  ),
                ),

                // Main content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 14, 14, 14),
                    child: Row(
                      children: [
                        // Session type icon
                        _buildSessionIcon(session.sessionType, status, accentColor),

                        const SizedBox(width: 14),

                        // Session info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Session name + live indicator
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      session.sessionName,
                                      style: F1TextStyles.headlineSmall.copyWith(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                  if (status == SessionStatus.live) ...[
                                    const SizedBox(width: 8),
                                    const LiveIndicator(),
                                  ],
                                ],
                              ),

                              const SizedBox(height: 6),

                              // Date + time
                              Row(
                                children: [
                                  Icon(
                                    Icons.schedule_rounded,
                                    size: 13,
                                    color: F1Colors.textTertiary,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      _formatSessionTime(session.dateStart),
                                      style: F1TextStyles.bodySmall.copyWith(
                                        color: F1Colors.textTertiary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Right side: status badge + chevron
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildStatusBadge(status, session.dateStart),
                            const SizedBox(height: 6),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: F1Colors.textTertiary,
                              size: 20,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionIcon(String sessionType, SessionStatus status, Color accentColor) {
    IconData icon;

    switch (sessionType.toLowerCase()) {
      case 'practice':
        icon = Icons.build_rounded;
        break;
      case 'qualifying':
      case 'sprint qualifying':
        icon = Icons.timer_rounded;
        break;
      case 'sprint':
        icon = Icons.bolt_rounded;
        break;
      case 'race':
        icon = Icons.emoji_events_rounded;
        break;
      default:
        icon = Icons.event_rounded;
    }

    final effectiveColor = status == SessionStatus.completed
        ? accentColor.withValues(alpha: 0.5)
        : accentColor;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: effectiveColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Icon(
        icon,
        color: effectiveColor,
        size: 22,
      ),
    );
  }

  Widget _buildStatusBadge(SessionStatus status, DateTime startTime) {
    switch (status) {
      case SessionStatus.live:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: F1Colors.vermelho.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: F1Colors.vermelho.withValues(alpha: 0.4),
              width: 0.5,
            ),
          ),
          child: Text(
            'LIVE',
            style: F1TextStyles.labelSmall.copyWith(
              color: F1Colors.vermelho,
              fontWeight: FontWeight.w800,
              fontSize: 10,
              letterSpacing: 0.8,
            ),
          ),
        );

      case SessionStatus.completed:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: F1Colors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_rounded, size: 12, color: F1Colors.success),
              const SizedBox(width: 3),
              Text(
                'Done',
                style: F1TextStyles.labelSmall.copyWith(
                  color: F1Colors.success,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        );

      case SessionStatus.upcoming:
        final timeUntil = startTime.difference(DateTime.now());
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: F1Colors.navyLight.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            _formatTimeUntil(timeUntil),
            style: F1TextStyles.labelSmall.copyWith(
              color: F1Colors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        );
    }
  }

  Color _getSessionAccentColor(String sessionType) {
    switch (sessionType.toLowerCase()) {
      case 'practice':
        return F1Colors.textSecondary;
      case 'qualifying':
      case 'sprint qualifying':
        return F1Colors.dourado;
      case 'sprint':
        return F1Colors.roxo;
      case 'race':
        return F1Colors.vermelho;
      default:
        return F1Colors.textSecondary;
    }
  }

  SessionStatus _getSessionStatus(Session session) {
    final now = DateTime.now();
    if (now.isAfter(session.dateEnd)) return SessionStatus.completed;
    if (now.isAfter(session.dateStart) && now.isBefore(session.dateEnd)) {
      return SessionStatus.live;
    }
    return SessionStatus.upcoming;
  }

  String _formatSessionTime(DateTime start) {
    return DateFormat('EEE, dd MMM • HH:mm').format(start);
  }

  String _formatTimeUntil(Duration duration) {
    if (duration.isNegative) return 'Starting soon';
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
