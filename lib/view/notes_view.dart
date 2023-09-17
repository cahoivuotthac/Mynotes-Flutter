import 'package:flutter/material.dart';
import '../constants/routes.dart';
import '../enums/menu_action.dart';
import '../services/auth/auth_service.dart';

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
                    await AuthService.firebase().logOut();
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      loginRoute,
                      (route) => false,
                    );
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
  //function type is bool because the content is 'Are you...?'
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
  ).then((value) =>
      value ??
      false); //when users dismiss the dialog (means that tap outside the dialog)
}
