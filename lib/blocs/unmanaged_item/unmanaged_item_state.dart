import 'package:brain_dump/models/unmanaged_item.dart';
import 'package:meta/meta.dart';
import 'package:brain_dump/models/database_client.dart';

@immutable
abstract class UnmanagedItemState {
  Future<void> initializeItems();
  int getItemsLength();
  UnmanagedItem getItem(int index);
}

class InitialUnmanagedItemState extends UnmanagedItemState {

  List<UnmanagedItem> items = [];

  int getItemsLength() {
    return items.length;
  }

  UnmanagedItem getItem(int index) {
    if (index <= this.items.length - 1) {
      return this.items[index];
    } else {
      return null;
    }
  }

  Future<void> initializeItems() async {
    DatabaseClient db = DatabaseClient();
    List<UnmanagedItem> items = await db.readUnmanagedItems();
    this.items = items;
  }
}