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
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          if (icon != null) ...[
            const SizedBox(width: 8),
            Icon(icon),
          ],
        ],
      ),
      content: content,
      actions: actions,
    );
  }
}
