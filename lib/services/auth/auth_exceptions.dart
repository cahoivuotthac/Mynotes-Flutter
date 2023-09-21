//!a typical way to create Exception class

//login exceptions
class UserNotFoundAuthException implements Exception {} //if wrong email

class WrongPasswordAuthException implements Exception {}

//register exceptions
class WeakPasswordAuthException implements Exception {}

class EmailAlreadyInUseAuthException implements Exception {}

class InvalidEmailAuthException implements Exception {}

//generic exceptions
class GenericAuthException implements Exception {}

class UserNotLoggedInAuthException implements Exception {}

class NotInitializedException implements Exception {}
