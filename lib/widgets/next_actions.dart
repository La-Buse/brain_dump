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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
        bloc: nextActionsBloc,
        builder: (BuildContext context, NextActionsState state) {
          if (state is InitialNextActionsState) {
            nextActionsBloc.add(FetchActionsEvent());
          }
          List<Widget> scaffoldChildren = [];
          scaffoldChildren.add(Text("Next Actions"));
          if (state.getParentId() != null && state.getParentId() != -1) {
            scaffoldChildren.add(Text(state.contextName, textScaleFactor: 0.5,));
          }
          return new Scaffold(
            appBar: new AppBar(title: new Column(
                children: scaffoldChildren),
              automaticallyImplyLeading: false,
                leading: IconButton(icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    if (state.getParentId() == null || state.getParentId() <= 0) {
                      Navigator.of(context).pop();
                    } else {
                      nextActionsBloc.add(GoBackContextEvent());
                    }
                  },
                ),
              actions: [
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
                  ConfirmationDialog.oneFieldInput(
                      context, 'Enter a short description for the action',
                      (String newActionName) {
                    if (newActionName != null && newActionName != '') {
                      nextActionsBloc.add(
                          AddActionEvent(newActionName, state.getParentId()));
                    }
                  }, '');
                } else {
                  ConfirmationDialog.oneFieldInput(
                      context, 'Enter the context name', (String contextName) {
                    if (contextName != null && contextName != '') {
                      nextActionsBloc.add(
                          AddContextEvent(contextName, state.getParentId()));
                    }
                    contextName = null;
                  }, '');
                }
              }, itemBuilder: (BuildContext context) {
                return popUpOptions.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              }),
            ],
            ),
            body: new ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: state.getNumberOfActions(),
                itemBuilder: (context, i) {
                  NextActionInterface action = state.getAction(i);
                  List<String> options = ['Edit', 'Delete'];
                  if (!action.isContext()) {
                    options.add('Mark as done');
                  }
                  return new ListTile(
                      subtitle: action.isContext() ? Text('context') : null,
                      title: new Text(action.getName()),
                      trailing: PopupMenuButton(
                        onSelected: (String selection) {
                          if (selection == 'Delete') {
                            if (action.isContext()) {
                              nextActionsBloc.add(
                                  DeleteContextEvent(
                                      action.getId(),
                                      state.getParentId()
                                  )
                              );
                            } else {
                              ConfirmationDialog.confirmationDialog(context,
                                  'Are you sure you want to delete this action?',
                                      () {
                                    nextActionsBloc
                                        .add(DeleteActionEvent(action.getId()));
                                  });
                            }

                          } else if (selection == 'Edit') {
                            ConfirmationDialog.oneFieldInput(
                                context,
                                'Enter a short description for the ' +
                                    (action.isContext()
                                        ? 'context.'
                                        : 'action.'), (String newName) {
                              if (action.isContext()) {
                                nextActionsBloc.add(
                                    EditContextEvent(newName, action.getId()));
                              } else {
                                nextActionsBloc.add(
                                    EditActionEvent(newName, action.getId()));
                              }
                            }, action.getName());
                          } else if (selection == 'Mark as done') {}
                        },
                        itemBuilder: (BuildContext context) {
                          {
                            return options.map((String selection) {
                              return PopupMenuItem<String>(
                                value: selection,
                                child: Text(selection),
                              );
                            }).toList();
                          }
                        },
                      ),
                      //Row(mainAxisSize: MainAxisSize.min, children: rowChildren),
                      onTap: () {
                        if (action.isContext()) {
                          nextActionsBloc.add(ChangeContextEvent(action.getId(), action.getName()));
                        }
                      });
                }),
          );
        });
  }

  @override
  void dispose() {
    super.dispose();
    nextActionsBloc.close();
  }
}
