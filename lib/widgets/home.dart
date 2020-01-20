import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  List<String> pages = ["Unmanaged", "Calendar", "Next Actions", "Projects List", "Reference"];
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        title: new Text("Brain Dump")
      ),
      drawer: new Drawer(
        child: new Container(
          child: new ListView.builder(
            itemCount: pages.length ,
            itemBuilder: (context, i) {
              return new ListTile(
                title: new Text(pages[i]),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed(
                    '/' + pages[i]
                  );
                },
              );
            }
          ),
          color: Colors.white
        ),

      ),
      body: new Center(

      ),
    );
  }
}

//return MaterialApp(
//debugShowCheckedModeBanner: false,
//theme: new ThemeData(
//primarySwatch: Colors.blue,
//),
//);