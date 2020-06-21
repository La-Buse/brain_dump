import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:brain_dump/models/db_models/unmanaged_item/unmanaged_item.dart';
import 'package:brain_dump/models/database_client.dart';

class UnmanagedItemBloc extends Bloc<UnmanagedItemEvent, UnmanagedItemState> {


  @override
  UnmanagedItemState get initialState => InitialUnmanagedItemState();

  @override
  Stream<UnmanagedItemState> mapEventToState(
    UnmanagedItemEvent event,
  ) async* {
        if (event is InitialEvent) {
          UnmanagedItemState state = InitialUnmanagedItemState();
          await state.initializeItems();
          yield state;
        }
        else if (event is SaveItemEvent) {
          UnmanagedItem item = new UnmanagedItem();
          item.setName(event.name);
          DatabaseClient db = DatabaseClient();
          UnmanagedItem.addUnmanagedItem(item);
        } else if (event is UpdateItemEvent) {
          DatabaseClient db = DatabaseClient();
          UnmanagedItem.updateItem(event.item);
        } else if (event is DeleteItemEvent) {
            DatabaseClient().delete(event.id, 'UnmanagedItem');
        }
        UnmanagedItemState state = InitializedUnmanagedItemState();
        await state.initializeItems();
        yield state;
  }
}
