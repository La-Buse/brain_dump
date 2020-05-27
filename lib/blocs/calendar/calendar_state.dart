import 'package:meta/meta.dart';

@immutable
abstract class CalendarState {
  final Map<DateTime, List> allEvents;
  final List selectedDayEvents;
  final DateTime selectedDay;
  final DateTime newEventDate;
  final String name;
  final String description;

  CalendarState(Map<DateTime, List> allEvents, List selectedDayEvents, DateTime selectedDay, DateTime newEventDate, String name, String description):
        this.allEvents=allEvents, this.selectedDayEvents = selectedDayEvents, this.selectedDay=selectedDay, this.newEventDate = newEventDate, this.name = name, this.description = description;
}

class InitialCalendarState extends CalendarState {
  InitialCalendarState(Map<DateTime, List> allEvents, List selectedDayEvents, DateTime selectedDay, DateTime newEventDate, String name, String description) :
        super(allEvents, selectedDayEvents, selectedDay, newEventDate, name, description);
}