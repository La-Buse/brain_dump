import 'package:brain_dump/models/next_actions/next_action_interface.dart';
import 'package:brain_dump/models/database_client.dart';
import 'package:sqflite/sqflite.dart';
import 'package:async/async.dart';
final  dbTableName = 'NextAction';

class NextAction extends NextActionInterface {
  int id;
  int parentId;
  String name;
  DateTime dateCreated;
  DateTime dateAccomplished;

  static Future<List<NextAction>> readNextActionsFromDb(int parentId) async {
    Database db = await DatabaseClient().database;
    String queryString = 'SELECT * FROM NextAction' + (parentId == -1 ? '' : ' WHERE id = ?');
    List<Object> args = parentId == -1 ? [] : [parentId];
    List<Map<String, dynamic>> result = await db.rawQuery(queryString, args);
    List<NextAction> actions = [];
    result.forEach((map) {
      NextAction nextAction = new NextAction();
      nextAction.fromMap(map);
      actions.add(nextAction);
    });
    return actions;
  }

  static Future<int> addNextActionToDb(NextAction action) async {
    Database db = await DatabaseClient().database;
    action.id = await db.insert(dbTableName, action.toMap());
    return action.id;
  }

  static Future<int> deleteNextAction(int id) async {
    Database db = await DatabaseClient().database;
    return await db.delete(dbTableName, where: 'id = ?', whereArgs: [id]);
  }

  fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.parentId = map['parent_id'];
    this.name = map['name'];
    this.dateCreated = DateTime.parse(map['date_created']);
    this.dateAccomplished = DateTime.parse(map['date_acomplished']);
  }

  setName(String newName) {
    this.name = newName;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'name': this.name
    };
    if (id != null) {
      map['id'] = this.id;
    }
    if (this.dateCreated != null) {
      map['date_created'] = this.dateCreated.toIso8601String();
    } else {
      map['date_created'] = DateTime.now().toIso8601String();
    }
    if (this.dateAccomplished != null) {
      map['date_accomplished'] = this.dateAccomplished.toIso8601String();
    }
    if (this.parentId != null) {
      map['parent_id'] = this.parentId;
    }
    return map;
  }

  bool isContext() {
    return false;
  }
}