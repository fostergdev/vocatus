import 'package:flutter/material.dart';

class CustomPopupMenuItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  CustomPopupMenuItem({
    required this.label,
    required this.icon,
    required this.onTap,
  });
}

class CustomPopupMenu extends StatelessWidget {
  final List<CustomPopupMenuItem> items;
  final Color iconColor;

  const CustomPopupMenu({
    super.key,
    required this.items,
    this.iconColor = Colors.purple, // Roxo padrão
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      color: Colors.purple.shade800.withAlpha(235),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      icon: Icon(Icons.more_vert, color: iconColor),
      onSelected: (index) => items[index].onTap(),
      itemBuilder: (context) => [
        for (int i = 0; i < items.length; i++)
          PopupMenuItem<int>(
            value: i,
            child: Row(
              children: [
                Icon(items[i].icon, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  items[i].label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
