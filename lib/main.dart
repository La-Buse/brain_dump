import 'package:flutter/material.dart';
import 'models/database_client.dart';
import 'models/database_client.dart';
import 'models/database_client.dart';
import 'widgets/my_app.dart';
import 'package:brain_dump/models/database_client.dart';
import 'package:brain_dump/models/db_models/next_actions/next_action.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart';


 Future<List> main2() async {
   List<dynamic> myclasses = [ NextAction] ;
   Database db = await DatabaseClient().database;
   DatabaseClient dbClient = DatabaseClient();
   List allElements = await dbClient.getAllDataInMemory(myclasses);
   return allElements;

}


//void main() => runApp(MyApp());
void main () async {
//  TestWidgetsFlutterBinding.ensureInitialized();
//   List result = await main2();
//   print(result);
   runApp(MyApp());
}