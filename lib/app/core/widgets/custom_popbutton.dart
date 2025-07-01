import 'package:flutter/material.dart';

// Mantenha esta classe auxiliar como está
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
  // Removendo iconColor e definindo-o automaticamente via tema
  final IconData? icon;
  final TextAlign textAlign;

  const CustomPopupMenu({
    super.key,
    required this.items,
    this.icon,
    this.textAlign = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    // Acesse o ColorScheme do tema atual
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return PopupMenuButton<int>(
      // Cor de fundo do PopupMenu
      color: colorScheme.surfaceContainerHigh, // Uma cor de superfície mais elevada
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      // Cor do ícone do botão que abre o menu (ex: três pontinhos)
      // Usamos onSurfaceVariant para um ícone neutro que contrasta com o fundo da AppBar/tela
      icon: Icon(icon ?? Icons.more_vert, color: colorScheme.onSurfaceVariant),
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
                  // Cor do ícone dos itens do menu (usa a cor primária ou onSurface)
                  Icon(items[i].icon, color: colorScheme.onSurface),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    items[i].label,
                    style: TextStyle(
                      // Cor do texto dos itens do menu
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