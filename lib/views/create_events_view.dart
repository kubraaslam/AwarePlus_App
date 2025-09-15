import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CounselorEventsPage extends StatefulWidget {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  // Optional test overrides
  final DateTime? testSelectedDate;
  final TimeOfDay? testSelectedTime;

  const CounselorEventsPage({
    super.key,
    required this.auth,
    required this.firestore,
    this.testSelectedDate,
    this.testSelectedTime,
  });

  @override
  State<CounselorEventsPage> createState() => _CounselorEventsPageState();
}

class _CounselorEventsPageState extends State<CounselorEventsPage> {
  late final FirebaseAuth _auth;
  late final FirebaseFirestore _firestore;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _auth = widget.auth;
    _firestore = widget.firestore;

    // Inject test values if provided
    _selectedDate = widget.testSelectedDate;
    _selectedTime = widget.testSelectedTime;
  }

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();

  bool _isSaving = false; // ✅ Used for loading indicator

  void _resetForm() {
    _titleController.clear();
    _descController.clear();
    _locationController.clear();
    _selectedDate = null;
    _selectedTime = null;
  }

  Future<void> _saveEvent({String? eventId}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    if (!_formKey.currentState!.validate() ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final data = {
        'title': _titleController.text,
        'description': _descController.text,
        'location': _locationController.text,
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
        'time':
            "${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}",
        'createdBy': user.uid,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (eventId == null) {
        await _firestore.collection('events').add({
          ...data,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        await _firestore.collection('events').doc(eventId).update(data);
      }

      _resetForm();
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showEventModal({DocumentSnapshot? event}) {
    if (event != null) {
      _titleController.text = event['title'];
      _descController.text = event['description'];
      _locationController.text = event['location'];
      _selectedDate = DateFormat('yyyy-MM-dd').parse(event['date']);
      final parts = (event['time'] as String).split(':');
      _selectedTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    } else {
      _resetForm();
    }

    showModalBottomSheet(
      backgroundColor: const Color(0xFFFFF0F3),
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 24,
          left: 20,
          right: 20,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    event == null ? "Create Event" : "Edit Event",
                    key: const Key('eventModalTitle'),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('eventTitleField'),
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: "Event Title",
                    prefixIcon: Icon(Icons.title),
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? "Enter title" : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('eventDescriptionField'),
                  controller: _descController,
                  decoration: const InputDecoration(
                    labelText: "Description",
                    prefixIcon: Icon(Icons.description),
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? "Enter description" : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('eventLocationField'),
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: "Location",
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? "Enter location" : null,
                ),
                const SizedBox(height: 20),
                _isSaving
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          key: const Key('createEventButton'),
                          onPressed: () => _saveEvent(eventId: event?.id),
                          child: Text(
                              event == null ? "Create Event" : "Update Event"),
                        ),
                      ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text("Please log in")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Events"),
        backgroundColor: const Color(0xFFC9184A),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('events')
            .where('createdBy', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final events = snapshot.data?.docs ?? [];
          if (events.isEmpty) {
            return const Center(child: Text("No events yet."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                key: Key('eventCard_${event.id}'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFFFCCD5), width: 2),
                ),
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event['title'],
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        event['description'],
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const Divider(),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 18,
                            color: Color(0xFF800F2F),
                          ),
                          const SizedBox(width: 4),
                          Expanded(child: Text(event['location'])),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 18,
                            color: Color(0xFFFF4D6D),
                          ),
                          const SizedBox(width: 4),
                          Text(event['date']),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.access_time,
                            size: 18,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(event['time']),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('fabCreateEventButton'),
        onPressed: () => _showEventModal(),
        child: const Icon(Icons.add),
      ),
    );
  }
}