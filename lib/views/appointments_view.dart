import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyAppointmentsView extends StatelessWidget {
  const MyAppointmentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Appointments')),
        body: const Center(
          child: Text('Please log in to view your appointments.'),
        ),
      );
    }

    // Reference to appointments collection filtered by user email or uid
    final appointmentsQuery = FirebaseFirestore.instance
        .collection('appointments')
        .where('email', isEqualTo: user.email)
        .orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        backgroundColor: const Color(0xFFE7636E),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: appointmentsQuery.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text('No appointments found.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final data = docs[index].data()! as Map<String, dynamic>;

              final preferredDateStr = data['preferredDate'] ?? '';
              final preferredTime = data['preferredTime'] ?? '';
              final appointmentType = data['appointmentType'] ?? '';
              final status = data['status'] ?? 'pending';

              DateTime? preferredDate;
              try {
                preferredDate = DateTime.parse(preferredDateStr);
              } catch (_) {
                preferredDate = null;
              }

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
                child: ListTile(
                  title: Text(
                    preferredDate != null
                        ? 'Date: ${DateFormat.yMMMd().format(preferredDate)} at $preferredTime'
                        : 'Date & time not set',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Type: $appointmentType\nStatus: ${status[0].toUpperCase()}${status.substring(1)}',
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'remove') {
                        if (status.toLowerCase() != 'done') {
                          await FirebaseFirestore.instance
                              .collection('appointments')
                              .doc(docs[index].id)
                              .delete();
                              
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Appointment removed'),
                            ),
                          );
                        }
                      } else if (value == 'reschedule') {
                        Navigator.pushNamed(
                          context,
                          '/bookAppointment', // Change to your actual route
                          arguments: {
                            'appointmentId':
                                docs[index].id, // Needed for update
                            'preferredDate': preferredDateStr,
                            'preferredTime': preferredTime,
                            'appointmentType': appointmentType,
                          },
                        );
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        if (status.toLowerCase() != 'done')
                          const PopupMenuItem(
                            value: 'remove',
                            child: Text('Remove'),
                          ),
                        if (status.toLowerCase() == 'rejected')
                          const PopupMenuItem(
                            value: 'reschedule',
                            child: Text('Reschedule'),
                          ),
                      ];
                    },
                    icon: const Icon(Icons.more_vert),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
