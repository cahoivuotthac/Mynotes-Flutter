import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/cupertino.dart';

@immutable //to tell that this class and subclasses  are going to be immuatable
class AuthUser {
  //to know user's email is verified or not
  final bool isEmailVerified;

  //constructor
  const AuthUser(this.isEmailVerified);
}
