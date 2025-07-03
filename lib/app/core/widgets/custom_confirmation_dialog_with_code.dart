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
        .toString();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
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
          
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary, 
            foregroundColor:
                colorScheme.onPrimary, 
          ),
          child: Text(widget.confirmButtonText),
        ),
        TextButton(
          onPressed: () => Get.back(),
          
          style: TextButton.styleFrom(
            foregroundColor:
                colorScheme.onSurfaceVariant, 
          ),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}
