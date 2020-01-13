import 'package:brain_dump/models/next_actions/next_action_interface.dart';
import 'package:meta/meta.dart';
import 'package:brain_dump/models/next_actions/next_action.dart';

@immutable
abstract class NextActionsState {
  final List<NextActionInterface> actions;
  final int parentId;
  final String contextName;
  NextActionsState({List<NextActionInterface> actions: const [],  int parentId: -1, String contextName: ''}) :
        this.actions = actions, this.parentId = parentId, this.contextName = contextName;

  int getNumberOfActions();
  NextActionInterface getAction(int index);
  int getParentId();
}

class InitialNextActionsState extends NextActionsState {
  InitialNextActionsState() : super();
  getNumberOfActions() {
    return 0;
  }
  getAction(int index) {
    return null;
  }

  getParentId() {
    return null;
  }

}

class InitializedNextActionsState extends NextActionsState {
  InitializedNextActionsState(List<NextActionInterface> actions2, int parentId, {contextName: ''}) :
        super(actions: actions2, parentId: parentId, contextName: contextName);
  int getNumberOfActions() {
    return actions.length;
  }
  NextActionInterface getAction(int index) {
    if (index <= actions.length -1) {
      return actions[index];
    } else {
      return null;
    }
  }

  int getParentId() {
    return this.parentId;
  }
}