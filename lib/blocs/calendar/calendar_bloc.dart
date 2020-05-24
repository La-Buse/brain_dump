import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:brain_dump/models/database_client.dart';
import 'package:sqflite/sqflite.dart';
import './bloc.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  static DateTime now = DateTime.now();
  static DateTime _selectedDay = new DateTime.utc(now.year, now.month, now.day, 12);
  static Map<DateTime, List> _events = {
//    _selectedDay.subtract(Duration(days: 30)).toUtc(): ['Event A0', 'Event B0', 'Event C0'],
//    _selectedDay.subtract(Duration(days: 27)).toUtc(): ['Event A1'],
//    _selectedDay.subtract(Duration(days: 20)).toUtc(): ['Event A2', 'Event B2', 'Event C2', 'Event D2'],
//    _selectedDay.subtract(Duration(days: 16)).toUtc(): ['Event A3', 'Event B3'],
//    _selectedDay.subtract(Duration(days: 10)).toUtc(): ['Event A4', 'Event B4', 'Event C4'],
//    _selectedDay.subtract(Duration(days: 4)).toUtc(): ['Event A5', 'Event B5', 'Event C5'],
//    _selectedDay.subtract(Duration(days: 2)).toUtc(): ['Event A6', 'Event B6'],
//    _selectedDay: ['Event A7', 'Event B7', 'Event C7', 'Event D7'],
//    _selectedDay.add(Duration(days: 1)).toUtc(): ['Event A8', 'Event B8', 'Event C8', 'Event D8'],
//    _selectedDay.add(Duration(days: 3)).toUtc(): Set.from(['Event A9', 'Event A9', 'Event B9']).toList(),
//    _selectedDay.add(Duration(days: 7)).toUtc(): ['Event A10', 'Event B10', 'Event C10'],
//    _selectedDay.add(Duration(days: 11)).toUtc(): ['Event A11', 'Event B11'],
//    _selectedDay.add(Duration(days: 17)).toUtc(): ['Event A12', 'Event B12', 'Event C12', 'Event D12'],
//    _selectedDay.add(Duration(days: 22)).toUtc(): ['Event A13', 'Event B13'],
//    _selectedDay.add(Duration(days: 26)).toUtc(): ['Event A14', 'Event B14', 'Event C14'],
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
//        };
  };
  List selectedDayEvents = _events[_selectedDay] ?? [];

  @override
  CalendarState get initialState => InitialCalendarState(_events, selectedDayEvents, _selectedDay);

  @override
  Stream<CalendarState> mapEventToState(
      CalendarEvent event,
  ) async* {
    if (event is NewDaySelectedEvent) {
//      DateTime newDay = event.daySelected;
      List events = _events[event.daySelected] ?? [];
      yield InitialCalendarState(_events, events, event.daySelected);
    }

  }




}
