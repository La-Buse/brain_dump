import 'package:brain_dump/models/next_actions/next_action.dart';
import 'package:brain_dump/models/unmanaged_item.dart';
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
