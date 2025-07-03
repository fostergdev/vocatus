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
  final Widget? actionWidget; 
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
    this.actionWidget, 
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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    
    Widget? internalSuffixIcon;
    if (widget.isPassword) {
      internalSuffixIcon = IconButton(
        icon: Icon(
          _showPassword ? Icons.visibility : Icons.visibility_off,
          color: colorScheme.onSurfaceVariant,
        ),
        onPressed: _togglePasswordVisibility,
      );
    } else {
      
      internalSuffixIcon = widget.suffixIcon;
    }

    
    InputDecoration baseDecoration = InputDecoration(
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest,
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
        borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
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
      hintStyle: widget.hintStyle ?? textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
      labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      errorStyle: TextStyle(color: colorScheme.error),
      helperStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      prefixIconColor: colorScheme.onSurfaceVariant,
      suffixIconColor: colorScheme.onSurfaceVariant,
      
      suffixIcon: internalSuffixIcon,
    );

    
    InputDecoration finalDecoration = baseDecoration.copyWith(
      hintText: widget.hintText ?? widget.decoration?.hintText,
      hintStyle: widget.hintStyle ?? widget.decoration?.hintStyle,
    );

    if (widget.decoration != null) {
      finalDecoration = finalDecoration.copyWith(
        labelText: widget.decoration?.labelText,
        alignLabelWithHint: widget.decoration?.alignLabelWithHint,
        filled: widget.decoration?.filled,
        fillColor: widget.decoration?.fillColor,
        enabledBorder: widget.decoration?.enabledBorder,
        focusedBorder: widget.decoration?.focusedBorder,
        contentPadding: widget.decoration?.contentPadding,
        
        
        
        suffixIcon: widget.isPassword ? internalSuffixIcon : (widget.suffixIcon ?? widget.decoration?.suffixIcon),
        
        hintText: widget.hintText ?? widget.decoration?.hintText ?? finalDecoration.hintText,
        hintStyle: widget.hintStyle ?? widget.decoration?.hintStyle ?? finalDecoration.hintStyle,
      );
    }

    finalDecoration = finalDecoration.applyDefaults(Theme.of(context).inputDecorationTheme);

    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center, 
      children: [
        Expanded(
          child: TextFormField(
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
            decoration: finalDecoration,
            style: TextStyle(
              color: colorScheme.onSurface,
            ),
            cursorColor: colorScheme.primary,
          ),
        ),
        if (widget.actionWidget != null) ...[
          const SizedBox(width: 8.0), 
          widget.actionWidget!, 
        ],
      ],
    );
  }
}