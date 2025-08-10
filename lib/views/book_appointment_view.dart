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
  String? _appointmentId; // NEW: For update mode

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      _appointmentId = args['appointmentId'];

      _selectedDate =
          args['preferredDate'] != null
              ? DateTime.tryParse(args['preferredDate'])
              : null;
      _selectedTime = args['preferredTime'] ?? '';
      _appointmentType = args['appointmentType'] ?? '';

      // Prefill other fields if provided
      _fullNameController.text = args['fullName'] ?? '';
      _studentIdController.text = args['studentId'] ?? '';
      _emailController.text = args['email'] ?? '';
      _phoneController.text = args['phone'] ?? '';
      _additionalInfoController.text = args['additionalInfo'] ?? '';
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
      'fullName': _fullNameController.text.trim(),
      'studentId': _studentIdController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'preferredDate': _selectedDate!.toIso8601String(),
      'preferredTime': _selectedTime,
      'appointmentType': _appointmentType,
      'additionalInfo': _additionalInfoController.text.trim(),
      'status': 'pending', // reset status on update
      'updatedAt': Timestamp.now(),
    };

    if (_appointmentId != null) {
      // Update existing appointment
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(_appointmentId)
          .update(data);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment updated successfully!')),
      );
    } else {
      // Create new appointment
      await FirebaseFirestore.instance.collection('appointments').add({
        ...data,
        'createdAt': Timestamp.now(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment booked successfully!')),
      );
    }

    setState(() => _isSubmitting = false);
    if (!mounted) return;

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/support');

    _formKey.currentState!.reset();
    setState(() {
      _selectedDate = null;
      _selectedTime = null;
      _appointmentType = null;
      _appointmentId = null;
    });
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Appointment Information'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Contact Information',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text('Student Support Services\nSSS@apit.lk'),
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
                child: const Text('Close'),
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
    Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _appointmentId != null
              ? 'Reschedule Appointment'
              : 'Book Appointment',
        ),
        backgroundColor: Colors.pinkAccent,
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
                              validator: (v) => v!.isEmpty ? 'Required' : null,
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
                              validator: (v) => v!.isEmpty ? 'Required' : null,
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
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
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
                                  firstDate: DateTime.now(),
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
                                  _times
                                      .map(
                                        (t) => DropdownMenuItem(
                                          value: t,
                                          child: Text(t),
                                        ),
                                      )
                                      .toList(),
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
                        onChanged: (v) => setState(() => _appointmentType = v),
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
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pinkAccent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
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
