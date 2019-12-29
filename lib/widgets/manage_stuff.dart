import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'custom_text.dart';
import 'package:brain_dump/bloc.dart';

class ManageStuff extends StatefulWidget {
  ManageStuff({Key key, this.title}) : super(key: key);
  final String title;

  @override
  State<StatefulWidget> createState() {
    return new _ManageStuffState();
  }
}

class _ManageStuffState extends State<ManageStuff> {
  final dumpItBloc = DumpItBloc();

  @override
  Widget build(BuildContext context) {
    return new BlocBuilder(
      bloc: dumpItBloc,
        builder: (BuildContext context, WorkflowState state) {

        return Scaffold(
              appBar: new AppBar(
                automaticallyImplyLeading: false,
                leading: IconButton(icon: Icon(Icons.arrow_back),
                onPressed: (){
                  dumpItBloc.add(GoBack());
                },),
                title: new Text("Manage your stuff"),
              ),
              body:new Center(
                child: buildColumnWithData(context, state.getName(), state.getButtons()),
              )
          );
        }
    );

  }

  Column buildColumnWithData(BuildContext context, question, List<WorkflowButton> buttons) {
    List<Widget> tempWidgets = [];
    tempWidgets.add(CustomText(
      question,
      scaleFactor: 2.0,
    ));
    for (int i = 0; i < buttons.length; i++) {
      WorkflowButton current = buttons[i];
      tempWidgets.add(customButton(current.name, () {
        dumpItBloc.add(current.nextEvent);
      }));
    }
    return new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: tempWidgets,
    );
  }

  @override
  void dispose() {
    super.dispose();
    dumpItBloc.close();
  }
}

RaisedButton customButton(String text, Function onPressed) {
  return new RaisedButton(
    elevation: 10.0,
    onPressed: onPressed,
    color: Colors.blue,
    child: new CustomText(text),
  );
}


