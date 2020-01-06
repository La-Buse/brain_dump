import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:brain_dump/models/next_actions/next_action.dart';
import 'package:brain_dump/models/next_actions/next_action_context.dart';
import 'package:brain_dump/models/next_actions/next_action_interface.dart';
import './bloc.dart';

class NextActionsBloc extends Bloc<NextActionsEvent, NextActionsState> {
  List<NextActionInterface> allActions;


  @override
  NextActionsState get initialState => InitialNextActionsState();

  @override
  Stream<NextActionsState> mapEventToState(
    NextActionsEvent event,
  ) async* {
    if (event is FetchActionsEvent) {
      var actions = await NextAction.readNextActionsFromDb(event.parentId);
      var contexts = await NextActionContext.readContextsFromDb(event.parentId);
      this.allActions = new List.from(actions)..addAll(contexts);
      yield InitializedNextActionsState(this.allActions, state.parentId);
    }
    if (event is AddActionEvent) {
      NextAction addedAction = NextAction();
      addedAction.name = event.actionName;
      addedAction.parentId = event.parentId;
      addedAction.id = await NextAction.addNextActionToDb(addedAction);
      this.allActions.add(addedAction);
      yield InitializedNextActionsState(this.allActions, state.parentId);

    } else if (event is DeleteActionEvent) {
      await NextAction.deleteNextAction(event.id);
      allActions.removeWhere((action) {return action.getId() == event.id; });
      yield InitializedNextActionsState(this.allActions, state.parentId);
    } else if (event is AddContextEvent) {
      NextActionContext context = new NextActionContext();
      context.name = event.contextName;
      context.parentId = event.parentId;
      context.id = await NextActionContext.addActionContext(context);
      this.allActions.add(context);
      yield InitializedNextActionsState(this.allActions, state.parentId);
    }
  }

}
