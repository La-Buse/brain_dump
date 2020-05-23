import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:brain_dump/blocs/calendar/bloc.dart';

class Calendar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _CalendarState();
  }
}

class _CalendarState extends State<Calendar> {
  final calendarBloc = CalendarBloc();
  final CalendarController calendarController = new CalendarController();
  @override
  Widget build(BuildContext context) {
    return new BlocBuilder(
      bloc: calendarBloc,
        builder: (BuildContext context, CalendarState state) {
        Map<CalendarFormat,String> calendarFormat = new Map<CalendarFormat, String>();
        calendarFormat.putIfAbsent(CalendarFormat.month, () => 'month');
          return Scaffold(
            appBar: new AppBar(

              title: new Text("Calendar"),
            ),
            body:TableCalendar(
              availableCalendarFormats: calendarFormat,
              calendarStyle: CalendarStyle(
                todayColor: Colors.orange,
                selectedColor: Theme.of(context).primaryColor
              ),
              calendarController: calendarController,
            ),
          );
        }
    );

  }

  @override
  void dispose() {
    super.dispose();
    calendarBloc.close();
  }
}