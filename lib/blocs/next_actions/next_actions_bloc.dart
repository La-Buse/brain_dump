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
      addedAction.name = event.actionName;
      addedAction.parentId = event.parentId;
      addedAction.dateCreated = DateTime.now().toUtc();
      addedAction.id = await NextAction.addNextActionToDb(addedAction);

      DocumentReference ref = await Firestore.instance.collection('users/' + userId + '/next_actions').add(
          {
            'name': addedAction.name,
            'id': addedAction.id,
            'parent_id': addedAction.parentId,
            'date_accomplished': addedAction.dateAccomplished,
            'date_created': addedAction.dateCreated,
          }
      );

      if (event.item != null) {

        //item went from being an unmanaged item to becoming a next action, so it must be deleted from Unmanaged item
        await DatabaseClient().delete(event.item.id, 'UnmanagedItem');
      }
      this.allActions.add(addedAction);
      yield InitializedNextActionsState(this.allActions, state.parentId);

    } else if (event is DeleteActionEvent) {
      await NextAction.deleteNextAction(event.id);
      var ref = await Firestore.instance.collection('users/' + userId + '/next_actions').getDocuments();
      var documents = ref.documents.where((f) {return f['id'] == event.id;}).toList();
      documents.forEach((element) {
        Firestore.instance.collection('users/' + userId + '/next_actions').document(element.documentID).delete();
      });
      allActions.removeWhere((action) {return !action.isContext() && action.getId() == event.id; });
      yield InitializedNextActionsState(this.allActions, state.parentId);
    } else if (event is DeleteContextEvent) {
      List<int> contextIds = await _getAllContextIdsAssociatedWithContext(event.id);
      var firestoreActionContexts = await Firestore.instance.collection('users/' + userId + '/next_actions_contexts').getDocuments();
      var firestoreActions = await Firestore.instance.collection('users/' + userId + '/next_actions').getDocuments();
      contextIds.forEach((int id) async {
        await NextActionContext.deleteActionContext(id);
        var documents = firestoreActionContexts.documents.where((f) {return f['id'] == id;}).toList();
        documents.forEach((element) {
          Firestore.instance.collection('users/' + userId + '/next_actions_contexts').document(element.documentID).delete();
        });
      });
      List<int> actionIds = await _getAllActionIdsAssociatedWithContext(contextIds);
      actionIds.forEach((int id) async {
        await NextAction.deleteNextAction(id);
        var documents = firestoreActions.documents.where((f) {return f['id'] == id;}).toList();
        documents.forEach((element) {
          Firestore.instance.collection('users/' + userId + '/next_actions').document(element.documentID).delete();
        });
      });
      await _setAllActions(event.parentId);
      yield InitializedNextActionsState(this.allActions, event.parentId);
    } else if (event is AddContextEvent) {
      NextActionContext context = new NextActionContext();
      context.name = event.contextName;
      context.parentId = event.parentId;
      context.dateCreated = DateTime.now().toUtc();
      context.id = await NextActionContext.addActionContext(context);
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      String userId = user.uid;
      DocumentReference ref = await Firestore.instance.collection('users/' + userId + '/next_actions_contexts').add(
          {
            'name': context.name,
            'id': context.id,
            'parent_id': context.parentId,
            'date_created': context.dateCreated,
          }
      );
      this.allActions.add(context);
      yield InitializedNextActionsState(this.allActions, state.parentId);
    } else if (event is EditContextEvent) {
      NextActionContext.editActionContext(event.id, event.contextName);
      NextActionContext edited = this.allActions.where((x) {
        return x.isContext() && x.getId() == event.id;
      }).toList()[0];
      edited.setName(event.contextName);
      var ref = await Firestore.instance.collection('users/' + userId + '/next_actions_contexts').getDocuments();
      var documents = ref.documents.where((f) {return f['id'] == event.id;}).toList();
      documents.forEach((element) {
        Firestore.instance.collection('users/' + userId + '/next_actions_contexts').document(element.documentID).updateData({"name": event.contextName});
      });
      yield InitializedNextActionsState(this.allActions, state.parentId);
    } else if (event is EditActionEvent) {
      NextAction.editAction(event.id, event.actionName);
      NextAction edited = this.allActions.where((x) {
        return !x.isContext() && x.getId() == event.id;
      }).toList()[0];
      edited.name = event.actionName;
      var ref = await Firestore.instance.collection('users/' + userId + '/next_actions').getDocuments();
      var documents = ref.documents.where((f) {return f['id'] == event.id;}).toList();
      documents.forEach((element) {
        Firestore.instance.collection('users/' + userId + '/next_actions').document(element.documentID).updateData({"name": event.actionName});
      });
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
      List<NextAction> actions = await NextAction.readAll(current);
      result..addAll(actions.map((NextAction a) {
        return a.id;
      }));
    }
    return result;
  }

}
