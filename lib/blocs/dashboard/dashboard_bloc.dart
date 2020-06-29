import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:brain_dump/models/database_client.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import './bloc.dart';
import 'bloc.dart';

class DashboardBloc  extends Bloc<DashboardEvent, DashboardState> {


  @override
  DashboardState get initialState => InitialDashboardState();

  @override
  Stream<DashboardState> mapEventToState(
      DashboardEvent event,
      ) async* {
    yield CloudDataSuccesfullyFetched();
  }




}
