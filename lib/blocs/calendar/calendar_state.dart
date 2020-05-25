import 'package:meta/meta.dart';

@immutable
abstract class CalendarState {
  final Map<DateTime, List> allEvents;
  final List selectedDayEvents;
  final DateTime selectedDay;
  final DateTime newEventDate;
  CalendarState(Map<DateTime, List> allEvents, List selectedDayEvents, DateTime selectedDay, DateTime newEventDate):
        this.allEvents=allEvents, this.selectedDayEvents = selectedDayEvents, this.selectedDay=selectedDay, this.newEventDate = newEventDate;
}

class InitialCalendarState extends CalendarState {
  InitialCalendarState(Map<DateTime, List> allEvents, List selectedDayEvents, DateTime selectedDay, DateTime newEventDate) : super(allEvents, selectedDayEvents, selectedDay, null);
}