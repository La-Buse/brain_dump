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
          DatabaseClient db = DatabaseClient();
          item = await UnmanagedItem.addUnmanagedItem(item);
          FirebaseUser user = await FirebaseAuth.instance.currentUser();
          String userId = user.uid;
          DocumentReference ref = await Firestore.instance.collection('users/' + userId + '/unmanaged_items').add(
              {
                'name': item.name,
                'id': item.id,
                'date_created': item.dateCreated,
              }
          );
        } else if (event is UpdateItemEvent) {
          DatabaseClient db = DatabaseClient();
          UnmanagedItem.updateItem(event.item);
          FirebaseUser user = await FirebaseAuth.instance.currentUser();
          String userId = user.uid;
          var ref = await Firestore.instance.collection('users/' + userId + '/unmanaged_items').getDocuments();
          var documents = ref.documents.where((f) {return f['id'] == event.item.id;}).toList();
          documents.forEach((element) {
            Firestore.instance.collection('users/' + userId + '/unmanaged_items').document(element.documentID).updateData({"name": event.item.name});
          });
          print(ref);
        } else if (event is DeleteItemEvent) {
            DatabaseClient().delete(event.id, 'UnmanagedItem');
            FirebaseUser user = await FirebaseAuth.instance.currentUser();
            String userId = user.uid;
            var ref = await Firestore.instance.collection('users/' + userId + '/unmanaged_items').getDocuments();
            var documents = ref.documents.where((f) {return f['id'] == event.id;}).toList();
            documents.forEach((element) {
              Firestore.instance.collection('users/' + userId + '/unmanaged_items').document(element.documentID).delete();
            });
        }
        UnmanagedItemState state = InitializedUnmanagedItemState();
        await state.initializeItems();
        yield state;
  }
}
