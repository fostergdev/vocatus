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
    _generatedCode = (100 + (DateTime.now().millisecondsSinceEpoch % 900))
        .toString(); // Gera um código de 3 dígitos
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: widget.title,
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${widget.message}\n\nCódigo: $_generatedCode'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              maxLength: 3,
              decoration: const InputDecoration(
                labelText: 'Digite o código',
                border: OutlineInputBorder(),
                counterText: '',
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
      actions: [
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Get.back(); // Fecha o diálogo antes de executar a ação
              widget.onConfirm();
            }
          },
          child: Text(widget.confirmButtonText),
        ),
        TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
      ],
    );
  }
}
