import 'package:aware_plus/views/notes_view.dart';
import 'package:aware_plus/views/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CounselorDashboard extends StatefulWidget {
  const CounselorDashboard({super.key});

  @override
  State<CounselorDashboard> createState() => _CounselorDashboardState();
}

class _CounselorDashboardState extends State<CounselorDashboard> {
  Future<void> _updateStatus(String docId, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(docId)
          .update({'status': status});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Appointment $status successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update status: $e')));
    }
  }

  Future<void> _completeSessionWithNotes(String docId, String notes) async {
    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(docId)
          .update({'status': 'completed', 'notes': notes});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session completed and notes saved')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save notes: $e')));
    }
  }

  Future<void> _showNotesDialog(String docId, String initialNotes) async {
    final TextEditingController notesController = TextEditingController(
      text: initialNotes,
    );

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              'Add Session Notes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            content: TextField(
              controller: notesController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Write your notes here...',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(), // Cancel
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _completeSessionWithNotes(docId, notesController.text.trim());
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF758F),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save & Complete'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFC9184A),
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.note_alt),
                  tooltip: 'Past Notes',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PastNotesPage(),
                      ),
                    );
                  },
                ),

                IconButton(
                  icon: const Icon(Icons.person),
                  tooltip: 'Profile',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                const ProfileView(showBackButton: true),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.asset('assets/img/awareplus-logo.png', height: 100),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('appointments')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: Text('No appointment data.'));
                  }

                  final allAppointments =
                      snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        data['id'] = doc.id; // add doc ID for updates
                        return data;
                      }).toList();

                  final now = DateTime.now();
                  final todayAppointments =
                      allAppointments.where((appt) {
                        final date = DateTime.tryParse(
                          appt['preferredDate'] ?? '',
                        );
                        return date != null &&
                            date.year == now.year &&
                            date.month == now.month &&
                            date.day == now.day;
                      }).toList();

                  final pendingAppointments =
                      allAppointments
                          .where(
                            (appt) =>
                                (appt['status'] ?? '').toLowerCase() ==
                                'pending',
                          )
                          .toList();

                  final weekAppointments =
                      allAppointments.where((appt) {
                        final date = DateTime.tryParse(
                          appt['preferredDate'] ?? '',
                        );
                        return date != null &&
                            date.isAfter(
                              now.subtract(const Duration(days: 1)),
                            ) &&
                            date.isBefore(now.add(const Duration(days: 7)));
                      }).toList();

                  final completedAppointments =
                      allAppointments
                          .where(
                            (appt) =>
                                (appt['status'] ?? '').toLowerCase() ==
                                'completed',
                          )
                          .toList();

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Welcome back, SSS!',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'You have ${pendingAppointments.length} appointment requests and ${todayAppointments.length} sessions scheduled for today.',
                          style: const TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 16),

                        // Summary Cards
                        SizedBox(
                          height: 180,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _summaryCard(
                                'Pending Requests',
                                pendingAppointments.length.toString(),
                                'Awaiting your response',
                                Icons.access_time,
                              ),
                              _summaryCard(
                                'Today\'s Sessions',
                                todayAppointments.length.toString(),
                                'Scheduled appointments',
                                Icons.calendar_today,
                              ),
                              _summaryCard(
                                'This Week',
                                weekAppointments.length.toString(),
                                'Total appointments',
                                Icons.date_range,
                              ),
                              _summaryCard(
                                'Completed',
                                completedAppointments.length.toString(),
                                'This month',
                                Icons.check_circle,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        isMobile
                            ? Column(
                              children: [
                                _appointmentRequestsCard(pendingAppointments),
                                const SizedBox(height: 20),
                                _todayScheduleCard(todayAppointments),
                                const SizedBox(height: 20),
                                _upcomingDaysCard(allAppointments),
                              ],
                            )
                            : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: _appointmentRequestsCard(
                                    pendingAppointments,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      _todayScheduleCard(todayAppointments),
                                      const SizedBox(height: 20),
                                      _upcomingDaysCard(allAppointments),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
  ) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFFC9184A), size: 28),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _appointmentRequestsCard(List<Map<String, dynamic>> appointments) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // rounded corners
        side: const BorderSide(
          color: Color(0xFFFFCCD5), // border color
          width: 1, // border thickness
        ),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Icon(Icons.access_time, color: Color(0xFFC9184A)),
                SizedBox(width: 8),
                Text(
                  'Appointment Requests',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (appointments.isEmpty) const Text('No pending requests.'),
            ...appointments.map((appt) {
              final date = DateTime.tryParse(appt['preferredDate'] ?? '');
              final formattedDate =
                  date != null
                      ? DateFormat('MMMM d, yyyy').format(date)
                      : 'No date';

              final notes = appt['notes'] ?? '';

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appt['fullName'] ?? 'Unknown Student',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text('$formattedDate • ${appt['preferredTime'] ?? ''}'),
                        const SizedBox(height: 4),
                        Text('Topic: ${appt['appointmentType'] ?? 'N/A'}'),
                        if (notes.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 6.0,
                              bottom: 6.0,
                            ),
                            child: Text(
                              'Notes: $notes',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ),
                        Wrap(
                          runSpacing: 8,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                onPressed:
                                    () => _updateStatus(appt['id'], 'approved'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF758F),
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Approve'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                onPressed:
                                    () => _updateStatus(appt['id'], 'rejected'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                  foregroundColor: Colors.red,
                                ),
                                child: const Text('Reject'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _todayScheduleCard(List<Map<String, dynamic>> todayAppointments) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // rounded corners
        side: const BorderSide(
          color: Color(0xFFFFCCD5), // border color
          width: 2, // border thickness
        ),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Icon(Icons.calendar_today, color: Color(0xFFC9184A)),
                SizedBox(width: 8),
                Text(
                  'Today\'s Schedule',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (todayAppointments.isEmpty)
              const Text('No appointments for today.'),
            ...todayAppointments.map((item) {
              final notes = item['notes'] ?? '';
              final status = (item['status'] ?? '').toLowerCase();

              Color badgeColor;
              Color badgeTextColor;
              switch (status) {
                case 'approved':
                  badgeColor = Colors.green[100]!;
                  badgeTextColor = Colors.green;
                  break;
                case 'rejected':
                  badgeColor = Colors.red[100]!;
                  badgeTextColor = Colors.red;
                  break;
                case 'completed':
                  badgeColor = Colors.grey[300]!;
                  badgeTextColor = Colors.grey[800]!;
                  break;
                default:
                  badgeColor = Colors.orange[100]!;
                  badgeTextColor = Colors.orange;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // First row: time, name, badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${item['preferredTime'] ?? ''} - ${item['fullName'] ?? ''}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: badgeColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              item['status'] ?? 'pending',
                              style: TextStyle(
                                color: badgeTextColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item['appointmentType'] ?? ''}',
                        style: const TextStyle(fontSize: 13),
                      ),
                      if (notes.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'Notes: $notes',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      if (status != 'completed' && status != 'rejected')
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  () => _showNotesDialog(item['id'], notes),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              child: const Text(
                                'Complete & Add Notes',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _upcomingDaysCard(List<Map<String, dynamic>> allAppointments) {
    final now = DateTime.now();
    final upcoming = <DateTime, List<Map<String, dynamic>>>{};

    // Group appointments by date
    for (var appt in allAppointments) {
      final date = DateTime.tryParse(appt['preferredDate'] ?? '');
      if (date != null && date.isAfter(now)) {
        final dayKey = DateTime(date.year, date.month, date.day);
        upcoming.putIfAbsent(dayKey, () => []).add(appt);
      }
    }

    // Sort by date
    final sortedDates = upcoming.keys.toList()..sort();

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // rounded corners
        side: const BorderSide(
          color: Color(0xFFFFCCD5), // border color
          width: 2, // border thickness
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Icon(Icons.calendar_today, color: Color(0xFFC9184A)),
                SizedBox(width: 8),
                Text(
                  'Upcoming Days',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (sortedDates.isEmpty) const Text('No upcoming appointments.'),
            ...sortedDates.map((date) {
              final bookedCount = upcoming[date]!.length;
              final remainingSlots = 8 - bookedCount;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left side
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDateLabel(date, now),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '$bookedCount appointments',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    // Right side
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Available slots',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        Text(
                          '$remainingSlots',
                          style: TextStyle(
                            color:
                                remainingSlots > 0 ? Colors.pink : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // Helper to format date like "Tomorrow", "Sat, Mar 16"
  String _formatDateLabel(DateTime date, DateTime now) {
    final tomorrow = now.add(const Duration(days: 1));
    if (date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day) {
      return 'Tomorrow';
    }
    return DateFormat('E, MMM d').format(date);
  }
}
