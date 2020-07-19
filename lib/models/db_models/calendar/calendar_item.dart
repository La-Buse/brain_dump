import 'package:brain_dump/blocs/workflow/bloc.dart';
import 'package:brain_dump/models/database_client.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import 'package:brain_dump/models/firestore_synchronized.dart';

final  dbTableName = 'CalendarItem';
final monthDays = {
  0:31,
  1:28,
  2:31,
  3:30,
  4:31,
  5:30,
  6:31,
  7:31,
  8:30,
  9:31,
  10:30,
  11:31
};

class CalendarItem extends FirestoreSynchronized {
  int id;
  String name;
  String description;
  DateTime date;
  DateTime dateCreated;
  DateTime dateAccomplished;
  String firestoreId;

  CalendarItem() {

  }

  static List<CalendarItem> dbToObjects(List<Map<String, dynamic>> result) {
    List<CalendarItem> calendarItems = [];
    result.forEach((map) {
      CalendarItem calendarItem = new CalendarItem();
      calendarItem.fromMap(map);
      calendarItems.add(calendarItem);
    });
    return calendarItems;
  }

  Future<int> addItemToLocalDb() async {
    var dbClass = DatabaseClient();
    Database db = await dbClass.database;
    this.id = await db.insert(dbTableName, this.toMap());
    return this.id;
  }

  static Future<List<CalendarItem>> getItemsBetweenTwoDate(DateTime from, DateTime to) async {
    var dbResult =  await _getItemsBetweenTwoDate(from, to);
    return dbToObjects(dbResult);
  }

  static Future<List<Map<String, dynamic>>> _getItemsBetweenTwoDate(DateTime from, DateTime to) async {
    String _from = from.toIso8601String();
    String _to = to.toIso8601String();
    Database db = await DatabaseClient().database;
    List<Map<String, dynamic>> result;
    result = await db.rawQuery( 'SELECT * FROM CalendarItem WHERE date >= ? AND date <= ?', [_from, _to]);
    return result;
  }
  static Future<int> deleteItem(CalendarItem item) async {
    Database db = await DatabaseClient().database;

    return await db.delete(dbTableName, where: 'id = ?', whereArgs: [item.id]);
  }

  Future<void> updateItemDbFields() async {
    var dbClass = DatabaseClient();
    Database db = await dbClass.database;
    Map<String,dynamic> calendarMap = this.toMap();
    this.id = await db.update(dbTableName, calendarMap, where: 'id = ?', whereArgs: [this.id]);
  }

  static Future<List<CalendarItem>> getInitialItems() async {
    DateTime now = new DateTime.now().toUtc();
    DateTime from = new DateTime(now.year, now.month, 1);
    DateTime to = new DateTime(now.year, now.month, monthDays[now.month]);
    List<Map<String, dynamic>> result = await _getItemsBetweenTwoDate(from, to);
    //select * from CalendarItem where date < "2020-06-03T12:00:00.000Z";
    return dbToObjects(result);
  }
  Future<CalendarItem> getItemById(int id) async {
    var dbClass = DatabaseClient();
    Database db = await dbClass.database;
    var result = await  db.rawQuery( 'SELECT * FROM CalendarItem WHERE id = ?', [id]);
    CalendarItem foundItem = new CalendarItem();
    try {
      foundItem.fromMap(result[0]);
    } catch (Exception) {
      return null;
    }
    return foundItem;
  }

  static Future<List<CalendarItem>> readAll(int parentId) async {
    Database db = await DatabaseClient().database;
    List<Map<String, dynamic>> result;
    result = await db.rawQuery( 'SELECT * FROM CalendarItem');
    return dbToObjects(result);
  }

  fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.firestoreId = map['firestore_id'];
    this.name = map['name'];
    this.description = map['description'];
    this.date = DateTime.parse(map['date']);
    this.dateCreated = DateTime.parse(map['date_created']);
    if (map['date_accomplished'] != null) {
      this.dateAccomplished = DateTime.parse(map['date_accomplished']); //TODO mettre ca dans une fonction ou utiliser une librarie qui gere les objets comme du monde
    }
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'name': this.name
    };
    if (id != null) {
      map['id'] = this.id;
    }
    map['date'] = this.date.toIso8601String();
    map['description'] = this.description;
    if (this.dateCreated != null) {
      map['date_created'] = this.dateCreated.toIso8601String();
    } else {
      map['date_created'] = DateTime.now().toUtc().toIso8601String();
    }
    if (this.dateAccomplished != null) {
      map['date_accomplished'] = this.dateAccomplished.toIso8601String();
    }
    if (this.firestoreId != null) {
      map['firestore_id'] = this.firestoreId;
    }

    return map;
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'id':this.id,
      'description':this.description,
      'name': this.name,
      'date':this.date,
      'date_created':this.dateCreated
    };
  }
  String getFirestoreId() {
    return this.firestoreId;
  }
  void setFirestoreId(String id) {
    this.firestoreId = id;
  }
  CollectionReference getItemFirestoreCollection(String userId) {
    return Firestore.instance.collection('users/' + userId + '/calendar_events');
  }
  int getId() {
    return this.id;
  }

}
