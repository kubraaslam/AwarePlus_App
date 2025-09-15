// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:aware_plus/views/events_view.dart';
import 'package:intl/intl.dart';

void main() {
  testWidgets('Displays events for 2025-09-24', (WidgetTester tester) async {
    // 1️⃣ Create fake Firestore
    final firestore = FakeFirebaseFirestore();

    // 2️⃣ Use the event date
    final eventDate = DateTime(2025, 9, 24);
    final formattedDate = DateFormat('yyyy-MM-dd').format(eventDate);

    // 3️⃣ Add the event
    await firestore.collection('events').add({
      'title': 'Test Event',
      'description': 'Test Description',
      'location': 'Test Location',
      'date': formattedDate,
      'time': '10:00',
    });

    // 4️⃣ Pump the widget
    await tester.pumpWidget(
      MaterialApp(home: StudentEventsPage(firestore: firestore)),
    );

    // 5️⃣ Wait for async calls
    await tester.pumpAndSettle();

    // 6️⃣ Initially shows "Select a date"
    final initialPrompt = find.text('Select a date to view events');
    expect(initialPrompt, findsOneWidget);

    // 7️⃣ Tap the day 24
    final dayKey = Key(
      'day-${eventDate.year}-${eventDate.month}-${eventDate.day}',
    );
    await tester.tap(find.byKey(dayKey));
    await tester.pumpAndSettle();

    // 8️⃣ Verify the event is displayed
    final titleFinder = find.text('Test Event');
    final descFinder = find.textContaining('Test Description');
    final locFinder = find.textContaining('Test Location');

    expect(titleFinder, findsOneWidget);
    expect(descFinder, findsOneWidget);
    expect(locFinder, findsOneWidget);

    // Console test-case table output
    print('''
+-----------------------------------+--------+
| Test Case                         | Result |
+-----------------------------------+--------+
| Initial "Select a date" prompt    |  ${initialPrompt.evaluate().isNotEmpty ? "PASS" : "FAIL"}  |
| Title of event displayed          |  ${titleFinder.evaluate().isNotEmpty ? "PASS" : "FAIL"}  |
| Description shown                 |  ${descFinder.evaluate().isNotEmpty ? "PASS" : "FAIL"}  |
| Location shown                    |  ${locFinder.evaluate().isNotEmpty ? "PASS" : "FAIL"}  |
+-----------------------------------+--------+
''');
  });
}
