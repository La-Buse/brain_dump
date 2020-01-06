import 'package:brain_dump/models/next_actions/next_action_interface.dart';
import 'package:meta/meta.dart';
import 'package:brain_dump/models/next_actions/next_action.dart';

@immutable
abstract class NextActionsState {
  final List<NextActionInterface> actions;
  final int parentId;
  NextActionsState(List<NextActionInterface> actions2, int parentId) :
        this.actions = actions2, this.parentId = parentId;

  int getNumberOfActions();
  NextActionInterface getAction(int index);
  int getParentId();
}

class InitialNextActionsState extends NextActionsState {
  InitialNextActionsState() : super([], null);
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
  InitializedNextActionsState(List<NextActionInterface> actions2, int parentId) : super(actions2, parentId);
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