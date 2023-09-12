import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email; //firebase setup
  late final TextEditingController _password; //firebase setup
  @override
  void initState() {
    // use TextEditingController need this function
    // firebase setup
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    // use TextEditingController need this function
    // firebase setup
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
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

                try {
                  //in a try block, if things dont work properly it will go to code lines after on....
                  await FirebaseAuth.instance.createUserWithEmailAndPassword(
                    email: email,
                    password: password,
                  );
                  devtools.log(userCredential.toString());
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'weak-password') {
                    devtools.log('Weak password');
                  } else if (e.code == 'email-already-in-use') {
                    devtools.log('Email already in use');
                  } else if (e.code == 'invalid-email') {
                    devtools.log('Invalid email entered');
                  }
                }
              },
              child: const Text('Register')),
          TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login/',
                  (route) => false,
                );
              },
              child: const Text('Already registered? Login here!'))
        ],
      ),
    );
  }
}
