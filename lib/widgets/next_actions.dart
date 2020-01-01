import 'package:brain_dump/models/next_action.dart';
import 'package:brain_dump/models/unmanaged_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:brain_dump/blocs/unmanaged_item/bloc.dart';
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
  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
        bloc: nextActionsBloc,
        builder: (BuildContext context, NextActionsState state) {
          return new Scaffold(
            appBar: new AppBar(
              title: new Text("Next actions"),
            ),
            body:
            new ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: state.getNumberOfActions(),
                itemBuilder: (context, i) {
                  NextAction action = state.getAction(i);
                  return new ListTile(
                      title: new Text(action.name),
                      trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children:
                          [
                            new Checkbox(
                              value: false,
                              onChanged:(newValue) {

                              }
                            ),
                            new IconButton(
                                icon: new Icon(Icons.edit),
                                onPressed: () { }
                            ),
                          ]),
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          '/Manage stuff',
                          arguments: item,
                        );
                      }
                  );
                }),

          );
        }
    );

  }

  @override
  void dispose() {
    super.dispose();
    nextActionsBloc.close();
  }
}