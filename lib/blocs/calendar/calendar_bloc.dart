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
      _selectedDayEvents = _events[_selectedDay];
      yield CalendarStateInitialized(_events, _selectedDayEvents, _selectedDay, _newEventDate, '','', -1);
    } else if (event is NewDaySelectedEvent) {
       _selectedDay = event.daySelected;
      _selectedDayEvents = _events[event.daySelected] ?? [];
      yield CalendarStateInitialized(_events, _selectedDayEvents, _selectedDay, _newEventDate, '', '', -1);
    } else if (event is NewEventDateSelected) {
      //event name and event description are known here because the user is in the process of creating a new event
      _newEventDate = event.daySelected;
      yield CalendarStateInitialized(_events, _selectedDayEvents, _selectedDay, _newEventDate, event.name, event.description,-1);
    } else if (event is AddNewCalendarEvent) {
      DateTime dateCreated = DateTime.now().toUtc();
      CalendarItem item = new CalendarItem();
      item.name = event.name;
      item.description =  event.description;
      item.date = event.daySelected;;
      item.dateCreated = dateCreated;
      int id = await CalendarItem.addCalendarItemToDb(item);
      item.id = id;
      addItemToMap(item, _events);
      if (_selectedDay == item.date) {
        _selectedDayEvents.add(item);
      }
      Firestore.instance.collection('users/' + userId + '/calendar_events').add(
        {
          'name': event.name,
          'description': event.description,
          'date': event.daySelected,
          'date_created': dateCreated,
          'id' : id
        }
      );
      yield CalendarStateInitialized(_events, _selectedDayEvents, _selectedDay, _newEventDate, event.name, event.description, -1);

    } else if (event is DeleteCalendarEvent) {
      CalendarItem.deleteItem(event.item);
      var deletedDocuments = await Firestore.instance.collection('users/' + userId + '/calendar_events').where("id", isEqualTo: event.item.id).getDocuments();
      deletedDocuments.documents.forEach((element) async {
        await Firestore.instance.collection('users/' + userId + '/calendar_events').document(element.documentID).delete();
      });
      List dayEvents = _events[event.item.date];
      for (int i=0; i<dayEvents.length; i++) {
        CalendarItem current = dayEvents[i];
        if (current.id == event.item.id) {
          dayEvents.remove(current);
        }
      }
      yield CalendarStateInitialized(_events, _selectedDayEvents, _selectedDay, _newEventDate, '', '', -1);
    } else if (event is EditCalendarEvent) {
      CalendarItem item = event.item;
      var modifiedDocuments = await Firestore.instance.collection('users/' + userId + '/calendar_events').where("id", isEqualTo: event.item.id).getDocuments();
      modifiedDocuments.documents.forEach((element) async {
        await Firestore.instance.collection('users/' + userId + '/calendar_events').document(element.documentID).setData({
          'id':item.id,
          'description':item.description,
          'name': item.name,
          'date':item.date,
          'date_created':item.dateCreated
        });
      });
      await CalendarItem.updateCalendarItemDbFields(item);
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
