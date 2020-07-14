import 'package:brain_dump/models/db_models/next_actions/next_action_interface.dart';
import 'package:brain_dump/models/database_client.dart';
import 'package:sqflite/sqflite.dart';
final  dbTableName = 'NextAction';

class NextAction extends NextActionInterface {
  int id;
  int parentId;
  String name;
  DateTime dateCreated;
  DateTime dateAccomplished;
  String firestoreId;

  String getName() {
    return this.name;
  }

  int getId() {
    return this.id;
  }

  static Future<List<NextAction>> readAll(int parentId) async {
    Database db = await DatabaseClient().database;
    List<Map<String, dynamic>> result;
    if (parentId == null || parentId == -1) {
      result = await db.rawQuery( 'SELECT * FROM NextAction WHERE parent_id = -1');
    } else {
      result = await db.rawQuery( 'SELECT * FROM NextAction WHERE parent_id = ?', [parentId]);
    }

    List<NextAction> actions = [];
    result.forEach((map) {
      NextAction nextAction = new NextAction();
      nextAction.fromMap(map);
      actions.add(nextAction);
    });
    return actions;
  }

  static Future<NextAction> editAction(NextAction action) async {
    Database db = await DatabaseClient().database;
    db.update('NextAction', action.toMap(), where: 'id = ?', whereArgs: [action.id] );
    return action;
  }

  static Future<NextAction> getActionById(int id) async {
    var dbClass = DatabaseClient();
    Database db = await dbClass.database;
    var result = await  db.rawQuery( 'SELECT * FROM NextAction WHERE id = ?', [id]);
    NextAction foundItem = new NextAction();
    try {
      foundItem.fromMap(result[0]);
    } catch (Exception) {
      return null;
    }
    return foundItem;
  }


  static Future<int> addNextActionToDb(NextAction action) async {
    var dbClass = DatabaseClient();
    Database db = await dbClass.database;
    action.id = await db.insert(dbTableName, action.toMap());
    return action.id;
  }
  static Future<Null> updateNextActionDbFields(NextAction action) async {
    var dbClass = DatabaseClient();
    Database db = await dbClass.database;
    Map<String,dynamic> actionMap = action.toMap();

    action.id = await db.update(dbTableName, actionMap, where: 'id = ?', whereArgs: [action.id]);
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
    if (map['date_accomplished'] != null) {
      this.dateAccomplished = DateTime.parse(map['date_accomplished']); //TODO mettre ca dans une fonction ou utiliser une librarie qui gere les objets comme du monde
    }
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
    if (this.dateAccomplished != null) {
      map['date_accomplished'] = this.dateAccomplished.toIso8601String();
    }
    if (this.parentId != null) {
      map['parent_id'] = this.parentId;
    } else {
      map['parent_id'] = -1;
    }
    return map;
  }

  bool isContext() {
    return false;
  }
}