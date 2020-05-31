import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:brain_dump/blocs/authentication/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Authentication extends StatefulWidget {
  @override
  _AuthenticationState createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
  final authenticationBloc =  AuthenticationBloc();
  final auth = FirebaseAuth.instance;
  var _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  var _isLogin = true;
  String _userEmail = '';
  String _userName = '';
  String _userPassword = '';

  void _trySubmit(BuildContext newContext) {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus(); //closes keyboard by removing focus from any input field
    if (isValid) {
      _formKey.currentState.save();
      _submitForm(_userEmail.trim(), _userPassword, _userName, _isLogin, newContext);
    }
  }
  void _submitForm(String email, String password, String username, bool isLogin, BuildContext newContext) async {
    AuthResult authResult;
    try {
      authenticationBloc.add(IsLoadingChanged(true));
      if (_isLogin) {
        authResult = await auth.signInWithEmailAndPassword(email: email, password: password);
      } else {
        authResult = await auth.createUserWithEmailAndPassword(email: email, password: password);
        await Firestore.instance.collection('users').document(authResult.user.uid).setData({
          'username':username,
          'email':email,
        });
      }
    } on PlatformException catch (err) {
      var message= 'An error occurred, please check your credentials!';
      if (err.message != null) {
        message = err.message;
      }
      authenticationBloc.add(IsLoadingChanged(false));
      Scaffold.of(newContext).showSnackBar(SnackBar(content: Text(message), backgroundColor: Theme.of(newContext).errorColor,));
    } catch (err) {
      print(err); //for debugging
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return new BlocBuilder(
        bloc: authenticationBloc,
      builder: (BuildContext context, AuthenticationState state) {
        return Scaffold
          (backgroundColor: Theme.of(context).primaryColor,
            body: Builder(builder: (newContext) => Center(
              child: Card(
                  margin: EdgeInsets.all(20),
                  child:SingleChildScrollView(
                      child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Form(
                              key: _formKey,
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget> [
                                    TextFormField(
                                      key: ValueKey('email'),
                                      validator: (value) {
                                        if (value.isEmpty || !value.contains('@')) {
                                          return 'Please enter a valid email address';
                                        }
                                        return null;
                                      },

                                      keyboardType: TextInputType.emailAddress,
                                      decoration: InputDecoration(
                                          labelText: 'Email address'
                                      ),
                                      onSaved: (value) {
                                        _userEmail = value;
                                      },
                                    ),
                                    if (!state.isLogin)
                                      TextFormField(
                                        key: ValueKey('username'),
                                        validator: (value) {
                                          if (value.isEmpty || value.length < 4) {
                                            return 'Please enter at least 4 characters';
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                            labelText: 'Username'
                                        ),
                                        onSaved: (value) {
                                          _userName = value;
                                        },
                                      ),
                                    TextFormField(
                                      key: ValueKey('password'),
                                      validator: (value) {
                                        if (value.isEmpty || value.length < 7) {
                                          return 'Password must be at least 7 characters long';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                          labelText: 'Password'
                                      ),
                                      onSaved: (value) {
                                        _userPassword = value;
                                      },
                                      obscureText: true,
                                    ),
                                    SizedBox(height:12),
                                    if(state.isLoading) CircularProgressIndicator(),
                                    if (!state.isLoading)
                                      RaisedButton(
                                        child: Text(state.isLogin ? 'Login': 'Sign up'),
                                        onPressed: () {
                                          _trySubmit(newContext);
//                                        Navigator.of(context).pushNamedAndRemoveUntil('/Dashboard', (Route<dynamic> route) {
//                                          return route.settings.name.compareTo('/') == 0;
//                                        },arguments: null);
                                        },
                                      ),
                                    if (!state.isLoading)
                                      FlatButton(
                                        child: Text(state.isLogin ? 'Create new account':'I already have an account'),
                                        onPressed: () {
                                          _isLogin = !_isLogin;
                                          authenticationBloc.add(IsLoginChanged(_isLogin));
                                        },
                                      )
                                  ]
                              )
                          )
                      )
                  )),
            ))
        );
      }
    );

  }
  @override
  void dispose() {
    super.dispose();
    authenticationBloc.close();
  }
}
