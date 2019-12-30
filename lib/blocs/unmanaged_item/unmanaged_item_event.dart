import 'package:brain_dump/models/database_client.dart';
import 'package:brain_dump/models/unmanaged_item.dart';
import 'package:meta/meta.dart';

@immutable
abstract class UnmanagedItemEvent {}

class SaveItemEvent extends UnmanagedItemEvent {
  SaveItemEvent(String name) {
    UnmanagedItem item = new UnmanagedItem();
    item.setName(name);
    DatabaseClient db = DatabaseClient();
    db.addUnmanagedItem(item);
  }
}

class InitialEvent extends UnmanagedItemEvent {

}

class DeleteItemEvent extends UnmanagedItemEvent {
  DeleteItemEvent(int id) {
    DatabaseClient().delete(id, 'UnmanagedItem');
  }
}