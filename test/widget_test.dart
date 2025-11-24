import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pharmax/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PharmaXApp());

    // Verify that the app launches without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
