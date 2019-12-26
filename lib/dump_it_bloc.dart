import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';

class DumpItBloc extends Bloc<WorkflowEvent, WorkflowState> {
  @override
  WorkflowState get initialState => InitialWorkflowState();
  List<WorkflowState >_lastState = new List();
  @override
  Stream<WorkflowState> mapEventToState(
    WorkflowEvent event,
  ) async* {
    if (event is GoBack) {
      if (_lastState.length > 0) {
        yield _lastState.removeLast();
      } else {
        yield InitialWorkflowState();
      }
    }
    else if (event is NotActionable) {
      _lastState.add(InitialWorkflowState());
      yield NonActionableState();
    }
    else if (event is IsActionable) {
      _lastState.add(InitialWorkflowState());
      yield IsActionableState();
    }
    else if (event is LessThanTwoMinutes) {
      _lastState.add(IsActionableState());
      yield DoItNowState();
    } else if (event is MoreThanTwoMinutes) {
      _lastState.add(IsActionableState());
      yield DelegateOrDeferState();
    }
    else if (event is DelegateIt) {
      _lastState.add(DelegateOrDeferState());
      yield WaitForItState();
    } else if (event is DeferIt) {
      _lastState.add(DelegateOrDeferState());
      yield CalendarOrNextActionsState();
    }
  }
}
