import 'package:flutter/material.dart';

class CustomDialogHelp extends StatelessWidget {
  final String title;
  final String message;

  const CustomDialogHelp({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(children: [Text(title), const SizedBox(width: 8)]),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
