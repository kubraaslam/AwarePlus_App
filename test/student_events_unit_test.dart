// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:aware_plus/views/events_view.dart';

void main() {
  testWidgets('Loads events from mock Firestore and displays them', (
    tester,
  ) async {
    // 1. Create fake Firestore
    final firestore = FakeFirebaseFirestore();

    // 2. Add a sample event
    await firestore.collection('events').add({
      'title': 'Test Event',
      'description': 'Event Description',
      'location': 'Test Location',
      'date': '2025-09-08',
      'time': '12:00',
    });

    // 3. Pump the widget with the fake Firestore
    await tester.pumpWidget(
      MaterialApp(home: StudentEventsPage(firestore: firestore)),
    );

    // Let initState and async calls complete
    await tester.pumpAndSettle();

    // 4. Tap the day on the calendar (September 8, 2025)
    final _ = DateTime(2025, 9, 8);
    await tester.tap(find.text('8')); // taps the day number in TableCalendar
    await tester.pumpAndSettle();

    // 5. Check that event is displayed correctly
    final titleFinder = find.text('Test Event');
    final descFinder = find.textContaining('Event Description');
    final locFinder = find.textContaining('Test Location');
    final timeFinder = find.textContaining('12:00');

    expect(titleFinder, findsOneWidget);
    expect(descFinder, findsOneWidget);
    expect(locFinder, findsOneWidget);
    expect(timeFinder, findsOneWidget);

    // Console test-case table output
    print('''
+-------------------------------+--------+
| Test Case                     | Result |
+-------------------------------+--------+
| Title of the event displayed  |  ${titleFinder.evaluate().isNotEmpty ? "PASS" : "FAIL"}  |
| Description shown             |  ${descFinder.evaluate().isNotEmpty ? "PASS" : "FAIL"}  |
| Location shown                |  ${locFinder.evaluate().isNotEmpty ? "PASS" : "FAIL"}  |
| Time shown                    |  ${timeFinder.evaluate().isNotEmpty ? "PASS" : "FAIL"}  |
+-------------------------------+--------+
''');
  });
}
