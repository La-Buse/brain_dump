import 'package:brain_dump/models/database_client.dart';
import 'file:///C:/Users/levas/source/repos/brain_dump/lib/models/db_models/unmanaged_item/unmanaged_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

@immutable
abstract class UnmanagedItemEvent {}

class SaveItemEvent extends UnmanagedItemEvent {
  SaveItemEvent(String name) {
    UnmanagedItem item = new UnmanagedItem();
    item.setName(name);
    DatabaseClient db = DatabaseClient();
    UnmanagedItem.addUnmanagedItem(item);
  }
}

class UpdateItemEvent extends UnmanagedItemEvent {
  UpdateItemEvent(UnmanagedItem item) {
    DatabaseClient db = DatabaseClient();
    UnmanagedItem.updateItem(item);
  }
}

class InitialEvent extends UnmanagedItemEvent {

}

class DeleteItemEvent extends UnmanagedItemEvent {
  DeleteItemEvent(int id) {
    DatabaseClient().delete(id, 'UnmanagedItem');
  }
}