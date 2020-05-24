import 'file:///C:/Users/levas/source/repos/brain_dump/lib/models/db_models/unmanaged_item/unmanaged_item.dart';
import 'package:reflectable/mirrors.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:async/async.dart';
import 'package:brain_dump/models/db_models/next_actions/next_action.dart';

final int launchVersion = 8;
final int currentVersion = 17;

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
//    String databaseDirectory = join(directory.path, 'database_v' + currentVersion.toString() + '.db');
    String databaseDirectory = join(directory.path, 'database.db');
    var bdd =
        await openDatabase(databaseDirectory, version: currentVersion, onUpgrade: _onUpgrade);
    return bdd;
  }

  Future<Null> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < launchVersion) { // switch to " oldVersion < newVersion" to apply modifications
      await _onCreate(db, newVersion);
    }
  }

  Future<Null> _onCreate(Database db, int version) async {
    List<dynamic> myclasses = [ NextAction] ;
    getAllDataInMemory(myclasses);
    await db.execute('''
      CREATE TABLE UnmanagedItem (
        id INTEGER PRIMARY KEY, 
        name TEXT NOT NULL,
        date_created TEXT NOT NULL)
    ''');
    await db.execute('''
        CREATE TABLE NextAction (
        id INTEGER PRIMARY KEY,
        parent_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        date_created TEXT NOT NULL,
        date_accomplished TEXT)
    ''');
    await db.execute('''
        CREATE TABLE NextActionContext (
        id INTEGER PRIMARY KEY,
        parent_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        date_created TEXT NOT NULL,
        date_accomplished TEXT)
    ''');
    await db.execute('''
        CREATE TABLE CalendarItem (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        date_created TEXT NOT NULL,
        date_accomplished TEXT)
    ''');
  }

  Future<Null> getAllDataInMemory(List classes) async {
    for (ClassMirror c in classes) {
      var result = c.invoke('readAll', []);
    }
  }

  Future<int> delete(int id, String table) async {
    Database db = await database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }


}
