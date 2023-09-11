import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:freecodecamp/view/login_view.dart';
import 'package:freecodecamp/view/register_view.dart';
import 'package:freecodecamp/view/verify_email_view.dart';
import 'firebase_options.dart';
//import 'package:firebase_auth/firebase_auth.dart'; => for FirebaseAuth.instance.createUserWithEmailAndPassword function
//import 'firebase_options.dart'; // also for Firebase.initializeApp function
//import 'package:firebase_core/firebase_core.dart'; => for Firebase.initializeApp function
import 'dart:developer' as devtools
    show
        log; //when you want to use a specific thing in this package, if not have show then will show everything in this package

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
          '/login/': (context) => const LoginView(),
          '/register/': (context) => const RegisterView(),
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
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        //Future Builder is a Widget so the output is also a widget => we need to return a widget
        switch (snapshot.connectionState) {
          case ConnectionState
                .done: //if future works then this UI will be showed on screen
            //print(FirebaseAuth.instance.currentUser); print some credential information about current-logined user
            final user = FirebaseAuth.instance
                .currentUser; //to storage credential information about the current user in Firebase Authentication
            if (user != null) {
              if (user.emailVerified) {
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

enum MenuAction {
  logout
} //enumeration called MenuAtion with a single value - logout

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Main UI'),
          actions: [
            //actions is list type, use [] for the type list
            PopupMenuButton<MenuAction>(//display a popup menu when tapped icon
                onSelected: (value) async {
              //this will be called when a menu item is selected
              //it takes the selected value as a parameter and performs an action based on the value
              switch (value) {
                case MenuAction
                      .logout: //if the selected value is MenuAction.logout it shows a logout dialog
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('/login/', (route) => false);
                  }
              }
            }, itemBuilder: (context) {
              //create the menu items for the popup menu
              //itemBuilder is list type
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout, //value is what programmer see
                  child: Text('Log out'), //child is what user see
                )
              ];
            })
          ],
        ),
        body: const Text('Hello world'));
  }
}

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      //create an alert dialogue
      return AlertDialog(
          title: const Text('Sign out'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .pop(false); //close the current dialog and return false
                },
                child: const Text('Cancel')),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text('Log out'))
          ]);
    },
  ).then((value) => value ?? false); //when users dismiss the dialog
}
