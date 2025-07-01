import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vocatus/app/core/widgets/custom_dialog.dart';

class CustomConfirmationDialogWithCode extends StatefulWidget {
  final String title;
  final String message;
  final VoidCallback onConfirm;
  final String confirmButtonText;

  const CustomConfirmationDialogWithCode({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    this.confirmButtonText = 'Confirmar',
  });

  @override
  State<CustomConfirmationDialogWithCode> createState() =>
      _CustomConfirmationDialogWithCodeState();
}

class _CustomConfirmationDialogWithCodeState
    extends State<CustomConfirmationDialogWithCode> {
  final TextEditingController _codeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final String _generatedCode;

  @override
  void initState() {
    super.initState();
    // Gera um código de 3 dígitos (entre 100 e 999)
    _generatedCode = (100 + (DateTime.now().millisecondsSinceEpoch % 900))
        .toString();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Acesse o ColorScheme do tema atual
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return CustomDialog(
      title: widget.title,

      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SelectableText(
                '${widget.message}\n\nCódigo: $_generatedCode',
                style: TextStyle(
                  // Cor do texto principal do diálogo
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                maxLength: 3,
                decoration: InputDecoration(
                  labelText: 'Digite o código',
                  border: const OutlineInputBorder(),
                  counterText: '',
                  // Cores da label e borda do TextFormField
                  labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: colorScheme.outline,
                      width: 1.0,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: colorScheme.error,
                      width: 1.0,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: colorScheme.error,
                      width: 2.0,
                    ),
                  ),
                ),
                style: TextStyle(
                  // Cor do texto digitado no campo
                  color: colorScheme.onSurface,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite o código para confirmar.';
                  }
                  if (value != _generatedCode) {
                    return 'Código incorreto. Tente novamente.';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Get.back();
              widget.onConfirm();
            }
          },
          // Estilo do botão de confirmação
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary, // Cor de fundo do botão
            foregroundColor:
                colorScheme.onPrimary, // Cor do texto/ícone do botão
          ),
          child: Text(widget.confirmButtonText),
        ),
        TextButton(
          onPressed: () => Get.back(),
          // Estilo do botão de cancelar
          style: TextButton.styleFrom(
            foregroundColor:
                colorScheme.onSurfaceVariant, // Cor do texto do botão
          ),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}
