import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:brain_dump/models/next_actions/next_action_interface.dart';
import './bloc.dart';

class NextActionsBloc extends Bloc<NextActionsEvent, NextActionsState> {
  List<NextActionInterface> actions;

  @override
  NextActionsState get initialState => InitialNextActionsState();

  @override
  Stream<NextActionsState> mapEventToState(
    NextActionsEvent event,
  ) async* {
    if (event is AddActionEvent) {

    }
  }
}
