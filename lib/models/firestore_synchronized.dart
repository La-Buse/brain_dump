import 'package:cloud_firestore/cloud_firestore.dart';

abstract class FirestoreSynchronized {
  //concrete methods
  addItemToFirestore(String userId) {
    Map<String, dynamic> myMap = this.toFirestoreMap();
    this.getItemFirestoreCollection(userId).add(
        myMap
    ).then((value) async {
      FirestoreSynchronized toBeUpdated = await this.getItemById(this.getId());
      if (toBeUpdated != null) {
        toBeUpdated.setFirestoreId(value.documentID);
        //if the current object is modified, it causes the id of the in-memory item to be reset to 1
        //when an item is edited or deleted later through the calendar page, it fails because
        //the item with id 1 is not found in the database
        toBeUpdated.updateItemLocalDbFields();
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

  //abstract methods
  Map<String, dynamic> toFirestoreMap();
//  FirestoreSynchronized fromFirestoreMap();
  String getFirestoreId();
  void setFirestoreId(String id);
  Future<FirestoreSynchronized> getItemById(int id);
  CollectionReference getItemFirestoreCollection(String userId);
  int getId();
  Future<int> addItemToLocalDb();
  Future<void> updateItemLocalDbFields();
  Future<void> deleteFromLocalDb();
  Future<List<FirestoreSynchronized>> readAllLocalItems();
  Future<List<FirestoreSynchronized>> getAllRemoteItems(String userId);
  fromFirestoreMap(Map<String,dynamic> firestoreMap, String documentId);
  String getLocalDbTableName();

  DateTime timestampToUtcDateTime(Timestamp timestamp) {
    double milliseconds = timestamp.seconds * 1000 + timestamp.nanoseconds / 1000000;
    DateTime time = new DateTime.fromMillisecondsSinceEpoch(milliseconds.toInt()).toUtc();
    return time;
  }

  static Map<int, FirestoreSynchronized> listToMap(List<FirestoreSynchronized> items) {
    Map<int, FirestoreSynchronized> result = new Map();
    for (FirestoreSynchronized item in items) {
      result.putIfAbsent(item.getId(), () => item);
    }
    return result;
  }
}