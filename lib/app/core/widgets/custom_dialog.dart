import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget> actions;
  final IconData? icon;

  const CustomDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,

      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          
          Text(
            title,
            style: TextStyle(
              color: colorScheme.onSurface, 
              fontWeight: FontWeight.bold, 
            ),
          ),
          if (icon != null) ...[
            const SizedBox(width: 8),
            
            Icon(
              icon,
              color: colorScheme.primary, 
              size: 24, 
            ),
          ],
        ],
      ),
      
      content: content,
      
      actions: actions,
      
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    );
  }
}