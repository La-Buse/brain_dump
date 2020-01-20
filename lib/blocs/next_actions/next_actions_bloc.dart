import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:brain_dump/models/database_client.dart';
import 'package:brain_dump/models/next_actions/next_action.dart';
import 'package:brain_dump/models/next_actions/next_action_context.dart';
import 'package:brain_dump/models/next_actions/next_action_interface.dart';
import 'package:sqflite/sqflite.dart';
import './bloc.dart';

class NextActionsBloc extends Bloc<NextActionsEvent, NextActionsState> {
  List<NextActionInterface> allActions;
  List<int> contextIdsStack = [];
  List<String> contextNamesStack = [];

  @override
  NextActionsState get initialState => InitialNextActionsState();

  @override
  Stream<NextActionsState> mapEventToState(
    NextActionsEvent event,
  ) async* {
    if (event is FetchActionsEvent) {
      await _setAllActions(event.parentId);
      yield InitializedNextActionsState(this.allActions, state.parentId);
    }
    if (event is AddActionEvent) {
      NextAction addedAction = NextAction();
      addedAction.name = event.actionName;
      addedAction.parentId = event.parentId;
      addedAction.id = await NextAction.addNextActionToDb(addedAction);
      if (event.item != null) {
        await DatabaseClient().delete(event.item.id, 'UnmanagedItem');
      }
      this.allActions.add(addedAction);
      yield InitializedNextActionsState(this.allActions, state.parentId);

    } else if (event is DeleteActionEvent) {
      await NextAction.deleteNextAction(event.id);
      allActions.removeWhere((action) {return !action.isContext() && action.getId() == event.id; });
      yield InitializedNextActionsState(this.allActions, state.parentId);
    } else if (event is DeleteContextEvent) {
      List<int> contextIds = await _getAllContextIdsAssociatedWithContext(event.id);
      contextIds.forEach((int id) async {
        await NextActionContext.deleteActionContext(id);
      });
      List<int> actionIds = await _getAllActionIdsAssociatedWithContext(contextIds);
      actionIds.forEach((int id) async {
        await NextAction.deleteNextAction(id);
      });
      await _setAllActions(event.parentId);
      yield InitializedNextActionsState(this.allActions, event.parentId);
    } else if (event is AddContextEvent) {
      NextActionContext context = new NextActionContext();
      context.name = event.contextName;
      context.parentId = event.parentId;
      context.id = await NextActionContext.addActionContext(context);
      this.allActions.add(context);
      yield InitializedNextActionsState(this.allActions, state.parentId);
    } else if (event is EditContextEvent) {
      NextActionContext.editActionContext(event.id, event.contextName);
      NextActionContext edited = this.allActions.where((x) {
        return x.isContext() && x.getId() == event.id;
      }).toList()[0];
      edited.setName(event.contextName);
      yield InitializedNextActionsState(this.allActions, state.parentId);
    } else if (event is EditActionEvent) {
      NextAction.editAction(event.id, event.actionName);
      NextAction edited = this.allActions.where((x) {
        return !x.isContext() && x.getId() == event.id;
      }).toList()[0];
      edited.name = event.actionName;
      yield InitializedNextActionsState(this.allActions, state.parentId);
    } else if (event is ChangeContextEvent) {
      this.contextIdsStack.add(event.parentId);
      this.contextNamesStack.add(event.contextName);
      await this._setAllActions(event.parentId);
      yield InitializedNextActionsState(
          this.allActions,
          event.parentId,
          contextName: event.contextName);
    } else if (event is GoBackContextEvent) {
      this.contextIdsStack.removeLast();
      int currentParentId =
        this.contextIdsStack.length > 0 ? this.contextIdsStack.last : -1;
      this.contextNamesStack.removeLast();
      String currentContextName =
        this.contextNamesStack.length > 0 ? this.contextNamesStack.last : '';

      await _setAllActions(currentParentId);
      yield InitializedNextActionsState(
          this.allActions,
          currentParentId,
          contextName: currentContextName
      );
    }
  }

  Future<void> _setAllActions(int parentId) async {
    var actions = await NextAction.readNextActionsFromDb(parentId);
    var contexts = await NextActionContext.readContextsFromDb(parentId);
    this.allActions = new List.from(actions)..addAll(contexts);
  }

  Future<List<int>> _getAllContextIdsAssociatedWithContext(int contextId) async {
    List<int> result = [];
    List<int> toCheck = [contextId];
    while (toCheck.length > 0) {
      int current = toCheck.removeLast();
      result.add(current);
      List<NextActionContext> newContexts = await NextActionContext.readContextsFromDb(current);
      List<int> contextIds = [];
      contextIds = newContexts.map((NextActionContext c) {
        return c.id;
      }).toList();

      result..addAll(contextIds);
      result = result.toSet().toList();
      toCheck..addAll(contextIds);
      toCheck = toCheck.toSet().toList();
    }
    return result;
  }

  Future<List<int>> _getAllActionIdsAssociatedWithContext(List<int> contextIds) async {
    List<int> result = [];
    while (contextIds.length > 0) {
      int current = contextIds.removeLast();
      List<NextAction> actions = await NextAction.readNextActionsFromDb(current);
      result..addAll(actions.map((NextAction a) {
        return a.id;
      }));
    }
    return result;
  }

}
