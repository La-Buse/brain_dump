import 'package:brain_dump/models/db_models/unmanaged_item/unmanaged_item.dart';
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
    AddNewCalendarEvent(String name, String description, DateTime daySelected):this.name = name, this.description = description, this.daySelected = daySelected;
}
