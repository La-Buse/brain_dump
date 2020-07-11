import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:brain_dump/models/database_client.dart';
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
      DateTime lastSyncNextActions = await DatabaseClient().getSyncTimeForTable("NextAction");
      QuerySnapshot nextActionDocuments;
      if (lastSyncNextActions != null) {
        nextActionDocuments = await Firestore.instance.collection('users/' + userId + '/next_actions').where("date_created", isGreaterThanOrEqualTo: lastSyncNextActions).getDocuments();
      } else {
        nextActionDocuments = await Firestore.instance.collection('users/' + userId + '/next_actions').getDocuments();
      }
//      int test = new DateTime.now().millisecondsSinceEpoch;
      nextActionDocuments.documents.forEach((element) {

      });
//      var firestoreActions = await Firestore.instance.collection('users/' + userId + '/next_actions').getDocuments();
      yield CloudDataSuccesfullyFetched();
    }
  }




}
