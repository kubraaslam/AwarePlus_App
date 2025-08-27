// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookAppointmentPage extends StatefulWidget {
  final String? appointmentId; // for rescheduling
  final String counselorId; // required to check availability

  const BookAppointmentPage({
    super.key,
    this.appointmentId,
    required this.counselorId,
  });

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _additionalInfoController =
      TextEditingController();

  // Appointment fields
  DateTime? _selectedDate;
  String? _selectedTime;
  String? _selectedType;

  // Slots based on availability
  List<String> availableSlots = [];

  // Availability map (should be loaded from Firestore "availability" collection)
  Map<String, Map<String, dynamic>> availability = {};

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAvailability().then((_) {
      if (widget.appointmentId != null) {
        _loadAppointmentData();
      } else {
        setState(() => isLoading = false);
      }
    });
  }

  // Load counselor availability
  Future<void> _loadAvailability() async {
    try {
      final doc =
          await _firestore
              .collection('availability')
              .doc(widget.counselorId)
              .get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data.containsKey('week')) {
          final weekData = data['week'] as Map<String, dynamic>;
          availability = weekData.map((key, value) {
            final dayMap = Map<String, dynamic>.from(value);
            dayMap['start'] = dayMap['start'].toString();
            dayMap['end'] = dayMap['end'].toString();
            dayMap['breaks'] =
                (dayMap['breaks'] as List<dynamic>?)
                    ?.map(
                      (b) => {
                        'start': b['start'].toString(),
                        'end': b['end'].toString(),
                      },
                    )
                    .toList() ??
                [];
            return MapEntry(key, dayMap);
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading availability: $e');
    }
  }

  // Load existing appointment data (for rescheduling)
  Future<void> _loadAppointmentData() async {
    final doc =
        await _firestore
            .collection('appointments')
            .doc(widget.appointmentId)
            .get();
    if (doc.exists) {
      final data = doc.data()!;
      _selectedDate = DateTime.tryParse(data['appointmentDate'] ?? '');
      _selectedTime = data['appointmentTime'];
      _selectedType = data['appointmentType'];
      _additionalInfoController.text = data['additionalInfo'] ?? '';
      if (_selectedDate != null) {
        _generateAvailableSlots(_selectedDate!).then((slots) {
          setState(() {
            availableSlots = slots;
          });
        });
      }
    }
    setState(() => isLoading = false);
  }

  // Generate available slots based on counselor availability and booked appointments
  Future<List<String>> _generateAvailableSlots(DateTime date) async {
    final weekday = DateFormat('EEEE').format(date); // e.g., "Monday"
    final dayAvailability = availability[weekday];

    if (dayAvailability == null || !(dayAvailability['available'] as bool)) {
      return [];
    }

    // Parse start/end times
    final startParts = (dayAvailability['start'] as String).split(':');
    final endParts = (dayAvailability['end'] as String).split(':');

    DateTime start = DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(startParts[0]),
      int.parse(startParts[1]),
    );
    DateTime end = DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(endParts[0]),
      int.parse(endParts[1]),
    );

    // Get already booked appointments
    final bookedDocs =
        await _firestore
            .collection('appointments')
            .where('counselorId', isEqualTo: widget.counselorId)
            .where(
              'appointmentDate',
              isEqualTo: DateFormat('yyyy-MM-dd').format(date),
            )
            .get();
    final bookedTimes =
        bookedDocs.docs.map((d) => d['appointmentTime'] as String).toSet();

    List<String> slots = [];
    DateTime slotTime = start;

    while (slotTime.isBefore(end)) {
      final slotLabel = DateFormat.jm().format(slotTime); // e.g., "9:00 AM"

      // Check if slot is in a break
      bool inBreak = false;
      for (var brk in dayAvailability['breaks']) {
        final brkStartParts = (brk['start'] as String).split(':');
        final brkEndParts = (brk['end'] as String).split(':');
        DateTime brkStart = DateTime(
          date.year,
          date.month,
          date.day,
          int.parse(brkStartParts[0]),
          int.parse(brkStartParts[1]),
        );
        DateTime brkEnd = DateTime(
          date.year,
          date.month,
          date.day,
          int.parse(brkEndParts[0]),
          int.parse(brkEndParts[1]),
        );
        if (!slotTime.isBefore(brkStart) && slotTime.isBefore(brkEnd)) {
          inBreak = true;
          break;
        }
      }

      if (!inBreak && !bookedTimes.contains(slotLabel)) {
        slots.add(slotLabel);
      }

      slotTime = slotTime.add(const Duration(minutes: 60)); // 1 hour interval
    }

    return slots;
  }

  // Book or reschedule appointment
  Future<void> _bookAppointment() async {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedTime != null &&
        _selectedType != null) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final data = {
        'studentId': user.uid,
        'studentName': user.displayName ?? user.email,
        'counselorId': widget.counselorId,
        'appointmentDate': DateFormat('yyyy-MM-dd').format(_selectedDate!),
        'appointmentTime': _selectedTime,
        'appointmentType': _selectedType,
        'additionalInfo': _additionalInfoController.text.trim(),
        'status': 'pending',
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (widget.appointmentId != null) {
        await _firestore
            .collection('appointments')
            .doc(widget.appointmentId)
            .update(data);
      } else {
        await _firestore.collection('appointments').add({
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

      // Go back to counselor dashboard
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appointmentTypes = [
      "Counseling",
      "Education Session",
      "Follow-up",
      "Other",
    ];

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Book Appointment"),
        backgroundColor: const Color(0xFFC9184A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
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
                children: [
                  // Date Picker
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.black54),
                    ),
                    title: Text(
                      _selectedDate == null
                          ? "Pick a Date"
                          : DateFormat('yyyy-MM-dd').format(_selectedDate!),
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
                        final slots = await _generateAvailableSlots(picked);
                        setState(() {
                          availableSlots = slots;
                          _selectedTime = null; // reset selected time
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Time slot dropdown
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
                        availableSlots.map((slot) {
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

                  // Appointment Type dropdown
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

                  // Additional info
                  TextFormField(
                    controller: _additionalInfoController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: "Additional Info (Optional)",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit button
                  ElevatedButton(
                    onPressed: _bookAppointment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF758F),
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: Text(
                      widget.appointmentId != null
                          ? "Reschedule Appointment"
                          : "Book Appointment",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
