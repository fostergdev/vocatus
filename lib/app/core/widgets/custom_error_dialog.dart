import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomErrorDialog extends StatelessWidget {
  final String? title;
  final String message;
  final VoidCallback? onOk;

  const CustomErrorDialog({
    super.key,
    this.title,
    required this.message,
    this.onOk,
  });

  @override
  Widget build(BuildContext context) {
    // Acesse o ColorScheme do tema atual
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      // Cor de fundo do diálogo de erro
      backgroundColor: colorScheme.errorContainer, // Cor de fundo suave para erros (Material 3)
      surfaceTintColor: colorScheme.error, // Tinta de elevação para Material 3

      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícone de erro (opcional, mas comum para indicar erro)
            Icon(
              Icons.error_outline,
              color: colorScheme.error, // Cor do ícone de erro
              size: 48,
            ),
            const SizedBox(height: 16),
            if (title != null && title!.isNotEmpty) ...[
              Text(
                title!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: colorScheme.onErrorContainer, // Texto do título do erro
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onErrorContainer, // Texto da mensagem de erro
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onOk ?? () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.error, // Fundo do botão de erro
                foregroundColor: colorScheme.onError, // Texto/ícone do botão de erro
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }
}