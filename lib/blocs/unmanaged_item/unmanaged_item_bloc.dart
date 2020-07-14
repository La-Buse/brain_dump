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
          item = await UnmanagedItem.addUnmanagedItem(item);
          Firestore.instance.collection('users/' + userId + '/unmanaged_items').add(
              {
                'name': item.name,
                'id': item.id,
                'date_created': item.dateCreated,
              }
          ).then((value) async {
            UnmanagedItem toBeUpdated = await UnmanagedItem.getItemById(item.id);
            if (toBeUpdated != null) {
              //this means the item was both added and deleted while offline
              value.delete();
            } else {
              toBeUpdated.firestoreId = value.documentID;
              //update in case item was created and updated offline
              Firestore.instance.collection('users/' + userId + '/unmanaged_items')
                  .document(toBeUpdated.firestoreId)
                  .updateData({
                    'name': event.item.name,
                  });
              UnmanagedItem.updateItem(toBeUpdated);
            }
          });
        } else if (event is UpdateItemEvent) {
          UnmanagedItem.updateItem(event.item);
          UnmanagedItem item = await UnmanagedItem.getItemById(event.item.id);
          if (item != null && item.firestoreId != null) {
            Firestore.instance.collection('users/' + userId + '/unmanaged_items').document(item.firestoreId).updateData({"name": event.item.name});
          }
        } else if (event is DeleteItemEvent) {
            UnmanagedItem toBeDeleted = await UnmanagedItem.getItemById(event.id);
            DatabaseClient().delete(event.id, 'UnmanagedItem');
            if (toBeDeleted.firestoreId != null) {
              Firestore.instance.collection('users/' + userId + '/calendar_events').document(toBeDeleted.firestoreId).delete();
            }
        }
        UnmanagedItemState state = InitializedUnmanagedItemState();
        await state.initializeItems();
        yield state;
  }
}
