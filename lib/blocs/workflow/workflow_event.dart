import 'package:meta/meta.dart';

@immutable
abstract class WorkflowEvent {}

class IsActionable extends WorkflowEvent {

}

class NotActionable extends WorkflowEvent {

}

class ForReview extends WorkflowEvent {

}

class TrashIt extends WorkflowEvent {

}

class ReferenceIt extends WorkflowEvent {

}

class LessThanTwoMinutes extends WorkflowEvent {

}

class MoreThanTwoMinutes extends WorkflowEvent {

}

class DelegateIt extends WorkflowEvent {

}

class DeferIt extends WorkflowEvent {

}

class DelegateOrDefer extends WorkflowEvent {

}

class GoBack extends WorkflowEvent {

}

class Calendar extends WorkflowEvent {

}

class NextActions extends WorkflowEvent {

}