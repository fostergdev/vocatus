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
    // Acesse o ColorScheme do tema atual
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      // Fundo do diálogo e a "tinta" de elevação para Material 3
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,

      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Título do diálogo
          Text(
            title,
            style: TextStyle(
              color: colorScheme.onSurface, // Cor do texto do título
              fontWeight: FontWeight.bold, // Opcional: para destacar o título
            ),
          ),
          if (icon != null) ...[
            const SizedBox(width: 8),
            // Ícone opcional no título
            Icon(
              icon,
              color: colorScheme.primary, // Cor do ícone
              size: 24, // Opcional: tamanho do ícone
            ),
          ],
        ],
      ),
      // Conteúdo do diálogo (será preenchido pelos diálogos que usam CustomDialog)
      content: content,
      // Ações do diálogo (botões, etc., também preenchidos pelos filhos)
      actions: actions,
      // Adiciona padding padrão às ações se elas forem vazias, para manter a consistência
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    );
  }
}