import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    
    final T? effectiveValue = value != null
        ? items.firstWhereOrNull((item) => item == value)
        : null;

    return DropdownButtonFormField<T>(
      value: effectiveValue,
      hint: hint != null
          ? Text(
              hint!,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant, 
              ),
            )
          : null,
      isExpanded: true,
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(
            labelBuilder(item),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colorScheme.onSurface, 
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
      selectedItemBuilder: (context) {
        return items.map((item) {
          return Text(
            labelBuilder(item),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colorScheme.onSurface, 
            ),
          );
        }).toList();
      },
      
      decoration: InputDecoration(
        filled: true,
        fillColor: colorScheme.surface, 
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
        
        suffixIconColor: colorScheme.onSurfaceVariant, 
      ),
      
      dropdownColor: colorScheme.surface, 
      style: textTheme.bodyLarge?.copyWith(
        color: colorScheme.onSurface, 
      ),
      iconEnabledColor: colorScheme.onSurfaceVariant, 
      iconDisabledColor: colorScheme.onSurfaceVariant.withValues(alpha:0.5), 
    );
  }
}