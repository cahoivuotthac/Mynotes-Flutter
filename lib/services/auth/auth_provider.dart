//! to encapsulate all the providers which help to signin/logout/authenticate users
import 'package:freecodecamp/services/auth/auth_user.dart';

abstract class AuthProvider {
  Future<void> initialized(); //to initialize the authentication provider
  AuthUser?
      get currentUser; //to retrieve the current authenticated user. If no user is authenticated, return null
  Future<AuthUser?> logIn({
    //if login successes, return a Future that resolves to an AuthUser object. Otherwise, return null
    required String email,
    required String password,
  });

  Future<AuthUser?> createUser({
    //same explanation as above
    required String email,
    required String password,
  });

  Future<void> logOut(); //to log out the current authenticated user
  Future<void> sendEmailVerification();
}
