import 'package:brain_dump/models/database_client.dart';
import 'package:sqflite/sqflite.dart';

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

  static List<CalendarItem> dbToObjects(List<Map<String, dynamic>> result) {
    List<CalendarItem> calendarItems = [];
    result.forEach((map) {
      CalendarItem calendarItem = new CalendarItem();
      calendarItem.fromMap(map);
      calendarItems.add(calendarItem);
    });
    return calendarItems;
  }

  static Future<int> addCalendarItemToDb(CalendarItem item) async {
    var dbClass = DatabaseClient();
    Database db = await dbClass.database;
    item.id = await db.insert(dbTableName, item.toMap());
    return item.id;
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

  static Future<List<CalendarItem>> getInitialItems() async {
    DateTime now = new DateTime.now().toUtc();
    DateTime from = new DateTime(now.year, now.month, 1);
    DateTime to = new DateTime(now.year, now.month, monthDays[now.month]);
    List<Map<String, dynamic>> result = await _getItemsBetweenTwoDate(from, to);
    //select * from CalendarItem where date < "2020-06-03T12:00:00.000Z";
    return dbToObjects(result);
  }

  static Future<List<CalendarItem>> readAll(int parentId) async {
    Database db = await DatabaseClient().database;
    List<Map<String, dynamic>> result;
    result = await db.rawQuery( 'SELECT * FROM CalendarItem');
    return dbToObjects(result);
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
      map['date_created'] = DateTime.now().toUtc().toIso8601String();
    }
    if (this.dateAccomplished != null) {
      map['date_accomplished'] = this.dateAccomplished.toIso8601String();
    }

    return map;
  }

}
