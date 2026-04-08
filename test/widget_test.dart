 import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rma_app/main.dart';

void main() {
  testWidgets('Login screen loads and can be submitted', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our login screen is shown.
    expect(find.text('Login'), findsAtLeast(1));
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsOneWidget);

    // Enter email and password.
    await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');

    // Tap the login button and trigger a frame.
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Verify that the login processing snackbar is shown.
    expect(find.text('Processing Login'), findsOneWidget);
  });
}
