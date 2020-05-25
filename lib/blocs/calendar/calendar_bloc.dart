import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:brain_dump/models/database_client.dart';
import 'package:sqflite/sqflite.dart';
import './bloc.dart';
import 'bloc.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  static DateTime now = DateTime.now();
  static DateTime _selectedDay = new DateTime.utc(now.year, now.month, now.day, 12);
  static Map<DateTime, List> _events = {
          _selectedDay.subtract(Duration(days: 30)): ['Event A0', 'Event B0', 'Event C0'],
          _selectedDay.subtract(Duration(days: 27)): ['Event A1'],
          _selectedDay.subtract(Duration(days: 20)): ['Event A2', 'Event B2', 'Event C2', 'Event D2'],
          _selectedDay.subtract(Duration(days: 16)): ['Event A3', 'Event B3'],
          _selectedDay.subtract(Duration(days: 10)): ['Event A4', 'Event B4', 'Event C4'],
          _selectedDay.subtract(Duration(days: 4)): ['Event A5', 'Event B5', 'Event C5'],
          _selectedDay.subtract(Duration(days: 2)): ['Event A6', 'Event B6'],
          _selectedDay: ['Event A7', 'Event B7', 'Event C7', 'Event D7'],
          _selectedDay.add(Duration(days: 1)): ['Event A8', 'Event B8', 'Event C8', 'Event D8'],
          _selectedDay.add(Duration(days: 3)): Set.from(['Event A9', 'Event A9', 'Event B9']).toList(),
          _selectedDay.add(Duration(days: 7)): ['Event A10', 'Event B10', 'Event C10'],
          _selectedDay.add(Duration(days: 11)): ['Event A11', 'Event B11'],
          _selectedDay.add(Duration(days: 17)): ['Event A12', 'Event B12', 'Event C12', 'Event D12'],
          _selectedDay.add(Duration(days: 22)): ['Event A13', 'Event B13'],
          _selectedDay.add(Duration(days: 26)): ['Event A14', 'Event B14', 'Event C14'],
  };
  List _selectedDayEvents = _events[_selectedDay] ?? [];
  DateTime _newEventDate = _selectedDay;

  @override
  CalendarState get initialState => InitialCalendarState(_events, _selectedDayEvents, _selectedDay, _newEventDate);

  @override
  Stream<CalendarState> mapEventToState(
      CalendarEvent event,
  ) async* {
    if (event is NewDaySelectedEvent) {
//      DateTime newDay = event.daySelected;
       _selectedDay = event.daySelected;
      _selectedDayEvents = _events[event.daySelected] ?? [];
      yield InitialCalendarState(_events, _selectedDayEvents, _selectedDay, _newEventDate);
    } else if (event is NewEventDateSelected) {
      _newEventDate = event.daySelected;
      yield InitialCalendarState(_events, _selectedDayEvents, _selectedDay, _newEventDate);
    }

  }




}
