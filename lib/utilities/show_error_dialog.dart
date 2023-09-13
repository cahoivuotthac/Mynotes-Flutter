import 'package:flutter/material.dart';

Future<void> showErrorDialog(BuildContext context, String text) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('An error occurred'),
          content: Text(text),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(); //when you press this button, dialog will disappear
              },
              child: const Text('OK'), //display for user
            )
          ],
        );
      });
}
