// integration_test/counselor_events_integration_test.dart
import 'package:aware_plus/views/create_events_view.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('CounselorEventsPage Integration Test', () {
    late MockFirebaseAuth auth;
    late FakeFirebaseFirestore firestore;

    setUp(() {
      auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'test_user', email: 'test@example.com'),
      );
      firestore =
          FakeFirebaseFirestore(); // use same instance for all operations
    });

    testWidgets('Create, edit, and delete event flow', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CounselorEventsPage(
            auth: auth,
            firestore: firestore,
            testSelectedDate: DateTime(2025, 9, 15),
            testSelectedTime: const TimeOfDay(hour: 10, minute: 30),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initially no events
      expect(find.text("No events yet."), findsOneWidget);

      // 1. Tap FAB → open modal
      await tester.tap(find.byKey(const Key('fabCreateEventButton')));
      await tester.pumpAndSettle();

      // 2. Fill text fields
      await tester.enterText(
        find.byKey(const Key('eventTitleField')),
        "Test Event",
      );
      await tester.enterText(
        find.byKey(const Key('eventDescriptionField')),
        "Desc",
      );
      await tester.enterText(
        find.byKey(const Key('eventLocationField')),
        "Zoom",
      );

      // 3. Submit form
      await tester.tap(find.byKey(const Key('modalCreateEventButton')));
      await tester.pumpAndSettle();

      // Wait for Firestore to emit the new event
      await tester.pump(const Duration(seconds: 1));

      // Get event ID from Firestore
      final eventsSnapshot = await firestore.collection('events').get();
      final eventDoc = eventsSnapshot.docs.first;
      expect(eventDoc, isNotNull, reason: 'Event should exist in Firestore');

      // Check event is displayed
      expect(find.text("Test Event"), findsOneWidget);

      // Edit event
      await tester.tap(find.byKey(Key('editButton_${eventDoc.id}')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('eventTitleField')),
        "Updated Event",
      );
      await tester.tap(find.byKey(const Key('modalCreateEventButton')));
      await tester.pumpAndSettle();

      // Wait for Firestore stream
      await tester.pump(const Duration(seconds: 1));
      expect(find.text("Updated Event"), findsOneWidget);

      // Delete event
      await tester.tap(find.byKey(Key('deleteButton_${eventDoc.id}')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirmDeleteButton')));
      await tester.pumpAndSettle();

      await tester.pump(const Duration(seconds: 1));

      expect(find.text("No events yet."), findsOneWidget);
    });
  });
}
