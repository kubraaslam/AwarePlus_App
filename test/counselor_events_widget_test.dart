// ignore_for_file: avoid_print

import 'package:aware_plus/views/create_events_view.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

void main() {
  testWidgets('Opens event modal and validates inputs', (tester) async {
    final mockUser = MockUser(
      isAnonymous: false,
      uid: 'testUser',
      email: 'test@example.com',
    );
    final auth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
    final firestore = FakeFirebaseFirestore();

    await tester.pumpWidget(
      MaterialApp(
        home: CounselorEventsPage(
          auth: auth,
          firestore: firestore,
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('createEventButton')));
    await tester.pump();

    final titleError = find.text("Enter title");
    final descError = find.text("Enter description");
    final locError = find.text("Enter location");

    // Assertions
    expect(titleError, findsOneWidget);
    expect(descError, findsOneWidget);
    expect(locError, findsOneWidget);

    // Custom test-case table style output
    print('''
+-------------------------+--------+
| Test Case               | Result |
+-------------------------+--------+
| Title validation shown  |  ${titleError.evaluate().isNotEmpty ? "PASS" : "FAIL"}  |
| Desc validation shown   |  ${descError.evaluate().isNotEmpty ? "PASS" : "FAIL"}  |
| Location validation     |  ${locError.evaluate().isNotEmpty ? "PASS" : "FAIL"}  |
+-------------------------+--------+
''');
  });
}