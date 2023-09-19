import 'package:freecodecamp/services/auth/auth_exceptions.dart';
import 'package:freecodecamp/services/auth/auth_provider.dart';
import 'package:freecodecamp/services/auth/auth_user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider();
    test('Should not be initialized to begin with', () {
      expect(provider._isInitialized, false);
    });
  });
}

class NotInitializedException implements Exception {}

//create a AuthProvider mock
class MockAuthProvider implements AuthProvider {
  //use underscore like this to tell that these members are private
  var _isInitialized = false;
  AuthUser? _user;
  bool get isInitialized =>
      _isInitialized; //isInitialized is a property which belongs to firebase

  //here are all the functionalities the AuthProvider abstract class required us to implement

  @override
  Future<void> initialized() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser?> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) {
      //1. check to make sure we are initialized
      throw NotInitializedException();
    }
    await Future.delayed(const Duration(seconds: 1)); //2. fake making api calls
    return logIn(
      //3. call the login function with the same email and password and return the result
      email: email,
      password: password,
    );
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<AuthUser?> logIn({
    required String email,
    required String password,
  }) {
    if (!isInitialized) throw NotInitializedException();
    if (email == 'foo@bar.com') throw UserNotFoundAuthException();
    if (password == 'foobar') throw WrongPasswordAuthException();
    const user = AuthUser(isEmailVerified: false);
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    const newUser = AuthUser(isEmailVerified: true);
    _user = newUser;
  }
}
