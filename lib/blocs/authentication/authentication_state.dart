import 'package:meta/meta.dart';

@immutable
abstract class AuthenticationState {
  final bool isLogin;
  final bool isLoading;

  AuthenticationState(bool isLogin, bool isLoading):
        this.isLogin=isLogin, this.isLoading=isLoading;
}

class InitialAuthenticationState extends AuthenticationState {
  InitialAuthenticationState(bool isLogin, bool isLoading) :
        super(isLogin, isLoading);
}

//class InitializedCalendarState extends CalendarState {
//  InitializedCalendarState()
//}