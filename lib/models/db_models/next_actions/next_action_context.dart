import 'package:brain_dump/models/db_models/next_actions/next_action_interface.dart';
import 'package:brain_dump/models/database_client.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import 'package:async/async.dart';
import 'package:brain_dump/models/firestore_synchronized.dart';
final  dbTableName = 'NextActionContext';

class NextActionContext extends FirestoreSynchronized implements NextActionInterface {
  int id;
  int parentId;
  String name;
  DateTime dateCreated;
  String firestoreId;

  String getName() {
    return this.name;
  }

  int getId() {
    return this.id;
  }

  static Future<List<NextActionContext>> readContextsFromDb(int parentId) async {
    Database db = await DatabaseClient().database;
    List<Map<String, dynamic>> result;

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

  Future<int> addItemToLocalDb() async {
    Database db = await DatabaseClient().database;
    this.id = await db.insert(dbTableName, this.toMap());
    return this.id;
  }

  static Future<int> deleteActionContext(int id) async {
    Database db = await DatabaseClient().database;
    return await db.delete(dbTableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateItemDbFields() async {
    Database db = await DatabaseClient().database;
    db.update('NextActionContext', this.toMap(), where: 'id = ?', whereArgs: [this.id] );
    return this;
  }

  Future<NextActionContext> getItemById(int id) async {
    var dbClass = DatabaseClient();
    Database db = await dbClass.database;
    var result = await  db.rawQuery( 'SELECT * FROM NextActionContext WHERE id = ?', [id]);
    NextActionContext foundItem = new NextActionContext();
    try {
      foundItem.fromMap(result[0]);
    } catch (Exception) {
      return null;
    }
    return foundItem;
  }

  fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.parentId = map['parent_id'];
    this.name = map['name'];
    this.dateCreated = DateTime.parse(map['date_created']);
    this.firestoreId = map['firestore_id'];
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
    if (this.firestoreId != null) {
      map['firestore_id'] = this.firestoreId;
    }
    return map;
  }

  bool isContext() {
    return true;
  }

  Map<String, dynamic> toFirestoreMap() {
    return           {
      'name': this.name,
      'id': this.id,
      'parent_id': this.parentId,
      'date_created': this.dateCreated,
    };
  }
  String getFirestoreId() {
    return this.firestoreId;
  }
  void setFirestoreId(String id) {
    this.firestoreId = id;
  }
  CollectionReference getItemFirestoreCollection(String userId) {
    return Firestore.instance.collection('users/' + userId + '/next_actions_contexts');
  }
}