import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:brain_dump/models/database_client.dart';
import 'package:brain_dump/models/next_actions/next_action.dart';
import 'package:brain_dump/models/next_actions/next_action_context.dart';
import 'package:brain_dump/models/next_actions/next_action_interface.dart';
import 'package:sqflite/sqflite.dart';
import './bloc.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {

  @override
  CalendarState get initialState => InitialCalendarState();

  @override
  Stream<CalendarState> mapEventToState(
      CalendarEvent event,
  ) async* {


  }




}
