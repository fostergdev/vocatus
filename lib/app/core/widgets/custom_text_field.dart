import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? Function(String?)? validator;
  final bool isPassword;
  final TextInputType? keyboardType;
  final MaskTextInputFormatter? maskFormatter;
  final Widget? suffixIcon; // Seu parâmetro para o ícone customizado
  final int? maxLines;
  final int? minLines;
  final TextStyle? hintStyle;
  final InputDecoration? decoration; // Seu parâmetro para o decoration customizado
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
    // 1. Determina qual ícone de sufixo deve ser usado:
    //    - Se for um campo de senha, usa o ícone de visibilidade.
    //    - Caso contrário, usa o ícone customizado que foi passado (widget.suffixIcon).
    Widget? effectiveSuffixIcon;
    if (widget.isPassword) {
      effectiveSuffixIcon = IconButton(
        icon: Icon(
          _showPassword ? Icons.visibility : Icons.visibility_off,
        ),
        onPressed: _togglePasswordVisibility,
      );
    } else {
      effectiveSuffixIcon = widget.suffixIcon;
    }

    // 2. Cria a decoração final:
    //    - Começa com a decoração que foi passada (widget.decoration) ou uma InputDecoration vazia.
    //    - Usa o método .copyWith() para MERGEAR as propriedades, garantindo que:
    //      - O hintText e hintStyle do seu CustomTextField tenham prioridade,
    //        ou usem os da decoração passada se não forem definidos aqui.
    //      - O suffixIcon seja SEMPRE o effectiveSuffixIcon que determinamos acima.
    InputDecoration finalDecoration = (widget.decoration ?? const InputDecoration()).copyWith(
      hintText: widget.hintText ?? widget.decoration?.hintText,
      hintStyle: widget.hintStyle ?? widget.decoration?.hintStyle,
      suffixIcon: effectiveSuffixIcon,
    );

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
    );
  }
}