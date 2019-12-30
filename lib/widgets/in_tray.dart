import 'package:brain_dump/models/database_client.dart';
import 'package:brain_dump/models/unmanaged_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:brain_dump/blocs/unmanaged_item/bloc.dart';
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

class InTray extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _InTrayState();
  }
}

class _InTrayState extends State<InTray> {
  final unmanagedItemBloc = UnmanagedItemBloc();
  String newUnmanagedItemName;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
        bloc: unmanagedItemBloc,
        builder: (BuildContext context, UnmanagedItemState state) {
          if (state.getItemsLength() <= 0) {
            unmanagedItemBloc.add(InitialEvent());
          }
          return new Scaffold(
            appBar: new AppBar(
              title: new Text("Add stuff to your in tray"),
            ),
            body:
                new ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: state.getItemsLength(),
                    itemBuilder: (context, i) {
                      UnmanagedItem item = state.getItem(i);
                      return new ListTile(
                          title: new Text(item.name),
                          trailing: new IconButton(
                              icon: new Icon(Icons.delete),
                              onPressed: () {
                                unmanagedItemBloc.add(DeleteItemEvent(item.id));
                              })
                      );
                    }),

            floatingActionButton: new FloatingActionButton(
              onPressed: addStuff,
              tooltip: 'Add stuff to your in tray',
              child: new Icon(Icons.add),
            ),
          );
        });
  }

  Future<Null> addStuff() async {
    return showDialog(
      barrierDismissible: true,
      builder: (BuildContext context) {
        return new AlertDialog(
            contentPadding: EdgeInsets.all(20.0),
            title: new Text("Describe your stuff with 50 characters or less."),
            content: new TextField(
                decoration: new InputDecoration(labelText: "Description: "),
                onChanged: (String str) {
                  newUnmanagedItemName = str;
                }),
            actions: [
              new FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: new Text('Cancel')),
              new FlatButton(
                  onPressed: () {
                    if (newUnmanagedItemName != null) {
                      unmanagedItemBloc
                          .add(SaveItemEvent(newUnmanagedItemName));
                    }
                    newUnmanagedItemName = null;
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
    unmanagedItemBloc.close();
  }
}
