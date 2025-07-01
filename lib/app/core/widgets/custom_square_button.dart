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
    // Acesse o ColorScheme do tema atual
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      // Use a cor primária do tema para os efeitos de splash e highlight
      splashColor: colorScheme.primary.withValues(alpha: .2), // Um tom mais suave da cor primária
      highlightColor: colorScheme.primary.withValues(alpha: .1), // Um tom ainda mais suave
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          // Cor de fundo do botão: use surface ou background do tema
          color: colorScheme.surface, // Geralmente branco no tema claro, cinza escuro no escuro
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            // Cor da borda: use outline ou um tom de cinza do tema
            color: colorScheme.outlineVariant, // Uma cor de borda do Material 3
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              // Cor da sombra: use a cor da sombra do tema
              color: colorScheme.shadow.withValues(alpha: 0.2), // Uma sombra mais sutil
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
              // Cor do ícone: use a cor primária do tema
              color: colorScheme.primary,
            ),
            const SizedBox(height: 10),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                // Cor do texto: use onSurface (texto em cima da superfície)
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