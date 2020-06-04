import 'package:brain_dump/models/database_client.dart';
import 'package:sqflite/sqflite.dart';

final  dbTableName = 'CalendarItem';

class CalendarItem {
  int id;
  String name;
  String description;
  DateTime date;
  DateTime dateCreated;
  DateTime dateAccomplished;
//  CalendarItem(String name, String description, DateTime date, DateTime dateCreated) {
//    this.name = name;
//    this.description = description;
//    this.date = date;
//    this.dateCreated = dateCreated;
//  }
  CalendarItem() {

  }

  static Future<int> addCalendarItemToDb(CalendarItem item) async {
    var dbClass = DatabaseClient();
    Database db = await dbClass.database;
    item.id = await db.insert(dbTableName, item.toMap());
    return item.id;
  }

  static Future<List<CalendarItem>> readAll(int parentId) async {
    Database db = await DatabaseClient().database;
    List<Map<String, dynamic>> result;
    result = await db.rawQuery( 'SELECT * FROM CalendarItem');


    List<CalendarItem> calendarItems = [];
    result.forEach((map) {
      CalendarItem calendarItem = new CalendarItem();
      calendarItem.fromMap(map);
      calendarItems.add(calendarItem);
    });
    return calendarItems;
  }

  fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
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
      map['date_created'] = DateTime.now().toIso8601String();
    }
    if (this.dateAccomplished != null) {
      map['date_accomplished'] = this.dateAccomplished.toIso8601String();
    }

    return map;
  }

}
