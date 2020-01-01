import 'package:meta/meta.dart';
import 'package:brain_dump/models/next_action.dart';

@immutable
abstract class NextActionsState {
  int getNumberOfActions();
  NextAction getAction(int index);
}

class InitialNextActionsState extends NextActionsState {
  getNumberOfActions() {
    return 0;
  }
  getAction(int index) {
    return null;
  }
}
