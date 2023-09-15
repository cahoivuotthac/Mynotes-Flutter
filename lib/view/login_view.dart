import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freecodecamp/constants/routes.dart';
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
                //grab email and password that users just entered
                final email = _email.text;
                final password = _password.text;

                //if user entered wrong account
                try {
                  await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: email,
                    password: password,
                  );
                  final user = FirebaseAuth.instance.currentUser;
                  if (user?.emailVerified ?? false) {
                    //if user's email is verified
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      notesRoute,
                      (route) => false,
                    );
                  } else {
                    //if user's email is NOT verified
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      verifyEmailRoute,
                      (route) => false,
                    );
                  }
                } on FirebaseAuthException catch (e) {
                  //handle exception about FirebaseAuthException

                  //write like this when you wanna catch specific error
                  //print(e.code); //view the error as a code not the text like print(e);
                  if (e.code == 'user-not-found') {
                    await showErrorDialog(
                      context,
                      'User not found',
                    );
                  } else if (e.code == 'wrong-password ') {
                    await showErrorDialog(
                      context,
                      'Wrong credentials',
                    );
                  } else {
                    await showErrorDialog(
                      context,
                      'Error: ${e.code}',
                    );
                  }
                } catch (e) {
                  //handle general exception
                  //e in this case is Object. Everthing has a type is Object has a function call toString();
                  await showErrorDialog(
                    context,
                    e.toString(),
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
