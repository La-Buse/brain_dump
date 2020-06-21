import 'package:brain_dump/models/database_client.dart';
import 'package:brain_dump/models/db_models/unmanaged_item/unmanaged_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

@immutable
abstract class UnmanagedItemEvent {
  String name;
  UnmanagedItem item;
  int id;
  UnmanagedItemEvent(String name, UnmanagedItem item, int id) :
        this.name = name,
        this.id = id,
        this.item = item;
}

class SaveItemEvent extends UnmanagedItemEvent {
  SaveItemEvent(String name):super(name, null, null);
}

class UpdateItemEvent extends UnmanagedItemEvent {
  UpdateItemEvent(UnmanagedItem item) :super (null, item, null);
}

class InitialEvent extends UnmanagedItemEvent {
  InitialEvent() : super(null, null, null);
}

class DeleteItemEvent extends UnmanagedItemEvent {
  DeleteItemEvent(int id) : super(null, null, id);
}