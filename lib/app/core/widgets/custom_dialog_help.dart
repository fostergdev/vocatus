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
    
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint, 

      title: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: colorScheme.onSurface, 
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      content: Text(
        message,
        style: TextStyle(
          color: colorScheme.onSurfaceVariant, 
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: colorScheme.primary, 
          ),
          child: const Text('OK'),
        ),
      ],
    );
  }
}