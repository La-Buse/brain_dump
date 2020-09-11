import 'package:brain_dump/models/database_client.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import 'package:brain_dump/models/firestore_synchronized.dart';

class UnmanagedItem extends FirestoreSynchronized {
  int id;
  String name;
  DateTime dateCreated;
  String firestoreId;

  UnmanagedItem();

  String getLocalDbTableName() {
    return 'UnmanagedItem';
  }
  fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.name = map['name'];
    this.dateCreated = DateTime.parse(map['date_created']);
    this.firestoreId = map['firestore_id'];
  }

  setName(String newName) {
    this.name = newName;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'name':this.name
    };
    if (id != null) {
      map['id'] = this.id;
    }
    if (this.dateCreated != null) {
      map['date_created'] = this.dateCreated.toIso8601String();
    } else {
      map['date_created'] = DateTime.now().toUtc().toIso8601String();
    }
    if (this.firestoreId != null) {
      map['firestore_id'] = this.firestoreId;
    }
    return map;
  }

  Future<void> updateItemLocalDbFields() async {
    Database db = await DatabaseClient().database;
    return db.update('UnmanagedItem', this.toMap(),
        where: 'id = ?', whereArgs: [this.id]);
  }

  Future<int> addItemToLocalDb() async {
    Database myDatabase = await DatabaseClient().database;
    this.id = await myDatabase.insert(this.getLocalDbTableName(), this.toMap());
    return this.id;
  }
  Future<void> deleteFromLocalDb() async {
    await DatabaseClient().delete(this.id, this.getLocalDbTableName());
  }

  Future<UnmanagedItem> getItemById(int id) async {
    var dbClass = DatabaseClient();
    Database db = await dbClass.database;
    var result = await  db.rawQuery( 'SELECT * FROM UnmanagedItem WHERE id = ?', [id]);
    UnmanagedItem foundItem = new UnmanagedItem();
    try {
      foundItem.fromMap(result[0]);
    } catch (Exception) {
      return null;
    }
    return foundItem;
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'name': this.name,
      'id': this.id,
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
    return Firestore.instance.collection('users/' + userId + '/unmanaged_items');
  }
  int getId() {
    return this.id;
  }
  Future<List<FirestoreSynchronized>> readAllLocalItems() async {
    Database myDatabase = await DatabaseClient().database;
    List<Map<String, dynamic>> result =
        await myDatabase.rawQuery('SELECT * FROM UnmanagedItem');
    List<UnmanagedItem> items = [];
    result.forEach((map) {
      UnmanagedItem item = new UnmanagedItem();
      item.fromMap(map);
      items.add(item);
    });
    return items;
  }
  Future<List<FirestoreSynchronized>> getAllRemoteItems(String userId) async {
    QuerySnapshot snapshot = await Firestore.instance.collection('users/' + userId + '/unmanaged_items').getDocuments();
    UnmanagedItem dummyItem = new UnmanagedItem();
    List<DocumentSnapshot> snapshots = snapshot.documents;
    List<FirestoreSynchronized> result = new List();
    for (DocumentSnapshot currentSnapshot in snapshots) {
      UnmanagedItem current = dummyItem.fromFirestoreMap(currentSnapshot.data, currentSnapshot.documentID);
      result.add(current);
    }
    return result;
  }
  UnmanagedItem fromFirestoreMap(Map<String,dynamic> firestoreMap, String documentId) {
    UnmanagedItem result = new UnmanagedItem();
    result.firestoreId = documentId;
    result.id = firestoreMap['id'];
    result.name = firestoreMap['name'];
    Timestamp timestamp = firestoreMap['date_created'];
    result.dateCreated = this.timestampToUtcDateTime(timestamp) ;
    return result;
  }
}