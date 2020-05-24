import 'package:brain_dump/models/db_models/next_actions/next_action.dart';
import 'file:///C:/Users/levas/source/repos/brain_dump/lib/models/db_models/unmanaged_item/unmanaged_item.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@immutable
abstract class NextActionsEvent {
    final String actionName;
    final String contextName;
    final int parentId;
    final int id;
    final UnmanagedItem item;
    NextActionsEvent({actionName: '', contextName: '', parentId: -1, id: -1, item: null}) :
        this.actionName = actionName,
        this.contextName = contextName,
        this.parentId = parentId,
        this.id = id,
        this.item = item;
}

class FetchActionsEvent extends NextActionsEvent {

}

class AddContextEvent extends NextActionsEvent {
  AddContextEvent(String contextName, int parentId) :
        super(contextName: contextName,
        parentId:parentId);
}

class AddActionEvent extends NextActionsEvent {
  AddActionEvent(String actionName, int parentId, UnmanagedItem item) :
        super(
          actionName: actionName, parentId: parentId, item:item);
}

class DeleteActionEvent extends NextActionsEvent {
  DeleteActionEvent(int id) :
        super(id: id);
}

class DeleteContextEvent extends NextActionsEvent {
  DeleteContextEvent(int id, int parentId) :
      super(id: id, parentId: parentId);
}

class EditActionEvent extends NextActionsEvent {
  EditActionEvent(String actionName, int id):
      super(actionName: actionName, id: id);
}

class EditContextEvent extends NextActionsEvent {
  EditContextEvent(String contextName, int id):
      super(contextName: contextName, id: id);
}

class ChangeContextEvent extends NextActionsEvent {
  ChangeContextEvent(int parentId, String contextName):
        super(parentId: parentId, contextName: contextName);
}

class GoBackContextEvent extends NextActionsEvent {
  
}
