import 'package:brain_dump/models/next_actions/next_action_interface.dart';
import 'package:meta/meta.dart';
import 'package:brain_dump/models/next_actions/next_action.dart';

@immutable
abstract class CalendarState {

  CalendarState();
}

class InitialCalendarState extends CalendarState {
  InitialCalendarState() : super();
}