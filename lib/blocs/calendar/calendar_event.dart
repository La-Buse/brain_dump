import 'file:///C:/Users/levas/source/repos/brain_dump/lib/models/db_models/unmanaged_item/unmanaged_item.dart';
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
