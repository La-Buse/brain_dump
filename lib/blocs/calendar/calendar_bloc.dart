import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:brain_dump/models/database_client.dart';
import 'package:brain_dump/models/db_models/calendar/calendar_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import './bloc.dart';
import 'bloc.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  static DateTime now = DateTime.now();
  static DateTime _selectedDay = new DateTime.utc(now.year, now.month, now.day, 12);
  static Map<DateTime, List> _events = {
          _selectedDay.subtract(Duration(days: 30)): ['Event A0', 'Event B0', 'Event C0'],
  };
  List _selectedDayEvents = _events[_selectedDay] ?? [];
  DateTime _newEventDate = _selectedDay;

  @override
  CalendarState get initialState => InitialCalendarState({}, [], _selectedDay, _newEventDate, '', '');

  @override
  Stream<CalendarState> mapEventToState(
      CalendarEvent event,
  ) async* {
    if (event is FetchItemsEvent) {
      var events = CalendarItem.getInitialEvents();
    } else if (event is NewDaySelectedEvent) {
//      DateTime newDay = event.daySelected;
       _selectedDay = event.daySelected;
      _selectedDayEvents = _events[event.daySelected] ?? [];
      Firestore.instance.collection('chats/Q3jRiyJT8Svec9E66A1k/messages').snapshots().listen((data) {
        print(data.documents.first['text']);
      });
      yield InitialCalendarState(_events, _selectedDayEvents, _selectedDay, _newEventDate, '', '');
    } else if (event is NewEventDateSelected) {
      _newEventDate = event.daySelected;
      yield InitialCalendarState(_events, _selectedDayEvents, _selectedDay, _newEventDate, event.name, event.description);
    } else if (event is AddNewCalendarEvent) {
      DateTime dateCreated = DateTime.now().toUtc();
      CalendarItem item = new CalendarItem();
      item.name = event.name;
      item.description =  event.description;
      item.date = event.daySelected;
      item.dateCreated = dateCreated;
      CalendarItem.addCalendarItemToDb(item);
      Firestore.instance.collection('calendarEvents').add(
        {
          'name': event.name,
          'description': event.description,
          'date': event.daySelected,
          'date_created': dateCreated,
          'userId' : 1
        }
      );
      print(event.name);
    }

  }




}
