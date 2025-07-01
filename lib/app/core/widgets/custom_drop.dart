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
    // Acesse o ColorScheme do tema atual
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return DropdownButtonFormField<T>(
      value: value,
      hint: hint != null
          ? Text(
              hint!,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant, // Cor para o hint text
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
              color: colorScheme.onSurface, // Cor do texto dos itens do menu
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
              color: colorScheme.onSurface, // Cor do texto do item selecionado
            ),
          );
        }).toList();
      },
      // Estilo do campo (InputDecoration) para alinhar com o tema
      decoration: InputDecoration(
        filled: true,
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
        // Ícone da seta
        suffixIconColor: colorScheme.onSurfaceVariant, // Cor da seta do dropdown
      ),
      // Estilo do Dropdown em si
      dropdownColor: colorScheme.surfaceContainerHigh, // Cor do fundo do menu dropdown
      style: textTheme.bodyLarge?.copyWith(
        color: colorScheme.onSurface, // Cor do texto principal do Dropdown
      ),
      iconEnabledColor: colorScheme.onSurfaceVariant, // Cor do ícone da seta quando habilitado
      iconDisabledColor: colorScheme.onSurfaceVariant.withOpacity(0.5), // Cor do ícone da seta quando desabilitado
    );
  }
}