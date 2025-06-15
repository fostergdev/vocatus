import 'package:flutter/material.dart';

class CustomDrop<T> extends StatelessWidget {
  final List<T> items;
  final T? value;
  final String Function(T) labelBuilder;
  final ValueChanged<T?> onChanged;
  final String? hint;
  final String? Function(T?)? validator;

  const CustomDrop({
    super.key,
    required this.items,
    required this.value,
    required this.labelBuilder,
    required this.onChanged,
    this.hint,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      hint: hint != null ? Text(hint!) : null,
      isExpanded: true,
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(labelBuilder(item)),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }
}