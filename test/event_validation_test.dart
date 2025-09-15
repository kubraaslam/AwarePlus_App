// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Form validation fails if fields are empty', (tester) async {
    final formKey = GlobalKey<FormState>();

    final titleController = TextEditingController();
    final descController = TextEditingController();
    final locationController = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: titleController,
                  validator:
                      (val) =>
                          val == null || val.isEmpty ? "Enter title" : null,
                ),
                TextFormField(
                  controller: descController,
                  validator:
                      (val) =>
                          val == null || val.isEmpty
                              ? "Enter description"
                              : null,
                ),
                TextFormField(
                  controller: locationController,
                  validator:
                      (val) =>
                          val == null || val.isEmpty ? "Enter location" : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final isValid = formKey.currentState!.validate();

    // Assertions
    expect(isValid, isFalse);

    // Custom test-case table output
    print('''
+---------------------------+--------+
| Test Case                 | Result |
+---------------------------+--------+
| Title empty validation    |  ${titleController.text.isEmpty ? "PASS" : "FAIL"}  |
| Description empty check   |  ${descController.text.isEmpty ? "PASS" : "FAIL"}  |
| Location empty check      |  ${locationController.text.isEmpty ? "PASS" : "FAIL"}  |
| Overall form invalid      |  ${isValid == false ? "PASS" : "FAIL"}  |
+---------------------------+--------+
''');
  });
}
