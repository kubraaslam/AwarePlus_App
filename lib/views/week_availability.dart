import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class WeeklyAvailabilityScreen extends StatefulWidget {
  const WeeklyAvailabilityScreen({super.key});

  @override
  State<WeeklyAvailabilityScreen> createState() =>
      _WeeklyAvailabilityScreenState();
}

class _WeeklyAvailabilityScreenState extends State<WeeklyAvailabilityScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<String> weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  Map<String, Map<String, dynamic>> availability = {};

  @override
  void initState() {
    super.initState();
    for (var day in weekdays) {
      availability[day] = {
        'available': false,
        'start': '09:00',
        'end': '17:00',
        'breaks': [],
      };
    }
    _loadExistingSchedule();
  }

  Future<void> _loadExistingSchedule() async {
    try {
      final doc =
          await _firestore
              .collection('availability')
              .doc('5JBRZ1SxjeYDpGxrmJogOQHsISb2')
              .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data.containsKey('week')) {
          final weekData = data['week'] as Map<String, dynamic>;
          setState(() {
            availability = weekData.map((key, value) {
              final dayMap = Map<String, dynamic>.from(value);
              // Ensure start and end are strings
              dayMap['start'] = dayMap['start'].toString();
              dayMap['end'] = dayMap['end'].toString();
              // Ensure breaks are properly typed
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
          });
        }
      } else {
        // Document doesn't exist, keep default availability
        debugPrint('No existing schedule found, using defaults.');
      }
    } catch (e) {
      debugPrint('Failed to load schedule: $e');
    }
  }

  Future<void> _saveSchedule() async {
    await _firestore
        .collection('availability')
        .doc('5JBRZ1SxjeYDpGxrmJogOQHsISb2')
        .set({'week': availability});
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Schedule saved!")));

    // Navigate back to CounselorDashboard
    Navigator.pushReplacementNamed(context, '/counselorDashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Weekly Availability"),
        backgroundColor: const Color(0xFFC9184A),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          ...weekdays.map((day) {
            final dayData = availability[day]!;
            return Card(
              margin: const EdgeInsets.all(8),
              child: ExpansionTile(
                title: Text(day),
                children: [
                  SwitchListTile(
                    title: const Text("Available"),
                    value: dayData['available'],
                    onChanged: (val) {
                      setState(() {
                        dayData['available'] = val;
                      });
                    },
                  ),
                  if (dayData['available']) ...[
                    ListTile(
                      title: const Text("Start Time"),
                      trailing: Text(dayData['start']),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: const TimeOfDay(hour: 9, minute: 0),
                        );
                        if (time != null) {
                          setState(() {
                            dayData['start'] =
                                "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
                          });
                        }
                      },
                    ),
                    ListTile(
                      title: const Text("End Time"),
                      trailing: Text(dayData['end']),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: const TimeOfDay(hour: 17, minute: 0),
                        );
                        if (time != null) {
                          setState(() {
                            dayData['end'] =
                                "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
                          });
                        }
                      },
                    ),
                    // Breaks list
                    Column(
                      children: [
                        ...dayData['breaks'].map<Widget>((brk) {
                          return ListTile(
                            title: Text(
                              "Break: ${brk['start']} - ${brk['end']}",
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  dayData['breaks'].remove(brk);
                                });
                              },
                            ),
                          );
                        }).toList(),
                        TextButton(
                          onPressed: () async {
                            final start = await showTimePicker(
                              context: context,
                              initialTime: const TimeOfDay(hour: 12, minute: 0),
                            );
                            if (start == null) return;
                            final end = await showTimePicker(
                              // ignore: use_build_context_synchronously
                              context: context,
                              initialTime: const TimeOfDay(hour: 13, minute: 0),
                            );
                            if (end == null) return;
                            setState(() {
                              dayData['breaks'].add({
                                'start':
                                    "${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}",
                                'end':
                                    "${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}",
                              });
                            });
                          },
                          child: const Text("+ Add Break"),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          }),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC9184A),
                foregroundColor: Colors.white,
              ),
              onPressed: _saveSchedule,
              child: const Text("Save Weekly Schedule"),
            ),
          ),
        ],
      ),
    );
  }
}
