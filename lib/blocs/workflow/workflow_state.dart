import './bloc.dart';
import 'package:meta/meta.dart';

@immutable
abstract class WorkflowState {
  String getName();
  List<WorkflowButton> getButtons();
  bool isInitialState();
}

class WorkflowButton {
  String name;
  WorkflowEvent nextEvent;
  String nextPageName;
  WorkflowButton(String name, WorkflowEvent nextEvent, {nextPageName: '/'}) {
    this.name = name;
    this.nextEvent = nextEvent;
    this.nextPageName = nextPageName;
  }
}

class NonActionableState extends WorkflowState {
  bool isInitialState() {
    return false;
  }
  String getName() {
    return "What kind of non actionable is this stuff ?";
  }
  List<WorkflowButton> getButtons() {
    return [
      new WorkflowButton("Trash", TrashIt()),
      new WorkflowButton("Someday/maybe", ForReview()),
      new WorkflowButton("Reference", ReferenceIt())
    ];
  }
}

class IsActionableState extends WorkflowState {
  bool isInitialState() {
    return false;
  }
  String getName() {
    return "Will it take less than 2 minutes ?";
  }
  List<WorkflowButton> getButtons() {
    return [
      new WorkflowButton("Yes", LessThanTwoMinutes()),
      new WorkflowButton("No", MoreThanTwoMinutes()),
    ];
  }
}

class DelegateOrDeferState extends WorkflowState {
  bool isInitialState() {
    return false;
  }
  String getName() {
    return "Do you want to delegate it or defer it ?";
  }
  List<WorkflowButton> getButtons() {
    return [
      new WorkflowButton("Delegate it", DelegateIt()),
      new WorkflowButton("Defer it", DeferIt())
    ];
  }
}

class DoItNowState extends WorkflowState {
  bool isInitialState() {
    return false;
  }
  String getName() {
    return "Do it now.";
  }
  List<WorkflowButton> getButtons() {
    return [
    ];
  }
}

class InitialWorkflowState extends WorkflowState {
  bool isInitialState() {
    return true;
  }
  String getName() {
    return "Is this stuff actionable ?";
  }
  List<WorkflowButton> getButtons() {
    return [
      new WorkflowButton("Yes", IsActionable()),
      new WorkflowButton("No", NotActionable())
    ];
  }
}

class FinalDumpItState extends WorkflowState {
  bool isInitialState() {
    return false;
  }
  String getName() {
    return "Congratulations, you have successfully dealt with some of your stuff !";
  }
  List<WorkflowButton> getButtons() {
    return null;
  }
}

class WaitForItState extends WorkflowState {
  bool isInitialState() {
    return false;
  }
  String getName() {
    return "Write down the name and contact of the person you are waiting for and take a note of the date.";
  }
  List<WorkflowButton> getButtons() {
    return [];
  }
}

class CalendarOrNextActionsState extends WorkflowState {
  bool isInitialState() {
    return false;
  }
  String getName() {
    return "Does this action have to be done at a specific time (Calendar) or ASAP (Next actions list) ? ";
  }
  List<WorkflowButton> getButtons() {
    return [
      new WorkflowButton("Calendar", null, nextPageName: '/Unmanaged'),
      new WorkflowButton("Next Actions", null, nextPageName: '/Next Actions'),
    ];
  }
}

