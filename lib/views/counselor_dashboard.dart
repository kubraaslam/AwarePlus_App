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

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'aware+',
          style: TextStyle(
            color: Color(0xFFE7636E),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: const [
          CircleAvatar(
            backgroundColor: Color(0xFFE7636E),
            child: Icon(Icons.person, color: Colors.white),
          ),
          SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                  final date = DateTime.tryParse(appt['preferredDate'] ?? '');
                  return date != null &&
                      date.year == now.year &&
                      date.month == now.month &&
                      date.day == now.day;
                }).toList();

            final pendingAppointments =
                allAppointments
                    .where(
                      (appt) =>
                          (appt['status'] ?? '').toLowerCase() == 'pending',
                    )
                    .toList();

            final weekAppointments =
                allAppointments.where((appt) {
                  final date = DateTime.tryParse(appt['preferredDate'] ?? '');
                  return date != null &&
                      date.isAfter(now.subtract(const Duration(days: 1))) &&
                      date.isBefore(now.add(const Duration(days: 7)));
                }).toList();

            final completedAppointments =
                allAppointments
                    .where(
                      (appt) =>
                          (appt['status'] ?? '').toLowerCase() == 'completed',
                    )
                    .toList();

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome back, SSS!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'You have ${pendingAppointments.length} appointment requests and ${todayAppointments.length} sessions scheduled for today.',
                    style: const TextStyle(color: Colors.grey),
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
              Icon(icon, color: const Color(0xFFE7636E), size: 28),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
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
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _appointmentRequestsCard(List<Map<String, dynamic>> appointments) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📩 Appointment Requests',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (appointments.isEmpty) const Text('No pending requests.'),
            ...appointments.map((appt) {
              final date = DateTime.tryParse(appt['preferredDate'] ?? '');
              final formattedDate =
                  date != null
                      ? DateFormat('MMMM d, yyyy').format(date)
                      : 'No date';
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200),
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
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ElevatedButton(
                            onPressed:
                                () => _updateStatus(appt['id'], 'approved'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE7636E),
                            ),
                            child: const Text('Approve'),
                          ),
                          ElevatedButton(
                            onPressed:
                                () => _updateStatus(appt['id'], 'rejected'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                            ),
                            child: const Text('Reject'),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text('View Details'),
                          ),
                        ],
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

  Widget _todayScheduleCard(List<Map<String, dynamic>> todayAppointments) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📅 Today\'s Schedule',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (todayAppointments.isEmpty)
              const Text('No appointments for today.'),
            ...todayAppointments.map((item) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  '${item['preferredTime'] ?? ''} - ${item['fullName'] ?? ''}',
                ),
                subtitle: Text('${item['appointmentType'] ?? ''}'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (item['status'] ?? '').toLowerCase() == 'approved'
                            ? Colors.green[100]
                            : Colors.orange[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item['status'] ?? 'pending',
                    style: TextStyle(
                      color:
                          (item['status'] ?? '').toLowerCase() == 'approved'
                              ? Colors.green
                              : Colors.orange,
                      fontWeight: FontWeight.bold,
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

  Widget _upcomingDaysCard(List<Map<String, dynamic>> allAppointments) {
    final now = DateTime.now();
    final upcoming = <String, List<Map<String, dynamic>>>{};

    for (var appt in allAppointments) {
      final date = DateTime.tryParse(appt['preferredDate'] ?? '');
      if (date != null && date.isAfter(now)) {
        final dayKey = DateFormat('EEEE, MMM d').format(date);
        upcoming.putIfAbsent(dayKey, () => []).add(appt);
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📆 Upcoming Days',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (upcoming.isEmpty) const Text('No upcoming appointments.'),
            ...upcoming.entries.map((entry) {
              return ListTile(
                title: Text(entry.key),
                subtitle: Text('${entry.value.length} appointments'),
              );
            }),
          ],
        ),
      ),
    );
  }
}
