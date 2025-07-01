import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? Function(String?)? validator;
  final bool isPassword;
  final TextInputType? keyboardType;
  final MaskTextInputFormatter? maskFormatter;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? minLines;
  final TextStyle? hintStyle;
  final InputDecoration? decoration;
  final ValueChanged<String>? onChanged;
  final bool autofocus;

  const CustomTextField({
    super.key,
    this.controller,
    this.hintText,
    this.validator,
    this.isPassword = false,
    this.keyboardType,
    this.maskFormatter,
    this.suffixIcon,
    this.maxLines,
    this.minLines,
    this.hintStyle,
    this.decoration,
    this.onChanged,
    this.autofocus = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _showPassword = true;

  void _togglePasswordVisibility() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Acesse o ColorScheme do tema atual
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    // 1. Determina qual ícone de sufixo deve ser usado:
    Widget? effectiveSuffixIcon;
    if (widget.isPassword) {
      effectiveSuffixIcon = IconButton(
        icon: Icon(
          _showPassword ? Icons.visibility : Icons.visibility_off,
          color: colorScheme.onSurfaceVariant, // Cor do ícone de visibilidade
        ),
        onPressed: _togglePasswordVisibility,
      );
    } else {
      effectiveSuffixIcon = widget.suffixIcon;
    }

    // 2. Cria a decoração base com as cores do tema
    InputDecoration baseDecoration = InputDecoration(
      filled: true, // Campo preenchido para melhor visualização do fundo
      fillColor: colorScheme.surfaceVariant, // Cor de fundo do campo
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: colorScheme.outline, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: colorScheme.outline, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: colorScheme.primary, width: 2.0), // Borda focada com a cor primária
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: colorScheme.error, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: colorScheme.error, width: 2.0),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      // Cores para hintText e labelText
      hintStyle: widget.hintStyle ?? TextStyle(color: colorScheme.onSurfaceVariant),
      labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      // Cores para o texto de erro e help text
      errorStyle: TextStyle(color: colorScheme.error),
      helperStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      // Cor do prefixIcon e suffixIcon
      prefixIconColor: colorScheme.onSurfaceVariant,
      suffixIconColor: colorScheme.onSurfaceVariant,
    );

    // 3. Mescla a decoração base com a decoração customizada passada pelo usuário
    //    e aplica o hintText e suffixIcon
    InputDecoration finalDecoration = baseDecoration.copyWith(
      hintText: widget.hintText ?? widget.decoration?.hintText,
      hintStyle: widget.hintStyle ?? widget.decoration?.hintStyle,
      suffixIcon: effectiveSuffixIcon,
    ).applyDefaults(Theme.of(context).inputDecorationTheme); // Aplica defaults do tema

    return TextFormField(
      onChanged: widget.onChanged,
      validator: widget.validator,
      controller: widget.controller,
      obscureText: widget.isPassword ? _showPassword : false,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.maskFormatter != null
          ? [widget.maskFormatter!]
          : [],
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      autofocus: widget.autofocus,
      decoration: finalDecoration, // Usa a decoração final mesclada
      style: TextStyle(
        color: colorScheme.onSurface, // Cor do texto digitado no campo
      ),
      cursorColor: colorScheme.primary, // Cor do cursor
    );
  }
}