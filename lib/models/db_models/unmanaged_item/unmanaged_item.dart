import 'package:brain_dump/models/database_client.dart';
import 'package:sqflite/sqflite.dart';

class UnmanagedItem {
  int id;
  String name;
  DateTime dateCreated;
  String firestoreId;

  UnmanagedItem();

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

  static Future<int> updateItem(UnmanagedItem item) async {
    Database db = await DatabaseClient().database;
    return db.update('UnmanagedItem', item.toMap(),
        where: 'id = ?', whereArgs: [item.id]);
  }

  static Future<UnmanagedItem> addUnmanagedItem(UnmanagedItem item) async {
    Database myDatabase = await DatabaseClient().database;
    item.id = await myDatabase.insert('UnmanagedItem', item.toMap());
    return item;
  }

  static Future<UnmanagedItem> getItemById(int id) async {
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

  static Future<List<UnmanagedItem>> readUnmanagedItems() async {
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
}