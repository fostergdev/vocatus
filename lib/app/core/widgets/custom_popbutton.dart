import 'package:flutter/material.dart';


class CustomPopupMenuItem {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  CustomPopupMenuItem({
    required this.label,
    this.icon,
    required this.onTap,
  });
}

class CustomPopupMenu extends StatelessWidget {
  final List<CustomPopupMenuItem> items;
  
  final IconData? icon;
  final TextAlign textAlign;
  final Color? iconColor;

  const CustomPopupMenu({
    super.key,
    required this.items,
    this.icon,
    this.textAlign = TextAlign.left,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return PopupMenuButton<int>(
      
      color: colorScheme.surfaceContainerHigh, 
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      
      
      icon: Icon(icon ?? Icons.more_vert, color: iconColor ?? colorScheme.onSurfaceVariant),
      onSelected: (index) => items[index].onTap(),
      itemBuilder: (context) => [
        for (int i = 0; i < items.length; i++)
          PopupMenuItem<int>(
            value: i,
            child: Row(
              mainAxisAlignment: textAlign == TextAlign.center
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                if (items[i].icon != null) ...[
                  
                  Icon(items[i].icon, color: colorScheme.onSurface),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    items[i].label,
                    style: TextStyle(
                      
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: textAlign,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}