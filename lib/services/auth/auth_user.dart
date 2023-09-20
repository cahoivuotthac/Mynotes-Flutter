import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/cupertino.dart';

@immutable //! annotation
//to tell that this class and its subclasses are going to be immuatable
class AuthUser {
  //to know user's email is verified or not
  final bool isEmailVerified;

  //constructor
  const AuthUser(
      {required this.isEmailVerified}); //when wanna use 'named parameter'

  //!factory constructor
  //make isEmailVerified required
  factory AuthUser.fromFirebase(User user) => AuthUser(
      isEmailVerified: user
          .emailVerified); //write like this because we use 'named parameter' for constructor above
}
