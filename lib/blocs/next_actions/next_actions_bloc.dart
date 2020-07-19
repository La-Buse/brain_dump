import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:brain_dump/models/database_client.dart';
import 'package:brain_dump/models/db_models/next_actions/next_action.dart';
import 'package:brain_dump/models/db_models/next_actions/next_action_context.dart';
import 'package:brain_dump/models/db_models/next_actions/next_action_interface.dart';
import 'package:brain_dump/models/db_models/unmanaged_item/unmanaged_item.dart';
import './bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    String userId = user.uid;
    if (event is AddActionEvent) {
      NextAction addedAction = NextAction();
      addedAction.id = new DateTime.now().millisecondsSinceEpoch;
      addedAction.name = event.actionName;
      addedAction.parentId = event.parentId;
      addedAction.dateCreated = DateTime.now().toUtc();
      addedAction.addItemToFirestore(userId);

      if (event.item != null) {
        UnmanagedItem emptyItem = UnmanagedItem();
        //item went from being an unmanaged item to becoming a next action, so it must be deleted from Unmanaged item
        await DatabaseClient().delete(event.item.id, 'UnmanagedItem');
        var ref = await emptyItem.getItemFirestoreCollection(userId).getDocuments();
        var documents = ref.documents.where((f) {return f['id'] == event.item.id;}).toList();
        documents.forEach((element) {
          emptyItem.getItemFirestoreCollection(userId).document(element.documentID).delete();
        });

      }
      this.allActions.add(addedAction);
      yield InitializedNextActionsState(this.allActions, state.parentId);

    } else if (event is DeleteActionEvent) {
      NextAction toBeDeleted = await new NextAction().getItemById(event.id);
      toBeDeleted.deleteFirestoreItem(userId);
      await NextAction.deleteNextAction(event.id);
      allActions.removeWhere((action) {return !action.isContext() && action.getId() == event.id; });
      yield InitializedNextActionsState(this.allActions, state.parentId);
    } else if (event is DeleteContextEvent) {
      List<NextActionContext> contexts = await _getAllContextsAssociatedWithContext(event.id);
      contexts.forEach((NextActionContext context) async {
        await NextActionContext.deleteActionContext(context.id);
        context.deleteFirestoreItem(userId);
      });
      List<NextAction> actions = await _getAllActionsAssociatedWithContext(contexts);
      actions.forEach((NextAction action) async {
        await NextAction.deleteNextAction(action.id);
        action.deleteFirestoreItem(userId);
      });
      await _setAllActions(event.parentId);
      yield InitializedNextActionsState(this.allActions, event.parentId);
    } else if (event is AddContextEvent) {
      NextActionContext context = new NextActionContext();
      context.id = new DateTime.now().millisecondsSinceEpoch;
      context.name = event.contextName;
      context.parentId = event.parentId;
      context.dateCreated = DateTime.now().toUtc();
      context.addItemToFirestore(userId);
      this.allActions.add(context);
      yield InitializedNextActionsState(this.allActions, state.parentId);
    } else if (event is EditContextEvent) {
      NextActionContext toBeUpdated = await NextActionContext().getItemById(event.id);
      toBeUpdated.name = event.contextName;
      toBeUpdated.updateItemDbFields();
      toBeUpdated.updateFirestoreData(userId);
      //modify in memory items
      NextActionContext edited = this.allActions.where((x) {
        return x.isContext() && x.getId() == event.id;
      }).toList()[0];
      edited.setName(event.contextName);
      yield InitializedNextActionsState(this.allActions, state.parentId);
    } else if (event is EditActionEvent) {
      NextAction toBeUpdated = await new NextAction().getItemById(event.id);
      toBeUpdated.name = event.actionName;
      toBeUpdated.updateItemDbFields();
      toBeUpdated.updateFirestoreData(userId);

      NextAction edited = this.allActions.where((x) {
        return !x.isContext() && x.getId() == event.id;
      }).toList()[0];
      edited.name = event.actionName;
      yield InitializedNextActionsState(this.allActions, state.parentId);
      //TODO edit in firebase
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
    var actions = await NextAction.readAll(parentId);
    var contexts = await NextActionContext.readContextsFromDb(parentId);
    this.allActions = new List.from(actions)..addAll(contexts);
  }

  Future<List<NextActionContext>> _getAllContextsAssociatedWithContext(int contextId) async {
    List<NextActionContext> result = [];
    List<NextActionContext> toCheck = [await new NextActionContext().getItemById(contextId)];
    while (toCheck.length > 0) {
      NextActionContext current = toCheck.removeLast();
      result.add(await new NextActionContext().getItemById(current.id));
      List<NextActionContext> newContexts = await NextActionContext.readContextsFromDb(current.id);
      result..addAll(newContexts);
      result = result.toSet().toList();
      toCheck..addAll(newContexts);
      toCheck = toCheck.toSet().toList();
    }
    return result;
  }

  Future<List<NextAction>> _getAllActionsAssociatedWithContext(List<NextActionContext> contexts) async {
    List<NextAction> result = [];
    while (contexts.length > 0) {
      NextActionContext current = contexts.removeLast();
      List<NextAction> actions = await NextAction.readAll(current.id);
      result..addAll(actions.map((NextAction a) {
        return a;
      }));
    }
    return result;
  }
}
