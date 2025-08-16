import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookAppointmentPage extends StatefulWidget {
  const BookAppointmentPage({super.key});

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _additionalInfoController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedTime;
  String? _appointmentType;
  String? _appointmentId; // For rescheduling

  final List<String> _times = [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '01:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
  ];

  final List<String> _appointmentTypes = [
    'Counseling',
    'Education Session',
    'Follow-up',
    'Other',
  ];

  // Validation Helpers
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full Name is required';
    }
    if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(value)) {
      return 'Name can only contain letters';
    }
    return null;
  }

  String? _validateStudentId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Student ID is required';
    }
    // allow letters, numbers
    if (!RegExp(r"^[A-Za-z0-9]+$").hasMatch(value)) {
      return 'Invalid Student ID format';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (!RegExp(r"^[0-9]{10}$").hasMatch(value)) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }

  String? _validateNotes(String? value) {
    if (value != null && value.length > 250) {
      return 'Maximum 250 characters allowed';
    }
    return null;
  }

  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

      if (args != null) {
        _appointmentId = args['appointmentId'];
        _selectedDate =
            args['preferredDate'] != null
                ? DateTime.tryParse(args['preferredDate'])
                : null;
        _selectedTime = args['preferredTime'];
        _appointmentType = args['appointmentType'];

        // Prefill other fields, read-only if rescheduling
        _fullNameController.text = args['fullName'] ?? '';
        _studentIdController.text = args['studentId'] ?? '';
        _emailController.text = args['email'] ?? '';
        _phoneController.text = args['phone'] ?? '';
        _additionalInfoController.text = args['additionalInfo'] ?? '';
      }
      _isInit = false; // Prevent resetting on rebuilds
    }
  }

  bool _isSubmitting = false;

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() ||
        _selectedDate == null ||
        _selectedTime == null ||
        _appointmentType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final data = {
      'preferredDate': _selectedDate!.toIso8601String(),
      'preferredTime': _selectedTime,
      'status': 'pending',
      'updatedAt': Timestamp.now(),
    };

    // Check if the selected slot is already booked
    final querySnapshot =
        await FirebaseFirestore.instance
            .collection('appointments')
            .where('preferredDate', isEqualTo: _selectedDate!.toIso8601String())
            .where('preferredTime', isEqualTo: _selectedTime)
            .get();

    // If rescheduling, exclude the current appointment from the check
    final isSlotTaken = querySnapshot.docs.any(
      (doc) => _appointmentId == null || doc.id != _appointmentId,
    );

    if (isSlotTaken) {
      setState(() => _isSubmitting = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Selected time slot unavailable. Please choose a different time.',
          ),
        ),
      );
      return;
    }

    if (_appointmentId != null) {
      // Update only date/time for reschedule
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(_appointmentId)
          .update(data);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment rescheduled successfully!')),
      );
    } else {
      // New appointment
      final fullData = {
        ...data,
        'fullName': _fullNameController.text.trim(),
        'studentId': _studentIdController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'appointmentType': _appointmentType,
        'additionalInfo': _additionalInfoController.text.trim(),
        'createdAt': Timestamp.now(),
      };
      await FirebaseFirestore.instance.collection('appointments').add(fullData);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment booked successfully!')),
      );
    }

    setState(() => _isSubmitting = false);

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/support');
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              'Appointment Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Contact Information',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text('Student Support Services: SSS@apiit.lk'),
                  SizedBox(height: 8),
                  Text('Office Hours:\nMon-Fri 9:00 AM - 5:00 PM'),
                  SizedBox(height: 16),
                  Text(
                    'What to Expect',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text('• Non-judgmental counseling in a safe environment'),
                  Text('• Evidence-based sexual health education'),
                  Text('• Confidential support for sexual health concerns'),
                  Text('• Referrals to specialized healthcare when needed'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Close',
                  style: TextStyle(color: Color(0xFFA4133C)),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildTitleBar() {
    return Row(
      children: [
        Expanded(
          child: Text(
            _appointmentId != null
                ? 'Reschedule Your Appointment'
                : 'Book Your Confidential Appointment',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _appointmentId != null
              ? 'Reschedule Appointment'
              : 'Book Appointment',
          style: TextStyle(fontSize: 20),
        ),
        backgroundColor: const Color(0xFFC9184A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showInfoDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleBar(),
                      const SizedBox(height: 8),
                      const Text(
                        'All conversations are strictly confidential. Your privacy is our top priority.',
                        style: TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _fullNameController,
                              decoration: const InputDecoration(
                                labelText: 'Full Name',
                                border: OutlineInputBorder(),
                              ),
                              validator: _validateName,
                              readOnly: _appointmentId != null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _studentIdController,
                              decoration: const InputDecoration(
                                labelText: 'Student ID',
                                border: OutlineInputBorder(),
                              ),
                              validator: _validateStudentId,
                              readOnly: _appointmentId != null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                        readOnly: _appointmentId != null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: _validatePhone,
                        readOnly: _appointmentId != null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDate ?? DateTime.now(),
                                  firstDate:
                                      DateTime.now(), // or some policy, e.g., past appointments cannot go back
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 365),
                                  ),
                                );

                                if (date != null) {
                                  setState(() => _selectedDate = date);
                                }
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Preferred Date',
                                  border: OutlineInputBorder(),
                                ),
                                child: Text(
                                  _selectedDate == null
                                      ? 'Select date'
                                      : '${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedTime,
                              decoration: const InputDecoration(
                                labelText: 'Preferred Time',
                                border: OutlineInputBorder(),
                              ),
                              items:
                                  _times.map((t) {
                                    bool isPast = false;
                                    if (_selectedDate != null) {
                                      final now = DateTime.now();
                                      final today = DateTime(
                                        now.year,
                                        now.month,
                                        now.day,
                                      );
                                      final selectedDay = DateTime(
                                        _selectedDate!.year,
                                        _selectedDate!.month,
                                        _selectedDate!.day,
                                      );
                                      if (selectedDay.isAtSameMomentAs(today)) {
                                        // convert time string to 24-hour int
                                        final parts = t.split(':');
                                        int hour = int.parse(parts[0]);
                                        int minute = int.parse(
                                          parts[1].split(' ')[0],
                                        );
                                        if (t.contains('PM') && hour != 12) {
                                          hour += 12;
                                        }
                                        final slotTime = DateTime(
                                          now.year,
                                          now.month,
                                          now.day,
                                          hour,
                                          minute,
                                        );
                                        if (slotTime.isBefore(now)) {
                                          isPast = true;
                                        }
                                      }
                                    }
                                    return DropdownMenuItem(
                                      value: t,
                                      enabled: !isPast,
                                      child: Text(
                                        t,
                                        style: TextStyle(
                                          color:
                                              isPast
                                                  ? Colors.grey
                                                  : Colors.black,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                              onChanged:
                                  (v) => setState(() => _selectedTime = v),
                              validator: (v) => v == null ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _appointmentType,
                        decoration: const InputDecoration(
                          labelText: 'Appointment Type',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            _appointmentTypes
                                .map(
                                  (type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            _appointmentId == null
                                ? (v) => setState(() => _appointmentType = v)
                                : null,
                        validator: (v) => v == null ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _additionalInfoController,
                        decoration: const InputDecoration(
                          labelText: 'Additional Information (Optional)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        maxLength: 250,
                        validator: _validateNotes,
                        readOnly: _appointmentId != null,
                      ),

                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFF758F),
                            padding: const EdgeInsets.all(20),
                          ),
                          child:
                              _isSubmitting
                                  ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  )
                                  : Text(
                                    _appointmentId != null
                                        ? 'Update Appointment'
                                        : 'Book Appointment',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
