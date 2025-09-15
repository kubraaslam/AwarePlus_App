import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class StudentEventsPage extends StatefulWidget {
  final FirebaseFirestore? firestore;
  const StudentEventsPage({super.key, this.firestore});

  @override
  State<StudentEventsPage> createState() => _StudentEventsPageState();
}

class _StudentEventsPageState extends State<StudentEventsPage> {
  late FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> _eventsByDate = {};

  @override
  void initState() {
    super.initState();
    _firestore = widget.firestore ?? FirebaseFirestore.instance;
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final snapshot = await _firestore.collection('events').get();
    final Map<DateTime, List<Map<String, dynamic>>> events = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final date = DateFormat('yyyy-MM-dd').parse(data['date']);

      final dayKey = DateTime(date.year, date.month, date.day);
      if (events[dayKey] == null) events[dayKey] = [];
      events[dayKey]!.add({
        'title': data['title'],
        'description': data['description'],
        'location': data['location'],
        'time': data['time'],
      });
    }

    setState(() => _eventsByDate = events);
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final dayKey = DateTime(day.year, day.month, day.day);
    return _eventsByDate[dayKey] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sexual Health Events"),
        backgroundColor: const Color(0xFFC9184A),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: _getEventsForDay,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Color(0xFFC9184A),
                shape: BoxShape.circle,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                return Container(
                  key: Key('day-${day.year}-${day.month}-${day.day}'),
                  alignment: Alignment.center,
                  child: Text('${day.day}'),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child:
                _selectedDay == null
                    ? const Center(child: Text("Select a date to view events"))
                    : ListView(
                      padding: const EdgeInsets.all(12),
                      children:
                          _getEventsForDay(_selectedDay!).map((event) {
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: const BorderSide(
                                  color: Color(0xFFFFCCD5),
                                  width: 2,
                                ),
                              ),
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                title: Text(
                                  event['title'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  "${event['description']}\nLocation: ${event['location']}\nTime: ${event['time']}",
                                ),
                                isThreeLine: true,
                                leading: const Icon(
                                  Icons.event,
                                  color: Color(0xFFC9184A),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
          ),
        ],
      ),
    );
  }
}
