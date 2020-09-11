import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:brain_dump/models/database_client.dart';
import 'package:brain_dump/models/db_models/calendar/calendar_item.dart';
import 'package:brain_dump/models/db_models/next_actions/next_action.dart';
import 'package:brain_dump/models/db_models/next_actions/next_action_context.dart';
import 'package:brain_dump/models/db_models/unmanaged_item/unmanaged_item.dart';
import 'package:brain_dump/models/firestore_synchronized.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './bloc.dart';
import 'bloc.dart';

class DashboardBloc  extends Bloc<DashboardEvent, DashboardState> {


  @override
  DashboardState get initialState => InitialDashboardState();

  @override
  Stream<DashboardState> mapEventToState(
      DashboardEvent event,
      ) async* {
    if (event is SyncDataFromCloud) {
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      String userId = user.uid;
      //todo compare last update time for each local table to remote tables to avoid fetching useless data
      List<FirestoreSynchronized> allClasses = [NextAction(), NextActionContext(), CalendarItem(), UnmanagedItem()];
      for (FirestoreSynchronized currentClass in allClasses) {
        List<FirestoreSynchronized> localItems = await currentClass.readAllLocalItems();
        List<FirestoreSynchronized> remoteItems = await currentClass.getAllRemoteItems(userId);
        Map<int, FirestoreSynchronized> localItemsMap = FirestoreSynchronized.listToMap(localItems);
        Map<int, FirestoreSynchronized> remoteItemsMap = FirestoreSynchronized.listToMap(remoteItems);
        for (int key in remoteItemsMap.keys) {
          if (localItemsMap.containsKey(key)) {
            FirestoreSynchronized local = localItemsMap[key];
            FirestoreSynchronized remote = remoteItemsMap[key];
            if (!compareFirestoreSynchronized(local, remote)) {
              remote.updateItemLocalDbFields();
            }
            //local items do not contain remote item, so add locally
          } else {
            FirestoreSynchronized remote = remoteItemsMap[key];
            remote.addItemToLocalDb();
          }
        }
        for (int key in localItemsMap.keys) {
          if (!remoteItemsMap.containsKey(key)) {
            FirestoreSynchronized local = localItemsMap[key];
            local.deleteFromLocalDb();
          }
        }
      }

//      var firestoreActions = await Firestore.instance.collection('users/' + userId + '/next_actions').getDocuments();
      yield CloudDataSuccesfullyFetched();
    }
  }

  bool compareFirestoreSynchronized(FirestoreSynchronized one, FirestoreSynchronized two) {
    Map mapOne = one.toFirestoreMap();
    Map mapTwo = two.toFirestoreMap();
    for (String oneKey in mapOne.keys) {
      Object valueOne = mapOne[oneKey];
      Object valueTwo = mapOne[oneKey];
      if (valueOne != valueTwo) {
        return false;
      }
    }
    return true;
  }




}
