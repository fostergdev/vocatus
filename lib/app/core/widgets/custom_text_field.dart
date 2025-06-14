import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText; // Alterado para opcional
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
    this.hintText, // Agora não é mais obrigatório
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
      decoration: (widget.decoration ?? InputDecoration(
        hintText: widget.hintText,
        hintStyle: widget.hintStyle,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _showPassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: _togglePasswordVisibility,
              )
            : widget.suffixIcon,
      )),
    );
  }
}
