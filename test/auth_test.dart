import 'package:freecodecamp/services/auth/auth_exceptions.dart';
import 'package:freecodecamp/services/auth/auth_provider.dart';
import 'package:freecodecamp/services/auth/auth_user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider();
    test('Should not be initialized to begin with', () {
      expect(provider.isInitialized, false);
    });

    test('Cannot log out if not initialized', () {
      expect(
        //excute the logOut function and then expect it to throw an exception of type NotInitializedException
        provider.logOut(),
        throwsA(
          const TypeMatcher<NotInitializedException>(),
        ),
      );
    });

    test('Should be able to be initialized', () async {
      await provider.initialized();
      expect(provider.isInitialized, true);
    });

    test('User should be null after initialization', () {
      expect(provider.currentUser, null);
    });

    test(
      'Should be able to initialize in less than 2 seconds',
      () async {
        await provider.initialized();
        expect(provider.isInitialized, true);
      },
      timeout: const Timeout(Duration(
          seconds:
              2)), //if the initialized process takes more than 2 seconds to end up, then the test will fail
    );

    test('Create user should delegate to login function', () async {
      final badEmailUser = provider.createUser(
        email: 'foo@bar.com',
        password: 'anypassword',
      );
      expect(
        badEmailUser,
        throwsA(const TypeMatcher<UserNotFoundAuthException>()),
      );

      final badPasswordUser = provider.createUser(
        email: 'someone@bar.com',
        password: 'foobar',
      );
      expect(
        badPasswordUser,
        throwsA(const TypeMatcher<WrongPasswordAuthException>()),
      );

      final user = await provider.createUser(
        //mock don't need a correct form of email like firebase does
        email: 'hien', //whatever as long as it's not an email of badEmailUser
        password:
            'phan', //whatever as long as it's not an email of wrongPasswordUser
      );
      expect(provider.currentUser,
          user); //expect the currentUser equal to this user
      expect(provider.isInitialized, false);

      test('Logged in user should be able to get verified', () async {
        await provider.sendEmailVerification();
        final user = provider.currentUser;
        expect(user, isNotNull);
        expect(user!.isEmailVerified, true);
      });

      test('Should be able to log out and log in again', () async {
        await provider.logOut();
        await provider.logIn(
          email: 'hien',
          password: 'phan',
        );
        final user = provider.currentUser;
        expect(user, isNotNull);
      });
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  //use underscore to tell that these members are private
  var _isInitialized = false;
  AuthUser? _user;
  bool get isInitialized =>
      _isInitialized; //isInitialized is a property which belongs to firebase

  //here are all the functions that AuthProvider abstract class required us to implement
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
