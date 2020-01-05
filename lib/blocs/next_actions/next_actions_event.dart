import 'package:brain_dump/models/next_actions/next_action.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@immutable
abstract class NextActionsEvent {
    final String actionName;
    final String contextName;
    final int parentId;
    final int id;
    NextActionsEvent({actionName: '', contextName: '', parentId: -1, id: -1}) :
        this.actionName = actionName,
        this.contextName = contextName,
        this.parentId = parentId,
        this.id = id;
}

class FetchActionsEvent extends NextActionsEvent {

}

class AddContextEvent extends NextActionsEvent {

}

class AddActionEvent extends NextActionsEvent {
  AddActionEvent(String actionName, int parentId) :
        super(
          actionName: actionName, parentId: parentId);
}

class DeleteActionEvent extends NextActionsEvent {
  DeleteActionEvent(int id) :
        super(id: id);
}
