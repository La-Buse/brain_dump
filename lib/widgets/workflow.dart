import 'package:brain_dump/models/unmanaged_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'custom_text.dart';
import 'package:brain_dump/blocs/workflow/bloc.dart';
import 'package:brain_dump/widgets/unmanaged.dart';

class ManageStuff extends StatefulWidget {
  ManageStuff(this.item, {Key key, this.title}) : super(key: key);
  final String title;
  UnmanagedItem item;

  @override
  State<StatefulWidget> createState() {
    return new _ManageStuffState(this.item);
  }
}

class _ManageStuffState extends State<ManageStuff> {
  UnmanagedItem item;
  final workflowBloc = WorkflowBloc();
  //only called one time at beginning of workflow ?
  _ManageStuffState(this.item) {
    workflowBloc.setItem(this.item);
  }


  @override
  Widget build(BuildContext context) {

    return new BlocBuilder(
      bloc: workflowBloc,
        builder: (BuildContext context, WorkflowState state) {
        return Scaffold(
              appBar: new AppBar(
                automaticallyImplyLeading: false,
                leading: IconButton(icon: Icon(Icons.arrow_back),
                onPressed: (){
                  if (state.isInitialState()) {
                    Navigator.of(context).pop();
                  } else {
                    workflowBloc.add(GoBack());
                  }
                },),
                title: new Text("Manage your stuff"),
              ),
              body:new Center(
                child: buildColumnWithData(context, state.getName(), state.getButtons(), item.name),
              )
          );
        }
    );

  }

  Column buildColumnWithData(BuildContext context, question, List<WorkflowButton> buttons, String stuffName) {
    List<Widget> tempWidgets = [];
    tempWidgets.add(CustomText(stuffName));
    tempWidgets.add(SizedBox(height:50));
    tempWidgets.add(CustomText(
      question,
      scaleFactor: 2.0,
    ));
    for (int i = 0; i < buttons.length; i++) {
      WorkflowButton current = buttons[i];
      tempWidgets.add(customButton(current.name, () {
        if (current.nextEvent != null) {
          workflowBloc.add(current.nextEvent);
        } else {
          /*
          This navigation strategy is odd, but it is the only way I found to make sure
          that the unmanaged items page would be reloaded when coming back to it
          after transforming an unmanaged item to next actions for example.
          It did not work with pushNamedAndRemoveUntil for some reason.
           */
          //
          Navigator.of(context).pushNamed(
            current.nextPageName,
            arguments: item,
          ).then((value) {
            Navigator.of(context).pop(); // this will pop Manage stuff page and code in unmanaged.dart will be executed
          });
        }

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
    workflowBloc.close();
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


