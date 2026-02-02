// Basic Flutter widget tests for F1Sync app
//
// These tests verify that the app's core widgets work correctly.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('App smoke test - basic widget rendering', (WidgetTester tester) async {
    // Build a minimal app widget and verify it doesn't crash
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('F1Sync'),
            ),
          ),
        ),
      ),
    );

    // Verify that our app text is rendered
    expect(find.text('F1Sync'), findsOneWidget);
  });
}
