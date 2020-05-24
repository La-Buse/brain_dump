import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:brain_dump/blocs/calendar/bloc.dart';
import 'package:brain_dump/widgets/confirmation_dialog.dart';

class Calendar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _CalendarState();
  }
}

class _CalendarState extends State<Calendar> {
  final calendarBloc = CalendarBloc();
  final CalendarController calendarController = new CalendarController();
  Map<DateTime, List> _events;
  List _selectedEvents;
  @override
  Widget build(BuildContext context) {
    return new BlocBuilder(
      bloc: calendarBloc,
        builder: (BuildContext context, CalendarState state) {
        Map<CalendarFormat,String> calendarFormat = new Map<CalendarFormat, String>();
        calendarFormat.putIfAbsent(CalendarFormat.month, () => 'month');
//        final _selectedDay = DateTime.now();
//        _events = {
//          _selectedDay.subtract(Duration(days: 30)): ['Event A0', 'Event B0', 'Event C0'],
//          _selectedDay.subtract(Duration(days: 27)): ['Event A1'],
//          _selectedDay.subtract(Duration(days: 20)): ['Event A2', 'Event B2', 'Event C2', 'Event D2'],
//          _selectedDay.subtract(Duration(days: 16)): ['Event A3', 'Event B3'],
//          _selectedDay.subtract(Duration(days: 10)): ['Event A4', 'Event B4', 'Event C4'],
//          _selectedDay.subtract(Duration(days: 4)): ['Event A5', 'Event B5', 'Event C5'],
//          _selectedDay.subtract(Duration(days: 2)): ['Event A6', 'Event B6'],
//          _selectedDay: ['Event A7', 'Event B7', 'Event C7', 'Event D7'],
//          _selectedDay.add(Duration(days: 1)): ['Event A8', 'Event B8', 'Event C8', 'Event D8'],
//          _selectedDay.add(Duration(days: 3)): Set.from(['Event A9', 'Event A9', 'Event B9']).toList(),
//          _selectedDay.add(Duration(days: 7)): ['Event A10', 'Event B10', 'Event C10'],
//          _selectedDay.add(Duration(days: 11)): ['Event A11', 'Event B11'],
//          _selectedDay.add(Duration(days: 17)): ['Event A12', 'Event B12', 'Event C12', 'Event D12'],
//          _selectedDay.add(Duration(days: 22)): ['Event A13', 'Event B13'],
//          _selectedDay.add(Duration(days: 26)): ['Event A14', 'Event B14', 'Event C14'],
//        };
//        _selectedEvents = _events[_selectedDay] ?? [];
          return Scaffold(
            appBar: new AppBar(

              title: new Text("Calendar"),
            ),
            body: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                TableCalendar(
                  availableCalendarFormats: calendarFormat,
                  calendarStyle: CalendarStyle(
                      todayColor: Colors.orange,
                      selectedColor: Theme.of(context).primaryColor
                  ),
                  calendarController: calendarController,
                  events: state.allEvents,
                  onDaySelected: (date, events) {
                    calendarBloc.add(NewDaySelectedEvent(date));
                  },
                ),
                Expanded(child:_buildEventList(state))
              ],
            )
          );
        }
    );

  }

  Widget _buildEventList(CalendarState state) {

    return ListView(
      children: state.selectedDayEvents
          .map((event) => Container(
        decoration: BoxDecoration(
          border: Border.all(width: 0.8),
          borderRadius: BorderRadius.circular(12.0),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: ListTile(
          title: Text(event.toString()),
          onTap: () => print('$event tapped!'),
        ),
      ))
          .toList(),
    );
  }

  @override
  void dispose() {
    super.dispose();
    calendarBloc.close();
  }
}