import 'dart:async';
import 'package:bloc/bloc.dart';

import 'package:brain_dump/models/db_models/calendar/calendar_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './bloc.dart';
import 'bloc.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  static DateTime now = DateTime.now();
  static DateTime _selectedDay = new DateTime.utc(now.year, now.month, now.day, 0);
  static Map<DateTime, List> _events = {

  };
  List _selectedDayEvents = _events[_selectedDay] ?? [];
  DateTime _newEventDate = _selectedDay;

  @override
  CalendarState get initialState => InitialCalendarState({}, [], _selectedDay, _newEventDate, '', '');

  @override
  Stream<CalendarState> mapEventToState(
      CalendarEvent event,
  ) async* {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    String userId = user.uid;
    if (event is FetchItemsEvent) {
      DateTime now = DateTime.now();
      _selectedDay = new DateTime.utc(now.year, now.month, now.day, 0);
      List<CalendarItem> items = [];
      if (event.start == null) {
        items = await CalendarItem.getInitialItems();
      } else {
        items = await CalendarItem.getItemsBetweenTwoDate(event.start, event.finish);
      }
      _events = {};
      for (int i=0; i<items.length; i++) {
        CalendarItem item = items[i];
        addItemToMap(item, _events);
      }
      _selectedDayEvents = _events[_selectedDay] ?? [];
      yield CalendarStateInitialized(_events, _selectedDayEvents, _selectedDay, _newEventDate, '','', -1);
    } else if (event is NewDaySelectedEvent) {
       _selectedDay = event.daySelected;
      _selectedDayEvents = _events[event.daySelected] ?? [];
      yield CalendarStateInitialized(_events, _selectedDayEvents, _selectedDay, _newEventDate, '', '', -1);
    } else if (event is NewEventDateSelected) {
      //event name and event description are known here because the user is in the process of creating a new event
      _newEventDate = event.daySelected;
      yield CalendarStateInitialized(_events, _selectedDayEvents, _selectedDay, _newEventDate, event.name, event.description,-1);
      /** ADD NEW EVENT **/
    } else if (event is AddNewCalendarEvent) {
      DateTime dateCreated = DateTime.now().toUtc();
      CalendarItem item = new CalendarItem();
      item.id = new DateTime.now().millisecondsSinceEpoch;
      item.name = event.name;
      item.description =  event.description;
      item.date = event.daySelected;
      item.dateCreated = dateCreated;
      item.addItemToFirestore(userId);
      addItemToMap(item, _events);
      if (_selectedDay == item.date) {
        _selectedDayEvents = _events[_selectedDay];
      }
      yield CalendarStateInitialized(_events, _selectedDayEvents, _selectedDay, _newEventDate, event.name, event.description, -1);
      /** DELETE EVENT **/
    } else if (event is DeleteCalendarEvent) {
      CalendarItem toBeDeleted = await CalendarItem().getItemById(event.item.id);
      await CalendarItem.deleteItem(event.item);
      toBeDeleted.deleteFirestoreItem(userId);
      List dayEvents = _events[event.item.date];
      for (int i=0; i<dayEvents.length; i++) {
        CalendarItem current = dayEvents[i];
        if (current.id == event.item.id) {
          dayEvents.remove(current);
        }
      }
      yield CalendarStateInitialized(_events, _selectedDayEvents, _selectedDay, _newEventDate, '', '', -1);
      /** EDIT EVENT **/
    } else if (event is EditCalendarEvent) {
      CalendarItem item = event.item;
      CalendarItem toBeUpdated = await CalendarItem().getItemById(event.item.id);
      toBeUpdated.name = item.name;
      toBeUpdated.description = item.description;
      toBeUpdated.date = item.date;
      toBeUpdated.updateFirestoreData(userId);
      await toBeUpdated.updateItemDbFields();
      List eventList = _events[item.date];
      for (int i=0; i<eventList.length; i++) {
        CalendarItem current = eventList[i];
        if (current.id == item.id) {
          eventList.remove(current);
          eventList.add(item);
        }
      }
      yield CalendarStateInitialized(_events, _selectedDayEvents, _selectedDay, _newEventDate, '', '', -1);
    }
  }

  void addItemToMap(CalendarItem item,  Map<DateTime, List> map) {
    if (map[item.date] == null) {
      List<CalendarItem> newList = [item];
      map[item.date] = newList;
    } else {
      map[item.date].add(item);
    }
  }




}
