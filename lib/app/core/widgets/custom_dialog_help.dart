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
    // Access the ColorScheme of the current theme
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      // Dialog background color
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint, // For Material 3 elevation effect

      title: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: colorScheme.onSurface, // Title text color
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      content: Text(
        message,
        style: TextStyle(
          color: colorScheme.onSurfaceVariant, // Message text color
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: colorScheme.primary, // Button text color
          ),
          child: const Text('OK'),
        ),
      ],
    );
  }
}