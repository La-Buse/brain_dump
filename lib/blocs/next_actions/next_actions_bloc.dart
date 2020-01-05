import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:brain_dump/models/next_actions/next_action.dart';
import 'package:brain_dump/models/next_actions/next_action_context.dart';
import 'package:brain_dump/models/next_actions/next_action_interface.dart';
import './bloc.dart';

class NextActionsBloc extends Bloc<NextActionsEvent, NextActionsState> {
  List<NextAction> actions;
  List<NextActionContext> contexts;

  @override
  NextActionsState get initialState => InitialNextActionsState();

  @override
  Stream<NextActionsState> mapEventToState(
    NextActionsEvent event,
  ) async* {
    if (event is FetchActionsEvent) {
      actions = await NextAction.readNextActionsFromDb(event.parentId);
      contexts = await NextActionContext.readContextsFromDb(event.parentId);
      yield InitializedNextActionsState(combineActionsAndContexts(), state.parentId);
    }
    if (event is AddActionEvent) {
      NextAction addedAction = NextAction();
      addedAction.name = event.actionName;
      addedAction.parentId = event.parentId;
      addedAction.id = await NextAction.addNextActionToDb(addedAction);
      this.actions.add(addedAction);
      List<NextActionInterface> all = new List.from(actions)..addAll(contexts);
      yield InitializedNextActionsState(combineActionsAndContexts(), state.parentId);

    } else if (event is DeleteActionEvent) {
      await NextAction.deleteNextAction(event.id);
      actions.removeWhere((action) {return action.id == event.id; });
      yield InitializedNextActionsState(combineActionsAndContexts(), state.parentId);
    }
  }

  List<NextActionInterface> combineActionsAndContexts() {
    List<NextActionInterface> all = new List.from(actions)..addAll(contexts);
    return all;
  }
}
