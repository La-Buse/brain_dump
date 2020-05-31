import 'package:brain_dump/models/db_models/next_actions/next_action.dart';
import 'package:brain_dump/models/db_models/next_actions/next_action_interface.dart';
import 'package:brain_dump/models/db_models/unmanaged_item/unmanaged_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:brain_dump/widgets/confirmation_dialog.dart';
import 'dart:async';
import 'package:brain_dump/blocs/next_actions/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NextActions extends StatefulWidget {
  UnmanagedItem unmanagedItem;
  NextActions({
    Key key,
    @required this.unmanagedItem
  }) : super(key:key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _NextActionsState(this.unmanagedItem);
  }
}

class _NextActionsState extends State<NextActions> {
  _NextActionsState(UnmanagedItem item)  {
    this.item = item;
  }

  UnmanagedItem item;
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
          if (this.item != null ) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              addActionDialog(state, this.item);
              this.item = null;
            });

          }


          if (state is InitialNextActionsState) {
            nextActionsBloc.add(FetchActionsEvent());
            return new Center(child: CircularProgressIndicator(),);
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
                  addActionDialog(state, null);
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

  //@param initialValue : When this page is called from workflow, it means the
  //user has chosen to add an unmanaged item to next actions. This is the description
  //of the value
  void addActionDialog(NextActionsState state, UnmanagedItem item) {
    String initialTextValue = ''; // default value in text field
    if (item != null) {
      initialTextValue = item.name;
    }
    ConfirmationDialog.oneFieldInput(
        context, 'Enter a short description for the action',
            (String newActionName) {
          if (newActionName != null && newActionName != '') {
            UnmanagedItem temp;
            if (item != null) {
              temp = item;
              item = null;
            }
            nextActionsBloc.add(
                AddActionEvent(newActionName, state.getParentId(), temp));
          }
        }, initialTextValue);
  }

  @override
  void dispose() {
    super.dispose();
    nextActionsBloc.close();
  }
}
