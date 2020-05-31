import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:brain_dump/models/database_client.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import './bloc.dart';
import 'bloc.dart';

class AuthenticationBloc  extends Bloc<AuthenticationEvent, AuthenticationState> {
  bool isLogin = true;
  bool isLoading = false;

  @override
  AuthenticationState get initialState => InitialAuthenticationState(isLogin, isLoading);

  @override
  Stream<AuthenticationState> mapEventToState(
      AuthenticationEvent event,
  ) async* {
    if (event is IsLoginChanged) {
      yield InitialAuthenticationState(event.isLogin, isLoading);
     // yield InitialCalendarState(_events, _selectedDayEvents, _selectedDay, _newEventDate, '', '');
    } else if (event is IsLoadingChanged) {
      yield InitialAuthenticationState(isLogin, event.isLoading);
    }

  }




}
