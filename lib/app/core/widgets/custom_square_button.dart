import 'package:flutter/material.dart';

class CustomSquareButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final double? elevation;

  const CustomSquareButton({
    required this.text,
    required this.icon,
    required this.onPressed,
    this.elevation,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      splashColor: Colors.deepPurple.withValues(alpha: .3),
      highlightColor: Colors.deepPurple.withValues(alpha: .2),
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.withValues(alpha: .3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: .4),
              blurRadius: elevation ?? 4.0,
              offset: Offset(0, (elevation ?? 4.0) / 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 30,
              color: Colors.deepPurple,
            ),
            const SizedBox(height: 10),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
