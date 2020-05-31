import 'package:brain_dump/models/db_models/unmanaged_item/unmanaged_item.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@immutable
abstract class AuthenticationEvent {

}

class IsLoginChanged extends AuthenticationEvent {
    bool isLogin;
    IsLoginChanged(bool isLogin):this.isLogin = isLogin;
}

class IsLoadingChanged extends AuthenticationEvent {
    bool isLoading;
    IsLoadingChanged(bool isLoading):this.isLoading=isLoading;
}

