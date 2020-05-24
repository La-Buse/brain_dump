import 'package:meta/meta.dart';

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