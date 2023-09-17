import 'package:flutter/material.dart';
import 'package:freecodecamp/constants/routes.dart';
import 'package:freecodecamp/services/auth/auth_service.dart';
import 'package:freecodecamp/view/login_view.dart';
import 'package:freecodecamp/view/notes_view.dart';
import 'package:freecodecamp/view/register_view.dart';
import 'package:freecodecamp/view/verify_email_view.dart';
//import 'package:firebase_auth/firebase_auth.dart'; => for FirebaseAuth.instance.createUserWithEmailAndPassword function
//import 'firebase_options.dart'; // also for Firebase.initializeApp function
//import 'package:firebase_core/firebase_core.dart'; => for Firebase.initializeApp function

void main() {
  WidgetsFlutterBinding
      .ensureInitialized(); //make sure that the binding is initialized before the application is running
  runApp(
    MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors
              .blue, //this is a color of appBar, primarySwatch cung cấp nhiều màu (màu đơn lẻ, chứ kp các loại màu trộn)
        ),
        home: const HomePage(),
        routes: {
          //named routes
          loginRoute: (context) => const LoginView(),
          registerRoute: (context) => const RegisterView(),
          notesRoute: (context) => const NotesView(),
          verifyEmailRoute: (context) => const VerifyEmailView(),
        }),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      //firebase setup

      //widget FutureBuilder includes future and builder
      //why use FutureBuilder?
      //1. need to make sure that Firebase is initialized properly, after that other UI components have been runned
      //2. wait until future is done, builder will be runned upon future's result
      future: AuthService.firebase().initialized(),
      builder: (context, snapshot) {
        //Future Builder is a Widget so the output is also a widget => we need to return a widget
        switch (snapshot.connectionState) {
          case ConnectionState
                .done: //if future works then this UI will be showed on screen
            //print(FirebaseAuth.instance.currentUser); print some credential information about current-logined user
            final user = AuthService.firebase()
                .currentUser; //to storage credential information about the current user in Firebase Authentication
            if (user != null) {
              if (user.isEmailVerified) {
                return const NotesView();
              } else {
                return const VerifyEmailView();
              }
            } else {
              return const LoginView();
            }
          //LoginView is embeded in HomePageView

          //if you tap in user, you can see that its type is nullable
          // print(user);
          // if (user?.emailVerified ?? false) {
          //this is a boolean type (inside if statement). Boolean don't accecpt a null value so that you need to make sure that 'user?.emailVerified' is not a null
          //explain a bit: it means if user.emailVerified is not null then return its value, else return false
          //   return const Text('Done');
          // } else {
          //   return const VerifyEmailView();
          // }
          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}
