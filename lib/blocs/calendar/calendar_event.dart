import 'package:brain_dump/models/db_models/calendar/calendar_item.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@immutable
abstract class CalendarEvent {
    CalendarEvent();
}

class InitialCalendarEvent extends CalendarEvent {

}

class NewDaySelectedEvent extends CalendarEvent {
    final DateTime daySelected;
    NewDaySelectedEvent(DateTime daySelected):this.daySelected = daySelected;
}

class NewEventDateSelected extends CalendarEvent {
    final DateTime daySelected;
    final String name;
    final String description;
    NewEventDateSelected(String name, String description, DateTime daySelected):this.name = name, this.description = description, this.daySelected = daySelected;
}

class AddNewCalendarEvent extends CalendarEvent {
    final String name;
    final String description;
    final DateTime daySelected;
    final CalendarItem calendarItem;
    AddNewCalendarEvent(String name, String description, DateTime daySelected, CalendarItem item):this.name = name, this.description = description, this.daySelected = daySelected, this.calendarItem = item;
}

class EditCalendarEvent extends CalendarEvent {
    final CalendarItem item;
    EditCalendarEvent(CalendarItem item): this.item=item;
}

class FetchItemsEvent extends CalendarEvent {
    final DateTime start;
    final DateTime finish;
    FetchItemsEvent(DateTime start, DateTime finish): this.start = start, this.finish = finish;
}

class DeleteCalendarEvent extends CalendarEvent {
    final CalendarItem item;
    DeleteCalendarEvent(CalendarItem item): this.item = item;
}

class GetEditedEventInfos extends CalendarEvent {
    final CalendarItem item;
    GetEditedEventInfos(CalendarItem item): this.item = item;
}