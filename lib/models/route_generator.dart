import 'package:brain_dump/widgets/workflow.dart';
import 'package:flutter/material.dart';
import 'package:brain_dump/widgets/home.dart';
import 'package:brain_dump/widgets/unmanaged.dart';
import 'package:brain_dump/widgets/next_actions.dart';
import 'package:brain_dump/widgets/calendar.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
            builder: (_) => Home(),
            settings: RouteSettings(name: '/')
        );
      case '/Manage stuff':
        if (! (args is String)) {
          return MaterialPageRoute(
            builder: (_) => ManageStuff(
              args,
            ),
            settings: RouteSettings(name: '/Manage stuff')
          );
        }
        break;
      case '/Unmanaged':
        return MaterialPageRoute(
          builder: (_) => InTray(),
            settings: RouteSettings(name: '/Unmanaged')
        );
        break;
      case '/Next Actions':
        return MaterialPageRoute(
          builder: (_) => NextActions(unmanagedItem: args,),
          settings: RouteSettings(name: '/Next Actions')
        );

      case '/Calendar':
        return MaterialPageRoute(
          builder: (_) => Calendar(),
            settings: RouteSettings(name: '/Calendar')
        );
      default:
        break;
    }
  }
}
