import 'package:brain_dump/models/db_models/next_actions/next_action_interface.dart';
import 'package:brain_dump/models/database_client.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import 'package:brain_dump/models/firestore_synchronized.dart';
final  dbTableName = 'NextAction';


class NextAction extends FirestoreSynchronized implements NextActionInterface {
  int id;
  int parentId;
  String name;
  DateTime dateCreated;
  DateTime dateAccomplished;
  String firestoreId;

  String getLocalDbTableName() {
    return 'NextAction';
  }

  String getName() {
    return this.name;
  }

  int getId() {
    return this.id;
  }
  Future<void> deleteFromLocalDb() async {
    await DatabaseClient().delete(this.id, this.getLocalDbTableName());
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

  Future<void> updateItemLocalDbFields() async {
    Database db = await DatabaseClient().database;
    db.update('NextAction', this.toMap(), where: 'id = ?', whereArgs: [this.id] );
  }

  Future<NextAction> getItemById(int id) async {
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


  Future<int> addItemToLocalDb() async {
    var dbClass = DatabaseClient();
    Database db = await dbClass.database;
    this.id = await db.insert(dbTableName, this.toMap());
    return this.id;
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
    this.firestoreId = map['firestore_id'];
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
    if (this.firestoreId != null) {
      map['firestore_id'] = this.firestoreId;
    }
    return map;
  }

  bool isContext() {
    return false;
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'name': this.name,
      'id': this.id,
      'parent_id': this.parentId,
      'date_accomplished': this.dateAccomplished,
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
    return Firestore.instance.collection('users/' + userId + '/next_actions');
  }
  Future<List<FirestoreSynchronized>> readAllLocalItems() async {
    Database db = await DatabaseClient().database;
    List<Map<String, dynamic>> mapResult;
;
    mapResult = await db.rawQuery('SELECT * FROM NextAction');
    List<FirestoreSynchronized> objectResult = new List();
    for (Map<String,dynamic> currentMap in mapResult) {
      NextAction dummyAction = new NextAction();
      NextAction current = dummyAction.fromMap(currentMap);
      objectResult.add(dummyAction);
    }
    return objectResult;
  }
  Future<List<FirestoreSynchronized>> getAllRemoteItems(String userId) async {
    QuerySnapshot snapshot = await Firestore.instance.collection('users/' + userId + '/next_actions').getDocuments();
    NextAction dummyAction = new NextAction();
    List<DocumentSnapshot> snapshots = snapshot.documents;
    List<FirestoreSynchronized> result = new List();
    for (DocumentSnapshot currentSnapshot in snapshots) {
      NextAction current = dummyAction.fromFirestoreMap(currentSnapshot.data, currentSnapshot.documentID);
      result.add(current);
    }
    return result;
  }
  NextAction fromFirestoreMap(Map<String,dynamic> firestoreMap, String documentId) {
    NextAction result = new NextAction();
    result.firestoreId = documentId;
    result.id = firestoreMap['id'];
    result.name = firestoreMap['name'];
    result.parentId = firestoreMap['parent_id'];
    Timestamp timestamp = firestoreMap['date_created'];
    result.dateCreated = this.timestampToUtcDateTime(timestamp) ;
    result.dateAccomplished = firestoreMap['date_accomplished'];
    return result;
  }
}