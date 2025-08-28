import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CounselorEventsPage extends StatefulWidget {
  const CounselorEventsPage({super.key});

  @override
  State<CounselorEventsPage> createState() => _CounselorEventsPageState();
}

class _CounselorEventsPageState extends State<CounselorEventsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isSaving = false;

  // pick date
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      WidgetsBinding.instance.addPostFrameCallback((_) => _pickTime());
    }
  }

  // pick time
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  // reset form
  void _resetForm() {
    _titleController.clear();
    _descController.clear();
    _locationController.clear();
    _selectedDate = null;
    _selectedTime = null;
  }

  // create or update event
  Future<void> _saveEvent({String? eventId}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    if (!_formKey.currentState!.validate() ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(eventId == null ? "Event created!" : "Event updated!"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  // delete confirmation
  Future<void> _confirmDelete(String eventId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              "Delete Event",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text("Are you sure you want to delete this event?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                icon: const Icon(Icons.delete, color: Colors.white),
                label: const Text("Delete"),
              ),
            ],
          ),
    );

    if (shouldDelete == true) {
      try {
        await _firestore.collection('events').doc(eventId).delete();
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Event deleted")));
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  // modal
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
      backgroundColor: Color(0xFFFFF0F3),
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (context) => Padding(
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
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: "Event Title",
                        prefixIcon: Icon(Icons.title),
                        border: OutlineInputBorder(),
                      ),
                      validator:
                          (val) =>
                              val == null || val.isEmpty ? "Enter title" : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descController,
                      decoration: const InputDecoration(
                        labelText: "Description",
                        prefixIcon: Icon(Icons.description),
                        border: OutlineInputBorder(),
                      ),
                      validator:
                          (val) =>
                              val == null || val.isEmpty
                                  ? "Enter description"
                                  : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: "Location",
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(),
                      ),
                      validator:
                          (val) =>
                              val == null || val.isEmpty
                                  ? "Enter location"
                                  : null,
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today),
                      title: Text(
                        _selectedDate == null
                            ? "Pick a Date"
                            : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                      ),
                      onTap: _pickDate,
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.access_time),
                      title: Text(
                        _selectedTime == null
                            ? "Pick a Time"
                            : _selectedTime!.format(context),
                      ),
                      onTap: _selectedDate == null ? null : _pickTime,
                    ),
                    const SizedBox(height: 20),
                    _isSaving
                        ? const Center(child: CircularProgressIndicator())
                        : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _saveEvent(eventId: event?.id),
                            icon: const Icon(Icons.check, color: Colors.white,),
                            label: Text(
                              event == null ? "Create Event" : "Update Event", style: TextStyle(fontSize: 18),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              backgroundColor: Color(0xFFC9184A),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
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
        stream:
            _firestore
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(
                    color: Color(0xFFFFCCD5), // border color
                    width: 2, // border thickness
                  ),
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Color(0xFFA4133C),
                            ),
                            onPressed: () => _showEventModal(event: event),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDelete(event.id),
                          ),
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
        backgroundColor: Color(0xFFC9184A),
        onPressed: () => _showEventModal(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}