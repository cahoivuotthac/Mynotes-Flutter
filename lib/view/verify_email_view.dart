import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freecodecamp/constants/routes.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify email')),
      body: Column(
        children: [
          const Text(
              "We're sent you an email verification. Please open it to verify your account!"),
          const Text(
              "If you haven't received the eamil verification yet, press the button below"),
          TextButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              await user?.sendEmailVerification();
            },
            child: const Text('Send email verification'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance
                  .signOut(); //just sign out and don't navigate to the register view
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(registerRoute, (route) => false);
            },
            child: const Text('Restart'),
          )
        ],
      ),
    );
  }
}
