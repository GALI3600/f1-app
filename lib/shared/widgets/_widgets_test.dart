// ignore_for_file: unused_import
/// Test file to verify all widgets compile correctly
/// This file should be removed before production

import 'package:flutter/material.dart';
import 'package:f1sync/shared/widgets/widgets.dart';
import 'package:f1sync/core/theme/f1_colors.dart';
import 'package:f1sync/core/theme/f1_gradients.dart';
import 'package:f1sync/core/theme/f1_text_styles.dart';

class WidgetsTestPage extends StatelessWidget {
  const WidgetsTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const F1AppBar(
        title: 'Widgets Test',
      ),
      backgroundColor: F1Colors.navyDeep,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // F1Card variants
            const F1Card(
              child: Text('Primary Card'),
            ),
            const SizedBox(height: 16),
            const F1Card.gradient(
              child: Text('Gradient Card'),
            ),
            const SizedBox(height: 16),
            const F1Card.elevated(
              child: Text('Elevated Card'),
            ),
            const SizedBox(height: 16),
            const F1Card.outlined(
              child: Text('Outlined Card'),
            ),
            const SizedBox(height: 16),

            // Loading widgets
            const LoadingWidget.card(),
            const SizedBox(height: 16),
            const LoadingWidget.listItem(),
            const SizedBox(height: 16),
            const LoadingWidget.circle(size: 64),
            const SizedBox(height: 16),

            // Error widgets
            F1ErrorWidget(
              title: 'Test Error',
              message: 'This is a test error',
              onRetry: () {},
            ),
            const SizedBox(height: 16),
            const F1ErrorWidget.network(),
            const SizedBox(height: 16),

            // Empty state widgets
            F1EmptyStateWidget(
              icon: Icons.inbox_outlined,
              title: 'No Data',
              message: 'Test empty state',
              onAction: () {},
            ),
            const SizedBox(height: 16),
            const F1EmptyStateWidget.noResults(),
            const SizedBox(height: 16),

            // Driver avatar
            const DriverAvatar(
              teamColor: '00D9FF',
              driverName: 'Max Verstappen',
            ),
            const SizedBox(height: 16),
            const DriverAvatar.small(
              teamColor: 'DC1E42',
              driverName: 'Lewis Hamilton',
            ),
            const SizedBox(height: 16),
            const DriverAvatar.medium(
              teamColor: '8B4FC9',
              driverName: 'Charles Leclerc',
            ),
            const SizedBox(height: 16),
            const DriverAvatar.large(
              teamColor: 'C9974D',
              driverName: 'Lando Norris',
            ),
            const SizedBox(height: 16),
            const DriverAvatarWithPosition(
              teamColor: '00D9FF',
              driverName: 'Max Verstappen',
              position: 1,
            ),
            const SizedBox(height: 16),

            // Live indicators
            const LiveIndicator(),
            const SizedBox(height: 16),
            const LiveIndicator.withLabel(),
            const SizedBox(height: 16),
            const LiveIndicator.large(),
            const SizedBox(height: 16),
            const LiveIndicatorBadge(),
            const SizedBox(height: 16),
            const SessionStatusIndicator(status: SessionStatus.live),
            const SizedBox(height: 16),
            const SessionStatusIndicator(status: SessionStatus.upcoming),
            const SizedBox(height: 16),

            // Team color strips
            SizedBox(
              height: 100,
              child: Row(
                children: [
                  const TeamColorStrip(teamColor: '00D9FF'),
                  const SizedBox(width: 16),
                  const TeamColorStrip.medium(teamColor: 'DC1E42'),
                  const SizedBox(width: 16),
                  const TeamColorStrip.thick(teamColor: '8B4FC9'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const HorizontalTeamColorStrip(teamColor: '00D9FF'),
            const SizedBox(height: 16),
            TeamColorCard(
              teamColor: '00D9FF',
              child: const Text('Team Color Card'),
              onTap: () {},
            ),
            const SizedBox(height: 16),
            const TeamColorDivider(teamColor: 'DC1E42'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
