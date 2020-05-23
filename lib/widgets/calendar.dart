import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _CalendarState();
  }
}

class _CalendarState extends State<Calendar> {
  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      //calendarController: _calendarController,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}