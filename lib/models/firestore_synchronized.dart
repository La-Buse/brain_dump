import 'package:cloud_firestore/cloud_firestore.dart';

abstract class FirestoreSynchronized<T> {
  Map<String, dynamic> toFirestoreMap();
  String getFirestoreId();
  void setFirestoreId(String id);
  Future<FirestoreSynchronized> getItemById(int id);
  addItemToFirestore(String userId) {
    this.getItemFirestoreCollection(userId).add(
        this.toFirestoreMap()
    ).then((value) async {
      FirestoreSynchronized toBeUpdated = await this.getItemById(this.getId());
      if (toBeUpdated != null) {
        toBeUpdated.setFirestoreId(value.documentID);
        //if the current object is modified, it causes the id of the in-memory item to be reset to 1
        //when an item is edited or deleted later through the calendar page, it fails because
        //the item with id 1 is not found in the database
        toBeUpdated.updateItemDbFields();
        //in case item was created and modified while offline
        toBeUpdated.getItemFirestoreCollection(userId).document(value.documentID).setData(toBeUpdated.toFirestoreMap());
      } else {
        //this means the item was both added and deleted while offline
        await value.delete();
      }
    });
    //TODO this instruction should be out of this method
    this.addItemToLocalDb();
  }
  updateFirestoreData(String userId) {
    if (this.getFirestoreId() != null) {
      this.getItemFirestoreCollection(userId).document(this.getFirestoreId()).setData(this.toFirestoreMap());
    }
  }
  deleteFirestoreItem(String userId) {
    if (this.getFirestoreId() != null) {
      this.getItemFirestoreCollection(userId).document(this.getFirestoreId()).delete();
    }
  }
  CollectionReference getItemFirestoreCollection(String userId);
  int getId();
  Future<int> addItemToLocalDb();
  Future<void> updateItemDbFields();
}