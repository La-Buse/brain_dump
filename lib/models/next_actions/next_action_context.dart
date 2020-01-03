import 'package:brain_dump/models/next_actions/next_action_interface.dart';
import 'package:brain_dump/models/database_client.dart';
import 'package:sqflite/sqflite.dart';
import 'package:async/async.dart';
final  dbTableName = 'NextActionContext';

class NextActionContext extends NextActionInterface {
  int id;
  int parentId;
  String name;
  DateTime dateCreated;

  static Future<List<NextActionContext>> readContextsFromDb(int parentId) async {
    Database db = await DatabaseClient().database;
    String queryString = 'SELECT * FROM NextActionContext' + (parentId == -1 ? '' : ' WHERE id = ?');
    List<Object> args = parentId == -1 ? [] : [parentId];
    List<Map<String, dynamic>> result = await db.rawQuery(queryString, args);
    List<NextActionContext> contexts = [];
    result.forEach((map) {
      NextActionContext nextAction = new NextActionContext();
      nextAction.fromMap(map);
      contexts.add(nextAction);
    });
    return contexts;
  }

  static Future<int> addActionContext(NextActionContext context) async {
    Database db = await DatabaseClient().database;
    context.id = await db.insert(dbTableName, context.toMap());
    return context.id;
  }

  static Future<int> deleteActionContext(int id) async {
    Database db = await DatabaseClient().database;
    return await db.delete(dbTableName, where: 'id = ?', whereArgs: [id]);
  }

  fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.parentId = map['parent_id'];
    this.name = map['name'];
    this.dateCreated = DateTime.parse(map['date_created']);
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
    if (this.parentId != null) {
      map['parent_id'] = this.parentId;
    }
    return map;
  }

  bool isContext() {
    return false;
  }
}