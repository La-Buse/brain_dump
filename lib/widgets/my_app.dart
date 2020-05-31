import 'package:brain_dump/blocs/authentication/authentication_event.dart';
import 'package:brain_dump/models/route_generator.dart';
import 'package:brain_dump/widgets/dashboard.dart';
import 'package:brain_dump/widgets/authentication.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        backgroundColor: Colors.blue,
        accentColor: Colors.blueGrey,
        accentColorBrightness: Brightness.dark,
        buttonTheme: ButtonTheme.of(context).copyWith(
          buttonColor: Colors.blue,
          textTheme: ButtonTextTheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)
          )
        )
      ),
      home: StreamBuilder(stream:FirebaseAuth.instance.onAuthStateChanged, builder: (context, userSnapshot) {
        if (userSnapshot.hasData) { //if token found
          return Dashboard();
        }
        return Authentication();
      }),
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
