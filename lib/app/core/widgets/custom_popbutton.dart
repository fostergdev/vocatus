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
  final Color iconColor;
  final IconData? icon;
  final TextAlign textAlign; // Novo parâmetro

  const CustomPopupMenu({
    super.key,
    required this.items,
    this.iconColor = Colors.purple,
    this.icon,
    this.textAlign = TextAlign.left, // Padrão agora é left
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      color: Colors.purple.shade800.withAlpha(235),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      icon: Icon(icon ?? Icons.more_vert, color: iconColor),
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
                  Icon(items[i].icon, color: Colors.white),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    items[i].label,
                    style: const TextStyle(
                      color: Colors.white,
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
