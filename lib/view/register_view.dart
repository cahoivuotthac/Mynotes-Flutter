import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freecodecamp/constants/routes.dart';
import 'package:freecodecamp/utilities/show_error_dialog.dart';

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

                  //I want email verification to be sent right after users press register button
                  //the 'send email verification' button will be used when users have not be sent email for a long time
                  final user = FirebaseAuth.instance.currentUser;
                  await user?.sendEmailVerification();

                  // Navigator.of(context).pushNamedAndRemoveUntil(
                  //   verifyEmailRoute,
                  //   (route) => false,
                  // );
                  Navigator.of(context).pushNamed(verifyEmailRoute);
                  //! we don't use pushNamedAndRemoveUntil(..) like before?

                  //-I don't want to navigate to another routes when the users do sth wrong
                  //-I want them to tap the <- button to go back to the register view to type email again (I think this way is better than the above option)
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'weak-password') {
                    await showErrorDialog(
                      //if dont have a word 'await', showErrorDialog just return a future, not display a dialog for user to see
                      context,
                      'Weak password',
                    );
                  } else if (e.code == 'email-already-in-use') {
                    await showErrorDialog(
                      context,
                      'Email already in use',
                    );
                  } else if (e.code == 'invalid-email') {
                    await showErrorDialog(
                      context,
                      'Invalid email',
                    );
                  } else {
                    await showErrorDialog(
                      context,
                      'Error: ${e.code}',
                    );
                  }
                } catch (e) {
                  await showErrorDialog(
                    context,
                    e.toString(),
                  );
                }
              },
              child: const Text('Register')),
          TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  loginRoute,
                  (route) => false,
                );
              },
              child: const Text('Already registered? Login here!'))
        ],
      ),
    );
  }
}
