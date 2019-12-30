
import 'package:brain_dump/models/unmanaged_item.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:async/async.dart';

class DatabaseClient {
  Database _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database;
    } else {
      _database = await create();
      return _database;
    }
  }

  Future<Database> create() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String databaseDirectory = join(directory.path, 'database.db');
    var bdd = await openDatabase(databaseDirectory, version: 1, onCreate: _onCreate);
    return bdd;
  }

  Future<Null> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE UnmanagedItem (
        id INTEGER PRIMARY KEY, 
        name TEXT NOT NULL,
        date_created TEXT NOT NULL)
    ''');
  }

  Future<UnmanagedItem> addUnmanagedItem(UnmanagedItem item) async {
    Database myDatabase = await database;
    item.id = await myDatabase.insert('UnmanagedItem', item.toMap());
    return item;
  }

  Future<List<UnmanagedItem>> readUnmanagedItems() async {
    Database myDatabase = await database;
    List<Map<String, dynamic>> result = await myDatabase.rawQuery('SELECT * FROM UnmanagedItem');
    List<UnmanagedItem> items = [];
    result.forEach((map) {
      UnmanagedItem item = new UnmanagedItem();
      item.fromMap(map);
      items.add(item);
    });
    return items;
  }

  Future<int> delete(int id, String table) async {
    Database db = await database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }
  Future<int> updateItem(UnmanagedItem item) async {
    Database db = await database;
    return db.update('UnmanagedItem', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
  }
}