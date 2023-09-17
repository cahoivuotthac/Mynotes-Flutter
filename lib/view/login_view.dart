import 'package:flutter/material.dart';
import 'package:freecodecamp/constants/routes.dart';
import '../services/auth/auth_exceptions.dart';
import '../services/auth/auth_service.dart';
import '../utilities/show_error_dialog.dart'; //when you want to use a specific thing in this package, if not have show then will show everything in this package

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email; //firebase setup
  late final TextEditingController _password; //firebase setup
  @override
  void initState() {
    // use TextEditingController need this function
    //firebase setup
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    // use TextEditingController need this function
    //firebase setup
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Column(
        children: [
          TextField(
            controller: _email,
            enableSuggestions:
                false, //no suggestions apparing on screen's keyboard
            autocorrect:
                false, //no matter what user entered is right or wrong, just let them enter 'cause it's personal informations
            keyboardType: TextInputType
                .emailAddress, //make @ and .com appear on screen's keyboard (easy for user to type email, cause all emails need it)
            decoration: const InputDecoration(
              hintText: 'Enter your email address',
            ),
          ),
          TextField(
            controller: _password,
            obscureText:
                true, //make sure that user's password isn't visible on screen(hide it)
            enableSuggestions:
                false, //no suggestions apparing on screen's keyboard
            autocorrect:
                false, //no matter what user entered is right or wrong, just let them enter 'cause it's personal informations
            decoration: const InputDecoration(
              hintText: 'Enter your password',
            ),
          ),
          TextButton(
              onPressed: () async {
                //this is a callback function
                //grab email and password that users just entered
                final email = _email.text;
                final password = _password.text;

                //if user entered wrong account
                try {
                  await AuthService.firebase().logIn(
                    email: email,
                    password: password,
                  );
                  final user = AuthService.firebase().currentUser;
                  if (user?.isEmailVerified ?? false) {
                    //if user's email is verified
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      notesRoute,
                      (route) => false,
                    );
                  } else {
                    //if user's email is NOT verified
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      verifyEmailRoute,
                      (route) => false,
                    );
                  }
                } on UserNotFoundAuthException {
                  // ignore: use_build_context_synchronously
                  await showErrorDialog(
                    context,
                    'User not found',
                  );
                } on WrongPasswordAuthException {
                  // ignore: use_build_context_synchronously
                  await showErrorDialog(
                    context,
                    'Wrong credentials',
                  );
                } on GenericAuthException {
                  // ignore: use_build_context_synchronously
                  await showErrorDialog(
                    context,
                    'Authentication error',
                  );
                }
              },
              child: const Text('Login')),
          TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  registerRoute,
                  (route) => false,
                ); //remove everything about the current route (which is loginview) to go to registerview directly
              },
              child: const Text('Not register yet? Register here!'))
        ],
      ),
    );
  }
}
