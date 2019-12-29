import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class InTray extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _InTrayState();
  }
}

class _InTrayState extends State<InTray> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Add stuff to your in tray"),
      ),
      body: Center(
          child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
      )),
      floatingActionButton: new FloatingActionButton(
        onPressed: addStuff,
        tooltip: 'Add stuff to your in tray',
        child: new Icon(Icons.add),
      ),
    );
  }

  Future<Null> addStuff() async {
    return showDialog(
      barrierDismissible: true,
      builder: (BuildContext context) {
        return new SimpleDialog(
          contentPadding: EdgeInsets.all(20.0),
          title: new Text("Describe your stuff with 50 characters or less."),
          children: [
            new TextField(
              decoration: new InputDecoration(labelText: "Description: "),
              onSubmitted: (String str) {
                Navigator.of(context).pop();
                //Navigator.pop(context);
              },
            )
          ]
        );
      },
      context: context,
    );
  }
}
