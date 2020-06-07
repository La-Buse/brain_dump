import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:brain_dump/models/database_client.dart';
import 'package:brain_dump/models/db_models/calendar/calendar_item.dart';
import 'package:brain_dump/models/db_models/project/project.dart';
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
      List<CalendarItem> items = [];
      if (event.start == null) {
        items = await CalendarItem.getInitialItems();
      } else {
        items = await CalendarItem.getItemsBetweenTwoDate(event.start, event.finish);
      }
      _events = {};
      for (int i=0; i<items.length; i++) {
        CalendarItem item = items[i];
        if (_events[item.date] == null) {
          List<String> newList = [item.name];
          _events[item.date] = newList;
        } else {
          _events[item.date].add(item.name);
        }
      }
//      items.forEach((element) {
//        _events[element.date].add(element.name);
//      });
      yield CalendarStateInitialized(_events, _selectedDayEvents, _selectedDay, _newEventDate, '','');
    } else if (event is NewDaySelectedEvent) {
//      DateTime newDay = event.daySelected;
       _selectedDay = event.daySelected;
      _selectedDayEvents = _events[event.daySelected] ?? [];
      yield CalendarStateInitialized(_events, _selectedDayEvents, _selectedDay, _newEventDate, '', '');
    } else if (event is NewEventDateSelected) {
      //event name and event description are known here because the user is in the process of creating a new event
      _newEventDate = event.daySelected;
      yield CalendarStateInitialized(_events, _selectedDayEvents, _selectedDay, _newEventDate, event.name, event.description);
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
