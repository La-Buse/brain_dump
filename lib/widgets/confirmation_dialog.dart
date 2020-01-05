import 'package:flutter/material.dart';

//class ConfirmationDialog extends StatelessWidget {
  class ConfirmationDialog{
    static Future<Null> confirmationDialog (BuildContext context, String message, Function callback) {
      return showDialog(
        barrierDismissible: true,
        builder: (BuildContext context) {
          return new AlertDialog(
              contentPadding: EdgeInsets.all(20.0),
              title: new Text(message),
              content: new Text(message),
              actions: [
                new FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: new Text('Cancel')),
                new FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      callback();
                    },
                    child: new Text('Confirm'))
              ]);
        },
        context: context,
      );
    }
}
