import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:brain_dump/models/database_client.dart';
import 'package:brain_dump/models/db_models/next_actions/next_action.dart';
import 'package:brain_dump/models/db_models/next_actions/next_action_context.dart';
import 'package:brain_dump/models/db_models/next_actions/next_action_interface.dart';
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
      Firestore.instance.collection('users/' + userId + '/next_actions').add(
          addedAction.toFirestoreMap()
      ).then((value) async {
        NextAction toBeUpdated = await NextAction.getActionById(addedAction.id);
        if (toBeUpdated != null) {
          toBeUpdated.firestoreId = value.documentID;
          NextAction.editAction(toBeUpdated);
          Firestore.instance.collection('users/' + userId + '/next_actions').document(value.documentID).setData(toBeUpdated.toFirestoreMap());
        } else {
          Firestore.instance.collection('users/' + userId + '/next_actions').document(value.documentID).delete();
        }
      });
//      ref.documentID
      await NextAction.addNextActionToDb(addedAction);

      if (event.item != null) {

        //item went from being an unmanaged item to becoming a next action, so it must be deleted from Unmanaged item
        await DatabaseClient().delete(event.item.id, 'UnmanagedItem');
        var ref = await Firestore.instance.collection('users/' + userId + '/unmanaged_items').getDocuments();
        var documents = ref.documents.where((f) {return f['id'] == event.item.id;}).toList();
        documents.forEach((element) {
          Firestore.instance.collection('users/' + userId + '/unmanaged_items').document(element.documentID).delete();
        });

      }
      this.allActions.add(addedAction);
      yield InitializedNextActionsState(this.allActions, state.parentId);

    } else if (event is DeleteActionEvent) {
      NextAction toBeDeleted = await NextAction.getActionById(event.id);
      if (toBeDeleted.firestoreId != null) {
        Firestore.instance.collection('users/' + userId + '/next_actions').document(toBeDeleted.firestoreId).delete();
      }
      await NextAction.deleteNextAction(event.id);
      allActions.removeWhere((action) {return !action.isContext() && action.getId() == event.id; });
      yield InitializedNextActionsState(this.allActions, state.parentId);
    } else if (event is DeleteContextEvent) {
      List<NextActionContext> contexts = await _getAllContextsAssociatedWithContext(event.id);
      contexts.forEach((NextActionContext context) async {
        await NextActionContext.deleteActionContext(context.id);
        if (context.firestoreId != null) {
          Firestore.instance.collection('users/' + userId + '/next_actions_contexts').document(context.firestoreId).delete();
        }
      });
      List<NextAction> actions = await _getAllActionsAssociatedWithContext(contexts);
      actions.forEach((NextAction action) async {
        await NextAction.deleteNextAction(action.id);
        if (action.firestoreId != null) {
          Firestore.instance.collection('users/' + userId + '/next_actions').document(action.firestoreId).delete();
        }
      });
      await _setAllActions(event.parentId);
      yield InitializedNextActionsState(this.allActions, event.parentId);
    } else if (event is AddContextEvent) {
      NextActionContext context = new NextActionContext();
      context.id = new DateTime.now().millisecondsSinceEpoch;
      context.name = event.contextName;
      context.parentId = event.parentId;
      context.dateCreated = DateTime.now().toUtc();
      await NextActionContext.addActionContext(context);
      Firestore.instance.collection('users/' + userId + '/next_actions_contexts').add(
          context.toFirestoreMap()
      ).then((value) async {
        NextActionContext toBeUpdated = await NextActionContext.getContextById(context.id);
        if (toBeUpdated != null) {
          toBeUpdated.firestoreId = value.documentID;
          NextActionContext.editActionContext(toBeUpdated);
          Firestore.instance.collection('users/' + userId + '/next_actions_contexts').document(toBeUpdated.firestoreId).setData(toBeUpdated.toFirestoreMap());
        } else {
          //delete if item was deleted while offline
          Firestore.instance.collection('users/' + userId + '/next_actions_contexts').document(value.documentID).delete();
        }
      });
      this.allActions.add(context);
      yield InitializedNextActionsState(this.allActions, state.parentId);
    } else if (event is EditContextEvent) {
      NextActionContext toBeUpdated = await NextActionContext.getContextById(event.id);
      toBeUpdated.name = event.contextName;
      NextActionContext.editActionContext(toBeUpdated);
      NextActionContext edited = this.allActions.where((x) {
        return x.isContext() && x.getId() == event.id;
      }).toList()[0];
      edited.setName(event.contextName);
      if (toBeUpdated.firestoreId != null) {
        Firestore.instance.collection('users/' + userId + '/next_actions_contexts')
            .document(toBeUpdated.firestoreId)
            .updateData(toBeUpdated.toFirestoreMap());
      }
      yield InitializedNextActionsState(this.allActions, state.parentId);
    } else if (event is EditActionEvent) {
      NextAction toBeUpdated = await NextAction.getActionById(event.id);
      toBeUpdated.name = event.actionName;
      NextAction.editAction(toBeUpdated);
      NextAction edited = this.allActions.where((x) {
        return !x.isContext() && x.getId() == event.id;
      }).toList()[0];
      edited.name = event.actionName;
      if (toBeUpdated.firestoreId != null) {
        Firestore.instance.collection('users/' + userId + '/next_actions')
            .document(toBeUpdated.firestoreId)
            .updateData({"name": event.actionName});
      }
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
    List<NextActionContext> toCheck = [await NextActionContext.getContextById(contextId)];
    while (toCheck.length > 0) {
      NextActionContext current = toCheck.removeLast();
      result.add(await NextActionContext.getContextById(current.id));
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
