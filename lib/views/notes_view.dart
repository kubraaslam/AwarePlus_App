import 'package:aware_plus/widgets/counselor_bottom_navbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PastNotesPage extends StatelessWidget {
  const PastNotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Past Session Notes'),
        backgroundColor: const Color(0xFFC9184A),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('appointments')
                .where('status', isEqualTo: 'completed')
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No past session notes found.'));
          }

          final completedAppointments =
              snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return data;
              }).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: completedAppointments.length,
            itemBuilder: (context, index) {
              final appt = completedAppointments[index];
              final date = DateTime.tryParse(appt['appointmentDate'] ?? '');
              final formattedDate =
                  date != null
                      ? DateFormat('MMMM d, yyyy').format(date)
                      : 'Unknown date';

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16), // rounded corners
                  side: const BorderSide(
                    color: Color(0xFFFFCCD5), // border color
                    width: 2, // border thickness
                  ),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(appt['studentName'] ?? 'Unknown Student'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$formattedDate • ${appt['appointmentType'] ?? 'N/A'}',
                      ),
                      const SizedBox(height: 4),
                      Text('Notes: ${appt['notes'] ?? 'No notes provided'}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: CounselorBottomNavbar(
        currentIndex: 1, // Index of Notes tab
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/counselorDashboard');
              break;
            case 1:
              // Already on Notes page
              break;
            case 2:
              Navigator.pushNamed(context, '/counselorProfile');
              break;
          }
        },
      ),
    );
  }
}
