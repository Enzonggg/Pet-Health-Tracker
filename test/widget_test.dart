// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('Phone frame test with login screen', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our phone simulator is rendered with login screen
    expect(find.text('Mobile Login'), findsOneWidget);

    // Test form fields are rendered
    expect(find.byType(TextFormField), findsAtLeast(2));
    expect(find.text('LOGIN'), findsOneWidget);
    expect(find.text('Don\'t have an account? Register here'), findsOneWidget);
  });
}
