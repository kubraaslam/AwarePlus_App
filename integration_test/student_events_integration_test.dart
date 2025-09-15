import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aware_plus/main.dart' as app; // main entrypoint
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Full student events flow', (WidgetTester tester) async {
    app.main(); // launches app
    await tester.pumpAndSettle();

    // Navigate to StudentEventsPage (assume button exists)
    final eventsButton = find.text('Student Events');
    await tester.tap(eventsButton);
    await tester.pumpAndSettle();

    // Verify calendar is visible
    expect(find.byType(CalendarDatePicker), findsWidgets);

    // Select today's date
    final today = DateTime.now();
    await tester.tap(find.text(today.day.toString()));
    await tester.pumpAndSettle();

    // Verify that events load
    expect(find.textContaining('Location:'), findsWidgets);

    // Scroll and verify at least one event card
    expect(find.byType(Card), findsWidgets);
  });
}