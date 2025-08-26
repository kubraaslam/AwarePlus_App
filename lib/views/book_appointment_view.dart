// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookAppointmentPage extends StatefulWidget {
  final String? appointmentId; // document ID if rescheduling

  const BookAppointmentPage({super.key, this.appointmentId});

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  late TextEditingController dateController;
  late TextEditingController timeController;
  late TextEditingController infoController;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    dateController = TextEditingController();
    timeController = TextEditingController();
    infoController = TextEditingController();

    if (widget.appointmentId != null) {
      _loadAppointmentData();
    } else {
      isLoading = false;
    }
  }

  Future<void> _loadAppointmentData() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('appointments')
            .doc(widget.appointmentId)
            .get();

    if (doc.exists) {
      final data = doc.data()!;
      dateController.text = data['appointmentDate'] ?? '';
      timeController.text = data['appointmentTime'] ?? '';
      infoController.text = data['additionalInfo'] ?? '';
    }

    setState(() {
      isLoading = false;
    });
  }

  DateTime? _selectedDate;
  String? _selectedTime;
  String? _selectedType;
  final TextEditingController _additionalInfoController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<String> generateTimeSlots() {
    List<String> slots = [];
    DateTime start = DateTime(0, 0, 0, 8, 30);
    DateTime end = DateTime(0, 0, 0, 16, 30);

    while (start.isBefore(end)) {
      slots.add(DateFormat.jm().format(start)); // "8:30 AM"
      start = start.add(const Duration(hours: 1));
    }
    return slots;
  }

  Future<void> _bookAppointment() async {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedTime != null) {
      final user = FirebaseAuth.instance.currentUser;

      final data = {
        'studentId': user!.uid,
        'studentName': user.displayName ?? user.email,
        'appointmentDate': DateFormat('yyyy-MM-dd').format(_selectedDate!),
        'appointmentTime': _selectedTime,
        'appointmentType': _selectedType,
        'additionalInfo': _additionalInfoController.text.trim(),
        'status': 'pending', // reset status when rescheduling
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (widget.appointmentId != null) {
        // Update existing appointment
        await FirebaseFirestore.instance
            .collection('appointments')
            .doc(widget.appointmentId)
            .update(data);
      } else {
        // Create a new appointment
        await FirebaseFirestore.instance.collection('appointments').add({
          ...data,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.appointmentId != null
                ? 'Appointment rescheduled successfully!'
                : 'Appointment booked successfully!',
          ),
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final slots = generateTimeSlots();
    final appointmentTypes = [
      "Counseling",
      "Education Session",
      "Follow-up",
      "Other",
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Book Appointment", style: TextStyle(fontSize: 20)),
        backgroundColor: const Color(0xFFC9184A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: const Text(
                        "Appointment Information",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      content: const SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Contact Information",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text("Student Support Services:\nSSS@apiit.lk"),
                            SizedBox(height: 8),
                            Text("Office Hours:\nMon-Fri 8:30 AM - 5:30 PM"),
                            SizedBox(height: 16),
                            Text(
                              "What to Expect",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "• Non-judgmental counseling in a safe environment",
                            ),
                            Text("• Evidence-based sexual health education"),
                            Text(
                              "• Confidential support for sexual health concerns",
                            ),
                            Text(
                              "• Referrals to specialized healthcare when needed",
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          child: const Text(
                            "Close",
                            style: TextStyle(color: Color(0xFFC9184A)),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Book Your Confidential Appointment",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "All conversations are strictly confidential. Your privacy is our top priority.",
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Date Picker
                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Colors.black54),
                      ),
                      title: Text(
                        _selectedDate == null
                            ? "Pick Date"
                            : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                        style: const TextStyle(fontSize: 16),
                      ),
                      trailing: const Icon(
                        Icons.calendar_today,
                        color: Color(0xFFC9184A),
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() => _selectedDate = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Time Slot Dropdown
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: "Select Time Slot",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items:
                          slots.map((slot) {
                            return DropdownMenuItem(
                              value: slot,
                              child: Text(slot),
                            );
                          }).toList(),
                      onChanged: (val) => setState(() => _selectedTime = val),
                      validator:
                          (val) =>
                              val == null ? "Please select a time slot" : null,
                    ),
                    const SizedBox(height: 16),

                    // Appointment Type Dropdown
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: "Appointment Type",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items:
                          appointmentTypes.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                      onChanged: (val) => setState(() => _selectedType = val),
                      validator:
                          (val) =>
                              val == null
                                  ? "Please select appointment type"
                                  : null,
                    ),
                    const SizedBox(height: 16),

                    // Additional Info (Optional)
                    TextFormField(
                      controller: _additionalInfoController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: "Additional Information (Optional)",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _bookAppointment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF758F),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: const Text(
                        "Book Appointment",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
