import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:brain_dump/models/db_models/unmanaged_item/unmanaged_item.dart';
import 'package:brain_dump/models/database_client.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UnmanagedItemBloc extends Bloc<UnmanagedItemEvent, UnmanagedItemState> {

  @override
  UnmanagedItemState get initialState => InitialUnmanagedItemState();

  @override
  Stream<UnmanagedItemState> mapEventToState(
    UnmanagedItemEvent event,
  ) async* {
        FirebaseUser user = await FirebaseAuth.instance.currentUser();
        String userId = user.uid;
        if (event is InitialEvent) {
          UnmanagedItemState state = InitialUnmanagedItemState();
          await state.initializeItems();
          yield state;
        }
        else if (event is SaveItemEvent) {
          UnmanagedItem item = new UnmanagedItem();
          item.id = new DateTime.now().millisecondsSinceEpoch;
          item.setName(event.name);
          item.dateCreated = new DateTime.now().toUtc();
          item.addItemToFirestore(userId);
        } else if (event is UpdateItemEvent) {
          UnmanagedItem item = await UnmanagedItem().getItemById(event.item.id);
          item.name = event.item.name;
          item.updateItemLocalDbFields();
          item.updateFirestoreData(userId);
        } else if (event is DeleteItemEvent) {
          UnmanagedItem toBeDeleted = await UnmanagedItem().getItemById(event.id);
          DatabaseClient().delete(event.id, 'UnmanagedItem');
          toBeDeleted.deleteFirestoreItem(userId);
        }
        UnmanagedItemState state = InitializedUnmanagedItemState();
        await state.initializeItems();
        yield state;
  }
}
