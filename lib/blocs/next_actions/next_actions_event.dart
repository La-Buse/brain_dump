import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@immutable
abstract class NextActionsEvent {
    final String actionName;
    final String contextName;
    final int parentId;
    NextActionsEvent({actionName: '', contextName: '', parentId: -1}) :
        this.actionName = actionName, this.contextName = contextName, this.parentId = parentId;
}

class AddContextEvent extends NextActionsEvent {

}

class AddActionEvent extends NextActionsEvent {
  AddActionEvent(String actionName, String contextName, int parentId):
        super(actionName: actionName, contextName: contextName, parentId: parentId);


}
