import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  List<DateTime> _markedDates = [];

  @override
  void initState() {
    super.initState();
    fetchTrainingDates();
  }

  void fetchTrainingDates() async {
    final user = FirebaseFirestore.instance.collection('usuarios').doc('userUid');
    final entrenamientosSnapshot = await user.collection('progreso').doc('entrenamientos').get();
    if (entrenamientosSnapshot.exists) {
      final List<dynamic> fechasEntrenamiento = entrenamientosSnapshot.data()?['fechas_entrenamiento'] ?? [];
      setState(() {
        _markedDates = fechasEntrenamiento.map((timestamp) => (timestamp as Timestamp).toDate()).toList();
      });
    }
  }

  bool _isSameDay(DateTime day1, DateTime day2) {
    return day1.year == day2.year && day1.month == day2.month && day1.day == day2.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TableCalendar(
            calendarFormat: _calendarFormat,
            focusedDay: _focusedDay,
            firstDay: DateTime(2010),
            lastDay: DateTime(2030),
            selectedDayPredicate: (day) {
              final DateTime selectedDay = DateTime(day.year, day.month, day.day);
              return _markedDates.any((date) => _isSameDay(date, selectedDay));
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (_markedDates.any((markedDate) => _isSameDay(markedDate, DateTime(date.year, date.month, date.day)))) {
                  return Positioned(
                    right: 1,
                    bottom: 1,
                    child: Icon(
                      Icons.fitness_center,
                      size: 16,
                      color: Colors.blue,
                    ),
                  );
                }
                return null;
              },
            ),
            headerStyle: HeaderStyle(
              titleCentered: true,
            ),
          ),
        ),
      ),
    );
  }
}
