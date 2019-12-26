import 'package:brain_dump/bloc.dart';
import 'package:meta/meta.dart';

@immutable
abstract class WorkflowState {
  String getName();
  List<WorkflowButton> getButtons();
}

class WorkflowButton {
  String name;
  WorkflowEvent nextEvent;
  WorkflowButton(String name, WorkflowEvent nextEvent) {
    this.name = name;
    this.nextEvent = nextEvent;
  }
}

class NonActionableState extends WorkflowState {
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
  String getName() {
    return "Do it now.";
  }
  List<WorkflowButton> getButtons() {
    return [
    ];
  }
}

class InitialWorkflowState extends WorkflowState {
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
  String getName() {
    return "Congratulations, you have successfully dealt with some of your stuff !";
  }
  List<WorkflowButton> getButtons() {
    return null;
  }
}

class WaitForItState extends WorkflowState {
  String getName() {
    return "Write down the name and contact of the person you are waiting for and take a note of the date.";
  }
  List<WorkflowButton> getButtons() {
    return [];
  }
}

class CalendarOrNextActionsState extends WorkflowState {
  String getName() {
    return "Does this action have to be done at a specific time (Calendar) or ASAP (Next actions list) ? ";
  }
  List<WorkflowButton> getButtons() {
    return [
      new WorkflowButton("Calendar", Calendar()),
      new WorkflowButton("Next Actions", NextActions()),
    ];
  }
}

