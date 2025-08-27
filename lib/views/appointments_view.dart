import 'package:aware_plus/views/book_appointment_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyAppointmentsView extends StatelessWidget {
  const MyAppointmentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Appointments", style: TextStyle(fontSize: 20)),
        backgroundColor: const Color(0xFFC9184A),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('studentId', isEqualTo: user!.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No appointments yet."));
          }

          final docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final doc = docs[i];
              final data = doc.data() as Map<String, dynamic>;
              final status = data['status'];

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(
                    "Date: ${data['appointmentDate']} at ${data['appointmentTime']}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Status: $status"),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'remove') {
                        // Remove appointment if not completed
                        if (status != 'completed') {
                          await FirebaseFirestore.instance
                              .collection('appointments')
                              .doc(doc.id)
                              .delete();
                        }
                      } else if (value == 'reschedule') {
                        // Reschedule if rejected
                        if (status == 'rejected') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookAppointmentPage( appointmentId: doc.id, counselorId: '5JBRZ1SxjeYDpGxrmJogOQHsISb2',
                              ),
                            ),
                          );
                        }
                      }
                    },
                    itemBuilder: (context) {
                      return <PopupMenuEntry<String>>[
                        if (status != 'completed')
                          const PopupMenuItem(
                            value: 'remove',
                            child: Text('Remove'),
                          ),
                        if (status == 'rejected')
                          const PopupMenuItem(
                            value: 'reschedule',
                            child: Text('Reschedule'),
                          ),
                      ];
                    },
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