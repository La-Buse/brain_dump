import 'package:brain_dump/widgets/manage_stuff.dart';
import 'package:flutter/material.dart';
import 'package:brain_dump/widgets/home.dart';
import 'package:brain_dump/widgets/in_tray.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => Home());
      case '/Manage stuff':
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => ManageStuff(
              //data: args,
            ),
          );
        }
        break;
      case '/In tray':
        return MaterialPageRoute(
          builder: (_) => InTray(),
        );
      default:
        break;
    }
  }
}
