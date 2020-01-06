import 'package:brain_dump/models/next_actions/next_action.dart';
import 'package:brain_dump/models/next_actions/next_action_interface.dart';
import 'package:brain_dump/models/unmanaged_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:brain_dump/widgets/confirmation_dialog.dart';
import 'dart:async';
import 'package:brain_dump/blocs/next_actions/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NextActions extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _NextActionsState();
  }
}

class _NextActionsState extends State<NextActions> {
  final nextActionsBloc = NextActionsBloc();
  final tooltipMessage = '''Action : The next physical action that will 
bring you closer to the completion of a task. 
Good: Call Gary to set merger meeting. Bad: Plan merger.

Context: context in which next actions will be easily done. Example: At home, at computer, errands, etc.
''';
  final popUpOptions = ['Add action', 'Add context'];
  final key = new GlobalKey();
  String newNextActionName = '';
  String newContextName = '';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
        bloc: nextActionsBloc,
        builder: (BuildContext context, NextActionsState state) {
          if (state is InitialNextActionsState) {
            nextActionsBloc.add(FetchActionsEvent());
          }
          return new Scaffold(
            appBar: new AppBar(title: new Text("Next actions"), actions: [
              FloatingActionButton(
                key: UniqueKey(),
                child: Tooltip(
                    key: key,
                    child: IconButton(icon: Icon(Icons.info)),
                    message: tooltipMessage,
                    waitDuration: null),
                onPressed: () {
                  final dynamic tooltip = key.currentState;
                  tooltip.ensureTooltipVisible();
                },
              ),
              PopupMenuButton<String>(onSelected: (String optionSelected) {
                if (optionSelected.compareTo(popUpOptions[0]) == 0) {
                  addNextAction(state.getParentId());
                } else {
                  addActionContext(state.getParentId());
                }
              }, itemBuilder: (BuildContext context) {
                return popUpOptions.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              }),
            ]),
            body: new ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: state.getNumberOfActions(),
                itemBuilder: (context, i) {
                  NextActionInterface action =
                    state.getAction(i);
                  List<Widget> rowChildren = [
                    new IconButton(
                      icon: new Icon(Icons.delete),
                      onPressed: () {
                        ConfirmationDialog.confirmationDialog(context,
                            'Are you sure you want to delete this action?',
                                () {
                              nextActionsBloc.add(DeleteActionEvent(action.getId()));
                            });
                      },
                    ),
                    new IconButton(
                        icon: new Icon(Icons.edit), onPressed: () {}),
                  ];
                  if (!action.isContext()) {
                    rowChildren.add(new Checkbox(value: false, onChanged: (newValue) {}));
                  }
                  return new ListTile(

                      subtitle: action.isContext() ? Text('context') : null,
                      title: new Text(action.getName()),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: rowChildren),
                      onTap: () {});
                }),
          );
        });
  }

  Future<Null> addNextAction(int parentId) async {
    return showDialog(
      barrierDismissible: true,
      builder: (BuildContext context) {
        return new AlertDialog(
            contentPadding: EdgeInsets.all(20.0),
            title: new Text(
                "Describe this next action with 50 characters or less."),
            content: new TextField(
                decoration: new InputDecoration(
                  labelText: "Description: ",
                ),
                onChanged: (String str) {
                  newNextActionName = str;
                }),
            actions: [
              new FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: new Text('Cancel')),
              new FlatButton(
                  onPressed: () {
                    if (newNextActionName != null) {
                      nextActionsBloc
                          .add(AddActionEvent(newNextActionName, parentId));
                    }
                    newNextActionName = null;
                    Navigator.of(context).pop();
                  },
                  child: new Text('Confirm'))
            ]);
      },
      context: context,
    );
  }

  Future<Null> addActionContext(int parentId) async {
    return showDialog(
      barrierDismissible: true,
      builder: (BuildContext context) {
        return new AlertDialog(
            contentPadding: EdgeInsets.all(20.0),
            title: new Text(
                "Describe this action context with 50 characters or less."),
            content: new TextField(
                decoration: new InputDecoration(
                  labelText: "Description: ",
                ),
                onChanged: (String str) {
                  newContextName = str;
                }),
            actions: [
              new FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: new Text('Cancel')),
              new FlatButton(
                  onPressed: () {
                    if (newContextName != null) {
                      nextActionsBloc
                          .add(AddContextEvent(newContextName, parentId));
                    }
                    newContextName = null;
                    Navigator.of(context).pop();
                  },
                  child: new Text('Confirm'))
            ]);
      },
      context: context,
    );
  }

  @override
  void dispose() {
    super.dispose();
    nextActionsBloc.close();
  }
}
