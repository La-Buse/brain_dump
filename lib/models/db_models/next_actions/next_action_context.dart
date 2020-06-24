import 'package:brain_dump/models/db_models/next_actions/next_action_interface.dart';
import 'package:brain_dump/models/database_client.dart';
import 'package:sqflite/sqflite.dart';
import 'package:async/async.dart';
final  dbTableName = 'NextActionContext';

class NextActionContext extends NextActionInterface {
  int id;
  int parentId;
  String name;
  DateTime dateCreated;

  String getName() {
    return this.name + ' ' + this.id.toString();
  }

  int getId() {
    return this.id;
  }

  static Future<List<NextActionContext>> readContextsFromDb(int parentId) async {
    Database db = await DatabaseClient().database;
    List<Map<String, dynamic>> result;

    var test = await db.rawQuery('SELECT * FROM NextActionContext');
    if (parentId == -1 || parentId == null) {
      result = await db.rawQuery('SELECT * FROM NextActionContext WHERE parent_id = -1');
    } else {
      result = await db.rawQuery('SELECT * FROM NextActionContext WHERE parent_id = ?', [parentId]);
    }

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

  static Future<NextActionContext> editActionContext(int id, String contextName) async {
    Database db = await DatabaseClient().database;
    NextActionContext context = new NextActionContext();
    List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT * FROM NextActionContext WHERE id = ?', [id]);
    context.fromMap(result[0]);
    context.name = contextName;
    db.update('NextActionContext', context.toMap(), where: 'id = ?', whereArgs: [id] );
    return context;
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
      map['date_created'] = DateTime.now().toUtc().toIso8601String();
    }
    if (this.parentId != null) {
      map['parent_id'] = this.parentId;
    } else {
      map['parent_id'] = -1;
    }
    return map;
  }

  bool isContext() {
    return true;
  }
}