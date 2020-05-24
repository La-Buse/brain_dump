import 'package:brain_dump/models/next_actions/next_action_interface.dart';
import 'package:meta/meta.dart';
import 'package:brain_dump/models/next_actions/next_action.dart';

@immutable
abstract class CalendarState {
  final Map<DateTime, List> allEvents;
  final List selectedDayEvents;
  final DateTime selectedDay;
  CalendarState(Map<DateTime, List> allEvents, List selectedDayEvents, DateTime selectedDay):
        this.allEvents=allEvents, this.selectedDayEvents = selectedDayEvents, this.selectedDay=selectedDay;
}

class InitialCalendarState extends CalendarState {
  InitialCalendarState(Map<DateTime, List> allEvents, List selectedDayEvents, DateTime selectedDay) : super(allEvents, selectedDayEvents, selectedDay);
}