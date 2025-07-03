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
    
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      
      splashColor: colorScheme.primary.withValues(alpha: .2), 
      highlightColor: colorScheme.primary.withValues(alpha: .1), 
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          
          color: colorScheme.surface, 
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            
            color: colorScheme.outlineVariant, 
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              
              color: colorScheme.shadow.withValues(alpha: 0.2), 
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
              
              color: colorScheme.primary,
            ),
            const SizedBox(height: 10),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}