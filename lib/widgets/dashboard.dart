import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _DashboardState();
  }
}

class _DashboardState extends State<Dashboard> {
  List<String> pages = ["Unmanaged", "Calendar", "Next Actions", "Projects List", "Reference", "Logout"];
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        title: new Text("Brain Dump")
      ),
      drawer: new Drawer(
        child: new Column(
          children: <Widget> [
            AppBar( automaticallyImplyLeading: false,),
            Divider(),
            ListTile(title:Text('Unmanaged Items'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed('/Unmanaged');
                }),
            Divider(),
            ListTile(title:Text('Calendar'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed('/Calendar');
                }),
            Divider(),
            ListTile(title:Text('Next Actions'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed('/Next Actions');
                }),
            Divider(),
            ListTile(title:Text('Projects List'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed('/Projects List');
                }),
            Divider(),
            ListTile(title:Text('Reference'),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushNamed('/Reference');
                    }),
            Divider(),
            ListTile(
                title:Text('Logout'), 
                onTap: () {
                  showDialog(context: context, builder: (BuildContext context) {
                    return new AlertDialog(
                        contentPadding: EdgeInsets.all(20.0),
                        title: new Text('Are you sure you want to logout ?'),
//                        content: new Text(message),
                        actions: [
                          new FlatButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: new Text('Cancel')),
                          new FlatButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                FirebaseAuth.instance.signOut();
                              },
                              child: new Text('Confirm'))
                        ]);
                  });
                }
            ),
          ]
//          new ListView.builder(
//            itemCount: pages.length ,
//            itemBuilder: (context, i) {
//              return new ListTile(
//                title: new Text(pages[i]),
//                onTap: () {
//                  Navigator.of(context).pop();
//                  Navigator.of(context).pushNamed(
//                    '/' + pages[i]
//                  );
//                },
//              );
//            }
//          ),
//          color: Colors.white
        ),

      ),
      body: new Center(

      ),
    );
  }
}
