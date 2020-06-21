import 'package:brain_dump/models/db_models/unmanaged_item/unmanaged_item.dart';
import 'package:meta/meta.dart';
import 'package:brain_dump/models/database_client.dart';

@immutable
abstract class UnmanagedItemState {
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
    List<UnmanagedItem> items = await UnmanagedItem.readUnmanagedItems();
    this.items = items;
  }
}

class InitializedUnmanagedItemState extends UnmanagedItemState {

}

class InitialUnmanagedItemState extends UnmanagedItemState {

}
