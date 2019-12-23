import 'package:flutter/material.dart';

class Body extends StatefulWidget {
  @override State<StatefulWidget> createState() {
    return new _BodyState();
  }
}

class _BodyState extends State<Body> {
  @override
   Widget build(BuildContext context) {
    return new Scaffold(
      appBar:  new AppBar(),
      body: new Body()
    );
  }
}